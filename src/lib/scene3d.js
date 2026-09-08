// A small perspective renderer for the first-person games.
//
// The trick that makes a flat screen feel like a window into a room is
// head-coupled perspective: the virtual camera follows the player's real head,
// so leaning left genuinely reveals what was hidden behind the left edge.
// Everything here works in a right-handed space where +z goes away from the
// viewer, +x is right and +y is down.

export function createCamera({ fov = Math.PI / 2.6, parallax = 1.5, ease = 6 } = {}) {
  const eye = { x: 0, y: 0, z: 0 }
  const target = { x: 0, y: 0 }
  let shake = 0

  return {
    eye,
    get shake() { return shake },
    kick(amount = 1) { shake = Math.min(1.5, shake + amount) },

    /**
     * headX / headY are normalised screen coordinates of the player's head.
     * The camera offset is deliberately larger than life — a subtle shift reads
     * as a rendering wobble, a strong one reads as looking around.
     */
    track(headX, headY, dt) {
      if (Number.isFinite(headX)) target.x = (headX - 0.5) * parallax * 2
      if (Number.isFinite(headY)) target.y = (headY - 0.55) * parallax
      const k = Math.min(1, dt * ease)
      eye.x += (target.x - eye.x) * k
      eye.y += (target.y - eye.y) * k
      shake = Math.max(0, shake - dt * 3)
    },

    /** World point -> screen. Returns null when behind or beside the viewer. */
    project(p, W, H) {
      const focal = H / 2 / Math.tan(fov / 2)
      const dz = p.z - eye.z
      if (dz < 0.35) return null
      const f = focal / dz
      const jitter = shake ? (Math.random() - 0.5) * shake * 14 : 0
      return {
        x: W / 2 + (p.x - eye.x) * f + jitter,
        y: H / 2 + (p.y - eye.y) * f + jitter,
        s: f,
        z: dz,
      }
    },

    reset() {
      eye.x = 0
      eye.y = 0
      target.x = 0
      target.y = 0
      shake = 0
    },
  }
}

/** Distant things fade into the haze — the strongest depth cue after scale. */
export function fogAlpha(z, near = 6, far = 34) {
  if (z <= near) return 1
  if (z >= far) return 0
  return 1 - (z - near) / (far - near)
}

/**
 * A receding corridor. Rings are drawn far to near so nearer geometry covers
 * what is behind it without needing a depth buffer.
 */
export function drawCorridor(ctx, cam, W, H, opts = {}) {
  const {
    z0 = 0, spacing = 4, count = 14, radius = 5.2,
    color = '#7C5CFF', sides = 8, roll = 0,
  } = opts

  for (let i = count; i >= 1; i--) {
    const z = z0 + i * spacing
    const a = fogAlpha(z, spacing * 2, spacing * count)
    if (a <= 0.01) continue
    const pts = []
    for (let s = 0; s < sides; s++) {
      const ang = (s / sides) * Math.PI * 2 + roll + i * 0.05
      const p = cam.project({ x: Math.cos(ang) * radius, y: Math.sin(ang) * radius, z }, W, H)
      if (!p) { pts.length = 0; break }
      pts.push(p)
    }
    if (pts.length < 3) continue
    ctx.save()
    ctx.globalAlpha = a * 0.55
    ctx.strokeStyle = color
    ctx.lineWidth = Math.max(0.5, 2.4 * a)
    ctx.beginPath()
    ctx.moveTo(pts[0].x, pts[0].y)
    for (let k = 1; k < pts.length; k++) ctx.lineTo(pts[k].x, pts[k].y)
    ctx.closePath()
    ctx.stroke()
    ctx.restore()
  }
}

/** Ground plane with lines running to the horizon. */
export function drawFloorGrid(ctx, cam, W, H, opts = {}) {
  const { y = 3.2, z0 = 0, depth = 44, step = 3, halfWidth = 16, color = '#3AF0C8' } = opts
  ctx.save()
  ctx.strokeStyle = color
  ctx.lineWidth = 1

  for (let x = -halfWidth; x <= halfWidth; x += step) {
    const a = cam.project({ x, y, z: z0 + 1.2 }, W, H)
    const b = cam.project({ x, y, z: z0 + depth }, W, H)
    if (!a || !b) continue
    ctx.globalAlpha = 0.18
    ctx.beginPath()
    ctx.moveTo(a.x, a.y)
    ctx.lineTo(b.x, b.y)
    ctx.stroke()
  }
  for (let z = z0 + 2; z < z0 + depth; z += step) {
    const a = cam.project({ x: -halfWidth, y, z }, W, H)
    const b = cam.project({ x: halfWidth, y, z }, W, H)
    if (!a || !b) continue
    ctx.globalAlpha = 0.10 + fogAlpha(z - z0, 4, depth) * 0.22
    ctx.beginPath()
    ctx.moveTo(a.x, a.y)
    ctx.lineTo(b.x, b.y)
    ctx.stroke()
  }
  ctx.restore()
}

/** Shadow blob on the floor, so 3D characters do not look pasted on. */
export function drawGroundShadow(ctx, cam, W, H, x, z, size, floorY = 3.2) {
  const p = cam.project({ x, y: floorY, z }, W, H)
  if (!p) return
  ctx.save()
  ctx.globalAlpha = 0.32 * fogAlpha(p.z, 8, 36)
  ctx.fillStyle = '#000'
  ctx.beginPath()
  ctx.ellipse(p.x, p.y, size * p.s * 0.5, size * p.s * 0.18, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

/** Sorts anything with a `z` so far things draw first. */
export function byDepth(a, b) {
  return b.z - a.z
}
