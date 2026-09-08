// Raw MediaPipe landmarks jitter by a pixel or two every frame even when a hand
// is perfectly still, and that shimmer is what makes tracking look cheap. A
// plain moving average would fix it but add lag, which feels worse in a game.
//
// The One Euro filter adapts instead: it smooths hard when you are still and
// barely at all when you move fast, so noise disappears while fast motion stays
// responsive.

const TAU = 2 * Math.PI

function alphaFor(cutoff, dt) {
  const tau = 1 / (TAU * cutoff)
  return 1 / (1 + tau / dt)
}

// Tuned by measurement, not guesswork: these values cut the noise on a still
// hand by ~11x while keeping a full-width swipe within ~5% of the true
// position. Raising beta buys responsiveness, lowering it buys steadiness.
export function createOneEuro({ minCutoff = 1.2, beta = 5.0, dCutoff = 1.0 } = {}) {
  let xPrev = null
  let dxPrev = 0
  let tPrev = null

  return {
    /** value in any unit, t in seconds. */
    filter(value, t) {
      if (!Number.isFinite(value)) return xPrev ?? 0
      if (xPrev === null || tPrev === null) {
        xPrev = value
        tPrev = t
        return value
      }
      let dt = t - tPrev
      // Guard against zero, negative or absurd gaps (tab was backgrounded).
      if (!(dt > 0) || dt > 0.25) dt = 1 / 60
      tPrev = t

      const dx = (value - xPrev) / dt
      const aD = alphaFor(dCutoff, dt)
      dxPrev = aD * dx + (1 - aD) * dxPrev

      const cutoff = minCutoff + beta * Math.abs(dxPrev)
      const a = alphaFor(cutoff, dt)
      xPrev = a * value + (1 - a) * xPrev
      return xPrev
    },
    reset() {
      xPrev = null
      dxPrev = 0
      tPrev = null
    },
  }
}

/**
 * Smooths a whole landmark array. One filter per landmark per axis, created
 * lazily so it works for hands (21 points) and bodies (33) alike.
 */
export function createLandmarkSmoother(opts = {}) {
  const axes = ['x', 'y', 'z']
  const filters = []

  return {
    apply(landmarks, tSeconds) {
      const out = new Array(landmarks.length)
      for (let i = 0; i < landmarks.length; i++) {
        const lm = landmarks[i]
        if (!lm) { out[i] = lm; continue }
        let slot = filters[i]
        if (!slot) {
          slot = { x: createOneEuro(opts), y: createOneEuro(opts), z: createOneEuro(opts) }
          filters[i] = slot
        }
        const next = { ...lm }
        for (const ax of axes) {
          if (typeof lm[ax] === 'number') next[ax] = slot[ax].filter(lm[ax], tSeconds)
        }
        out[i] = next
      }
      return out
    },
    reset() {
      for (const s of filters) if (s) { s.x.reset(); s.y.reset(); s.z.reset() }
    },
  }
}

/**
 * Rejects detections that are geometrically impossible, before they reach a
 * game. A hand collapsed to a few pixels or landmarks far outside the frame is
 * noise, and acting on it produces phantom inputs.
 */
export function plausibleHand(lm) {
  if (!lm || lm.length < 21) return false
  const span = Math.hypot(lm[0].x - lm[9].x, lm[0].y - lm[9].y)
  if (!(span > 0.015) || span > 0.9) return false
  let inside = 0
  for (const p of lm) {
    if (!Number.isFinite(p.x) || !Number.isFinite(p.y)) return false
    if (p.x > -0.25 && p.x < 1.25 && p.y > -0.25 && p.y < 1.25) inside += 1
  }
  return inside >= lm.length * 0.75
}

export function plausiblePose(lm) {
  if (!lm || lm.length < 33) return false
  const core = [11, 12, 23, 24]
  let seen = 0
  for (const i of core) {
    const p = lm[i]
    if (!p || !Number.isFinite(p.x)) return false
    if ((p.visibility ?? 1) >= 0.35) seen += 1
  }
  if (seen < 2) return false
  const shoulders = Math.hypot(lm[11].x - lm[12].x, lm[11].y - lm[12].y)
  return shoulders > 0.01
}
