// MediaPipe returns detections in an arbitrary order that can shuffle between
// frames. For anything multi-player that is fatal — player 1 and player 3 would
// swap rockets mid-flight. This assigns each detection a stable id by matching
// it to the nearest track from the previous frame, and keeps a track alive for
// a short grace period so a momentary dropout doesn't reset anybody.

export function createTracker({ maxDist = 0.22, maxAge = 400 } = {}) {
  let tracks = []
  let nextId = 1

  return {
    /**
     * points: [{ x, y, data }] in normalised coordinates.
     * Returns live tracks, each carrying a stable `id`.
     */
    update(points, now) {
      const unmatched = points.map((p, i) => ({ p, i }))
      const claimed = new Set()

      // Greedy nearest-neighbour: score every track/detection pair, then take
      // the best pairs first so a close match wins over a distant one.
      const pairs = []
      for (const t of tracks) {
        for (const u of unmatched) {
          const d = Math.hypot(t.x - u.p.x, t.y - u.p.y)
          if (d <= maxDist) pairs.push({ t, u, d })
        }
      }
      pairs.sort((a, b) => a.d - b.d)

      const usedTracks = new Set()
      for (const { t, u } of pairs) {
        if (usedTracks.has(t.id) || claimed.has(u.i)) continue
        usedTracks.add(t.id)
        claimed.add(u.i)
        // Velocity is what makes throwing feel right in Kinetic.
        const dt = Math.max(1, now - t.lastSeen)
        t.vx = ((u.p.x - t.x) / dt) * 1000
        t.vy = ((u.p.y - t.y) / dt) * 1000
        t.x = u.p.x
        t.y = u.p.y
        t.data = u.p.data
        t.lastSeen = now
        t.missing = false
      }

      for (const u of unmatched) {
        if (claimed.has(u.i)) continue
        tracks.push({
          id: nextId++,
          x: u.p.x,
          y: u.p.y,
          vx: 0,
          vy: 0,
          data: u.p.data,
          firstSeen: now,
          lastSeen: now,
          missing: false,
        })
      }

      for (const t of tracks) {
        if (!usedTracks.has(t.id) && t.lastSeen !== now) t.missing = true
      }
      tracks = tracks.filter((t) => now - t.lastSeen <= maxAge)
      return tracks
    },

    /** Tracks currently being seen, ordered left to right on screen. */
    live(now) {
      return tracks
        .filter((t) => !t.missing || now - t.lastSeen < 150)
        .sort((a, b) => a.x - b.x)
    },

    reset() {
      tracks = []
    },
  }
}

/**
 * Locks tracks to player slots at the start of a round, ordered left to right.
 * Once locked, players keep their slot even if they move past each other.
 */
export function createRoster(count) {
  let ids = []
  return {
    lock(tracks) {
      ids = tracks.slice(0, count).map((t) => t.id)
      return ids.length
    },
    /** Returns an array of length `count`; empty slots are null. */
    resolve(tracks) {
      const byId = new Map(tracks.map((t) => [t.id, t]))
      const slots = new Array(count).fill(null)
      for (let i = 0; i < ids.length; i++) slots[i] = byId.get(ids[i]) || null
      // Any free slot can be adopted by an unclaimed track, so a player who
      // dropped out entirely can rejoin by putting their hand back up.
      const taken = new Set(ids)
      const spare = tracks.filter((t) => !taken.has(t.id))
      for (let i = 0; i < count && spare.length; i++) {
        if (!slots[i]) {
          const t = spare.shift()
          ids[i] = t.id
          slots[i] = t
        }
      }
      return slots
    },
    reset() {
      ids = []
    },
  }
}
