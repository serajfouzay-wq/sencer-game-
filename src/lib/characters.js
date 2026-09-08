// Draws a proper character from pose landmarks instead of a stick figure.
// Limbs are tapered capsules, the torso is a filled shell, and the head carries
// a visor — the same rig serves the player, the hologram target and the crowd.

function len(a, b) {
  return Math.hypot(b.x - a.x, b.y - a.y)
}

/** A tapered capsule from a to b, wide at a and narrow at b. */
export function limb(ctx, a, b, wa, wb, fill) {
  const dx = b.x - a.x
  const dy = b.y - a.y
  const d = Math.hypot(dx, dy) || 1
  const nx = -dy / d
  const ny = dx / d
  ctx.beginPath()
  ctx.moveTo(a.x + nx * wa, a.y + ny * wa)
  ctx.lineTo(b.x + nx * wb, b.y + ny * wb)
  ctx.arc(b.x, b.y, wb, Math.atan2(ny, nx), Math.atan2(-ny, -nx), false)
  ctx.lineTo(a.x - nx * wa, a.y - ny * wa)
  ctx.arc(a.x, a.y, wa, Math.atan2(-ny, -nx), Math.atan2(ny, nx), false)
  ctx.closePath()
  ctx.fillStyle = fill
  ctx.fill()
}

/**
 * pts: { [landmarkIndex]: {x, y} } in screen pixels. Needs 0, 11, 12, 13, 14,
 * 15, 16, 23, 24, 25, 26, 27, 28.
 * limbColor(a, b) may return a per-bone colour for match feedback.
 */
export function drawCharacter(ctx, pts, opts = {}) {
  const {
    color = '#00E5B0',
    accent = '#FFFFFF',
    alpha = 1,
    hologram = false,
    limbColor = null,
    glow = 18,
    face = true,
  } = opts

  const P = (i) => pts[i]
  const has = (...ids) => ids.every((i) => pts[i])
  if (!has(11, 12, 23, 24)) return

  const shoulderW = len(P(11), P(12)) || 40
  const unit = Math.max(6, shoulderW * 0.5)

  ctx.save()
  ctx.globalAlpha = alpha
  ctx.lineJoin = 'round'
  ctx.lineCap = 'round'
  if (glow) {
    ctx.shadowColor = color
    ctx.shadowBlur = glow
  }

  const shade = hologram ? withAlpha(color, 0.30) : color
  const bone = (a, b, wa, wb) => {
    const c = limbColor ? limbColor(a, b) : null
    limb(ctx, P(a), P(b), wa, wb, c || shade)
  }

  const hipMid = { x: (P(23).x + P(24).x) / 2, y: (P(23).y + P(24).y) / 2 }
  const shMid = { x: (P(11).x + P(12).x) / 2, y: (P(11).y + P(12).y) / 2 }

  // Legs first so the torso overlaps them at the hip.
  if (has(24, 26, 28)) { bone(24, 26, unit * 0.40, unit * 0.30); bone(26, 28, unit * 0.30, unit * 0.20) }
  if (has(23, 25, 27)) { bone(23, 25, unit * 0.40, unit * 0.30); bone(25, 27, unit * 0.30, unit * 0.20) }
  if (has(28)) foot(ctx, P(26) || P(28), P(28), unit * 0.26, shade)
  if (has(27)) foot(ctx, P(25) || P(27), P(27), unit * 0.26, shade)

  // Torso shell
  ctx.beginPath()
  const spread = unit * 0.16
  ctx.moveTo(P(12).x, P(12).y - spread)
  ctx.lineTo(P(11).x, P(11).y - spread)
  ctx.quadraticCurveTo(P(11).x + (P(23).x - P(11).x) * 0.5 + spread, (P(11).y + P(23).y) / 2, P(23).x, P(23).y)
  ctx.lineTo(P(24).x, P(24).y)
  ctx.quadraticCurveTo(P(12).x + (P(24).x - P(12).x) * 0.5 - spread, (P(12).y + P(24).y) / 2, P(12).x, P(12).y - spread)
  ctx.closePath()
  const torso = ctx.createLinearGradient(shMid.x, shMid.y, hipMid.x, hipMid.y)
  torso.addColorStop(0, hologram ? withAlpha(color, 0.34) : lighten(color, 0.18))
  torso.addColorStop(1, hologram ? withAlpha(color, 0.16) : darken(color, 0.28))
  ctx.fillStyle = torso
  ctx.fill()

  // Chest emblem
  ctx.globalAlpha = alpha * (hologram ? 0.5 : 0.85)
  ctx.fillStyle = accent
  ctx.beginPath()
  ctx.arc(shMid.x + (hipMid.x - shMid.x) * 0.32, shMid.y + (hipMid.y - shMid.y) * 0.32, unit * 0.16, 0, Math.PI * 2)
  ctx.fill()
  ctx.globalAlpha = alpha

  // Arms over the torso
  if (has(12, 14, 16)) { bone(12, 14, unit * 0.32, unit * 0.24); bone(14, 16, unit * 0.24, unit * 0.16) }
  if (has(11, 13, 15)) { bone(11, 13, unit * 0.32, unit * 0.24); bone(13, 15, unit * 0.24, unit * 0.16) }
  if (has(16)) hand(ctx, P(16), unit * 0.20, shade)
  if (has(15)) hand(ctx, P(15), unit * 0.20, shade)

  // Neck + head
  const headR = Math.max(10, shoulderW * 0.40)
  const head = P(0) || { x: shMid.x, y: shMid.y - headR * 1.5 }
  limb(ctx, shMid, { x: head.x, y: head.y + headR * 0.7 }, unit * 0.22, unit * 0.18, shade)

  const hg = ctx.createRadialGradient(head.x - headR * 0.3, head.y - headR * 0.35, headR * 0.15, head.x, head.y, headR)
  hg.addColorStop(0, hologram ? withAlpha(color, 0.55) : lighten(color, 0.3))
  hg.addColorStop(1, hologram ? withAlpha(color, 0.22) : darken(color, 0.2))
  ctx.fillStyle = hg
  ctx.beginPath()
  ctx.arc(head.x, head.y, headR, 0, Math.PI * 2)
  ctx.fill()

  if (face) {
    // A visor reads as a character at any size and never lands in uncanny valley.
    ctx.shadowBlur = 0
    ctx.globalAlpha = alpha * (hologram ? 0.55 : 0.95)
    ctx.fillStyle = hologram ? withAlpha(accent, 0.5) : '#0A0A12'
    ctx.beginPath()
    ctx.ellipse(head.x, head.y - headR * 0.06, headR * 0.66, headR * 0.34, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = accent
    ctx.globalAlpha = alpha
    ctx.beginPath()
    ctx.ellipse(head.x - headR * 0.3, head.y - headR * 0.08, headR * 0.14, headR * 0.14, 0, 0, Math.PI * 2)
    ctx.ellipse(head.x + headR * 0.3, head.y - headR * 0.08, headR * 0.14, headR * 0.14, 0, 0, Math.PI * 2)
    ctx.fill()
  }

  if (hologram) {
    // Scanlines sell the "projection" without hiding the shape.
    ctx.save()
    ctx.globalAlpha = alpha * 0.16
    ctx.strokeStyle = accent
    ctx.lineWidth = 1
    const top = head.y - headR * 1.4
    const bottom = Math.max(P(27) ? P(27).y : hipMid.y, P(28) ? P(28).y : hipMid.y) + 20
    for (let y = top; y < bottom; y += 7) {
      ctx.beginPath()
      ctx.moveTo(head.x - shoulderW * 1.8, y)
      ctx.lineTo(head.x + shoulderW * 1.8, y)
      ctx.stroke()
    }
    ctx.restore()
  }

  ctx.restore()
}

function hand(ctx, p, r, fill) {
  ctx.beginPath()
  ctx.arc(p.x, p.y, r, 0, Math.PI * 2)
  ctx.fillStyle = fill
  ctx.fill()
}

function foot(ctx, knee, ankle, r, fill) {
  const dx = ankle.x - knee.x
  const dy = ankle.y - knee.y
  const d = Math.hypot(dx, dy) || 1
  ctx.save()
  ctx.translate(ankle.x, ankle.y)
  ctx.rotate(Math.atan2(dy, dx) - Math.PI / 2)
  ctx.fillStyle = fill
  ctx.beginPath()
  ctx.ellipse(0, r * 0.3, r * 1.25, r * 0.62, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

/* ------------------------------ colour utils ------------------------------ */

function parse(hex) {
  const h = hex.replace('#', '')
  const n = parseInt(h.length === 3 ? h.split('').map((c) => c + c).join('') : h, 16)
  return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 }
}
export function withAlpha(hex, a) {
  const { r, g, b } = parse(hex)
  return `rgba(${r},${g},${b},${a})`
}
export function lighten(hex, amt) {
  const { r, g, b } = parse(hex)
  const f = (v) => Math.round(v + (255 - v) * amt)
  return `rgb(${f(r)},${f(g)},${f(b)})`
}
export function darken(hex, amt) {
  const { r, g, b } = parse(hex)
  const f = (v) => Math.round(v * (1 - amt))
  return `rgb(${f(r)},${f(g)},${f(b)})`
}

/* ------------------------------- the cowboy ------------------------------- */

/**
 * A gunslinger for the duel. `raise` is 0 (holstered) to 1 (levelled).
 * Idle sway keeps him alive between rounds.
 */
export function drawGunslinger(ctx, x, groundY, scale, opts = {}) {
  const { color = '#FFB000', raise = 0, facing = 1, cocked = false, defeated = false, t = 0 } = opts
  const s = scale
  const sway = defeated ? 0 : Math.sin(t * 0.0016) * 2.2
  const slump = defeated ? 1 : 0

  ctx.save()
  ctx.translate(x, groundY + slump * 14 * s)
  ctx.scale(facing, 1)

  // Long shadow toward the sun
  ctx.save()
  ctx.globalAlpha = 0.35
  ctx.fillStyle = '#120A10'
  ctx.beginPath()
  ctx.ellipse(0, 2 * s, 26 * s, 6 * s, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()

  ctx.globalAlpha = defeated ? 0.55 : 1
  const coat = darken(color, 0.55)
  const trim = color

  // Legs
  limb(ctx, { x: -5 * s, y: -34 * s }, { x: -8 * s, y: 0 }, 5 * s, 3.6 * s, coat)
  limb(ctx, { x: 5 * s, y: -34 * s }, { x: 9 * s, y: 0 }, 5 * s, 3.6 * s, coat)
  ctx.fillStyle = darken(color, 0.7)
  ctx.beginPath()
  ctx.ellipse(-9 * s, 0, 7 * s, 2.6 * s, 0, 0, Math.PI * 2)
  ctx.ellipse(10 * s, 0, 7 * s, 2.6 * s, 0, 0, Math.PI * 2)
  ctx.fill()

  // Poncho / torso
  const g = ctx.createLinearGradient(0, -60 * s, 0, -28 * s)
  g.addColorStop(0, lighten(color, 0.1))
  g.addColorStop(1, darken(color, 0.45))
  ctx.fillStyle = g
  ctx.beginPath()
  ctx.moveTo(-11 * s, -60 * s + sway * 0.3)
  ctx.lineTo(11 * s, -60 * s + sway * 0.3)
  ctx.lineTo(15 * s, -28 * s)
  ctx.lineTo(-15 * s, -28 * s)
  ctx.closePath()
  ctx.fill()
  ctx.fillStyle = withAlpha(trim, 0.65)
  ctx.fillRect(-15 * s, -32 * s, 30 * s, 2.4 * s)

  // Gun arm swings up as the player draws
  const shoulder = { x: 10 * s, y: -55 * s + sway * 0.3 }
  const ang = -0.15 - raise * 1.25
  const elbow = { x: shoulder.x + Math.cos(ang) * 13 * s, y: shoulder.y + 13 * s - raise * 5 * s }
  const wrist = { x: elbow.x + 15 * s, y: elbow.y - raise * 16 * s + (1 - raise) * 8 * s }
  limb(ctx, shoulder, elbow, 4.6 * s, 3.8 * s, darken(color, 0.35))
  limb(ctx, elbow, wrist, 3.8 * s, 3 * s, darken(color, 0.35))

  // Off arm
  const sh2 = { x: -10 * s, y: -55 * s + sway * 0.3 }
  limb(ctx, sh2, { x: -14 * s, y: -40 * s }, 4.6 * s, 3.6 * s, darken(color, 0.4))
  limb(ctx, { x: -14 * s, y: -40 * s }, { x: -13 * s, y: -30 * s }, 3.6 * s, 2.8 * s, darken(color, 0.4))

  // Head + hat
  const hy = -68 * s + sway * 0.4
  ctx.fillStyle = lighten(color, 0.35)
  ctx.beginPath()
  ctx.arc(0, hy, 7.5 * s, 0, Math.PI * 2)
  ctx.fill()
  ctx.fillStyle = '#1A1118'
  ctx.beginPath()
  ctx.ellipse(1.5 * s, hy - 0.5 * s, 5.2 * s, 2.2 * s, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.fillStyle = darken(color, 0.6)
  ctx.beginPath()
  ctx.ellipse(0, hy - 5.5 * s, 17 * s, 3.2 * s, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.moveTo(-8 * s, hy - 6 * s)
  ctx.quadraticCurveTo(0, hy - 20 * s, 8 * s, hy - 6 * s)
  ctx.closePath()
  ctx.fill()
  ctx.fillStyle = withAlpha(trim, 0.7)
  ctx.fillRect(-8 * s, hy - 8 * s, 16 * s, 1.8 * s)

  ctx.restore()
  return { x: x + facing * (wristX(raise, s)), y: groundY + wristY(raise, s), cocked }
}

const wristX = (raise, s) => (10 + Math.cos(-0.15 - raise * 1.25) * 13 + 15) * s
const wristY = (raise, s) => -55 * s + 13 * s - raise * 5 * s - raise * 16 * s + (1 - raise) * 8 * s

/* -------------------------------- the ship -------------------------------- */

export function drawShip(ctx, x, y, s, color, t, dead = false) {
  ctx.save()
  ctx.translate(x, y)
  if (dead) ctx.globalAlpha = 0.25

  // Thruster plume
  if (!dead) {
    const flick = 1 + Math.sin(t * 0.05) * 0.3
    const fl = ctx.createLinearGradient(-10 * s, 0, -34 * s * flick, 0)
    fl.addColorStop(0, '#FFF6D0')
    fl.addColorStop(0.35, color)
    fl.addColorStop(1, withAlpha(color, 0))
    ctx.fillStyle = fl
    ctx.beginPath()
    ctx.moveTo(-9 * s, -5 * s)
    ctx.lineTo(-34 * s * flick, 0)
    ctx.lineTo(-9 * s, 5 * s)
    ctx.closePath()
    ctx.fill()
  }

  ctx.shadowColor = color
  ctx.shadowBlur = 18

  // Fins
  ctx.fillStyle = darken(color, 0.45)
  ctx.beginPath()
  ctx.moveTo(-6 * s, -4 * s); ctx.lineTo(-16 * s, -13 * s); ctx.lineTo(-4 * s, -3 * s)
  ctx.closePath(); ctx.fill()
  ctx.beginPath()
  ctx.moveTo(-6 * s, 4 * s); ctx.lineTo(-16 * s, 13 * s); ctx.lineTo(-4 * s, 3 * s)
  ctx.closePath(); ctx.fill()

  // Hull
  const hull = ctx.createLinearGradient(0, -8 * s, 0, 8 * s)
  hull.addColorStop(0, lighten(color, 0.45))
  hull.addColorStop(0.5, color)
  hull.addColorStop(1, darken(color, 0.4))
  ctx.fillStyle = hull
  ctx.beginPath()
  ctx.moveTo(22 * s, 0)
  ctx.quadraticCurveTo(6 * s, -8 * s, -10 * s, -6 * s)
  ctx.lineTo(-10 * s, 6 * s)
  ctx.quadraticCurveTo(6 * s, 8 * s, 22 * s, 0)
  ctx.closePath()
  ctx.fill()

  // Cockpit
  ctx.shadowBlur = 0
  ctx.fillStyle = 'rgba(180,240,255,0.9)'
  ctx.beginPath()
  ctx.ellipse(7 * s, -1 * s, 5 * s, 3 * s, -0.15, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}
