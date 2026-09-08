// Shared look-and-feel layer.
//
// Every game previously lit its shapes with ctx.shadowBlur, which is convenient
// but re-blurs on every single draw call — with four glowing characters on
// screen that alone can halve the frame rate. Drawing the glowing pass once
// into a half-resolution buffer, blurring it once, and adding it back is both
// faster and a much better looking bloom.

export function createBloom(scale = 0.5) {
  let buf = null
  let bctx = null

  return {
    /** Returns a context to draw the glowing pass into, already cleared. */
    layer(W, H) {
      const w = Math.max(1, Math.round(W * scale))
      const h = Math.max(1, Math.round(H * scale))
      if (!buf) buf = document.createElement('canvas')
      if (buf.width !== w || buf.height !== h) {
        buf.width = w
        buf.height = h
      }
      bctx = buf.getContext('2d')
      bctx.setTransform(scale, 0, 0, scale, 0, 0)
      bctx.clearRect(0, 0, W, H)
      return bctx
    },

    /** Adds the blurred glow back over the scene. */
    composite(ctx, W, H, { blur = 12, alpha = 0.9, passes = 2 } = {}) {
      if (!buf) return
      ctx.save()
      ctx.globalCompositeOperation = 'lighter'
      const canFilter = typeof ctx.filter === 'string'
      for (let i = 0; i < passes; i++) {
        ctx.globalAlpha = alpha / (i + 1)
        if (canFilter) ctx.filter = `blur(${blur * (i + 1)}px)`
        ctx.drawImage(buf, 0, 0, W, H)
      }
      ctx.restore()
      if (typeof ctx.filter === 'string') ctx.filter = 'none'
    },
  }
}

/**
 * Paints the camera feed behind the game, cropped to fill.
 *
 * Showing people themselves is what made Kinect legible — without it players
 * have no idea where they are in frame, and step out of shot without knowing
 * why tracking stopped.
 */
export function drawCameraBackdrop(ctx, video, W, H, opts = {}) {
  const {
    mirror = true,
    alpha = 0.30,
    grade = 'grayscale(0.75) brightness(0.55) contrast(1.15)',
  } = opts
  if (!video || video.readyState < 2 || !video.videoWidth) return false

  const vw = video.videoWidth
  const vh = video.videoHeight
  const scale = Math.max(W / vw, H / vh)
  const dw = vw * scale
  const dh = vh * scale

  ctx.save()
  ctx.globalAlpha = alpha
  if (typeof ctx.filter === 'string' && grade) ctx.filter = grade
  if (mirror) {
    ctx.translate(W, 0)
    ctx.scale(-1, 1)
  }
  try {
    ctx.drawImage(video, (W - dw) / 2, (H - dh) / 2, dw, dh)
  } catch {
    // Safari can throw briefly while the stream is still settling.
  }
  ctx.restore()
  if (typeof ctx.filter === 'string') ctx.filter = 'none'
  return true
}

export function drawVignette(ctx, W, H, strength = 0.55) {
  const g = ctx.createRadialGradient(
    W / 2, H / 2, Math.min(W, H) * 0.28,
    W / 2, H / 2, Math.max(W, H) * 0.78
  )
  g.addColorStop(0, 'rgba(0,0,0,0)')
  g.addColorStop(1, `rgba(0,0,0,${strength})`)
  ctx.fillStyle = g
  ctx.fillRect(0, 0, W, H)
}

/** A colour wash that ties the camera feed and the game art together. */
export function drawColorGrade(ctx, W, H, color, alpha = 0.14) {
  ctx.save()
  ctx.globalCompositeOperation = 'overlay'
  ctx.globalAlpha = alpha
  ctx.fillStyle = color
  ctx.fillRect(0, 0, W, H)
  ctx.restore()
}

/**
 * Frame edge that turns red when the player drifts out of shot, so people
 * self-correct instead of wondering why nothing is responding.
 */
export function drawFrameGuide(ctx, W, H, ok, pulse = 0) {
  const col = ok ? 'rgba(0,229,176,0.18)' : `rgba(255,77,141,${0.30 + pulse * 0.25})`
  ctx.save()
  ctx.strokeStyle = col
  ctx.lineWidth = ok ? 2 : 4
  const m = 12
  const c = 42
  const corners = [
    [m, m, 1, 1], [W - m, m, -1, 1], [m, H - m, 1, -1], [W - m, H - m, -1, -1],
  ]
  for (const [x, y, sx, sy] of corners) {
    ctx.beginPath()
    ctx.moveTo(x + sx * c, y)
    ctx.lineTo(x, y)
    ctx.lineTo(x, y + sy * c)
    ctx.stroke()
  }
  ctx.restore()
}

/** Screen shake helper: returns the offset to translate by, and decays itself. */
export function shakeOffset(state, dt, decay = 3.2) {
  if (!state.amount || state.amount <= 0) return { x: 0, y: 0 }
  state.amount = Math.max(0, state.amount - dt * decay)
  const m = state.amount * (state.magnitude || 14)
  return { x: (Math.random() - 0.5) * m, y: (Math.random() - 0.5) * m }
}
