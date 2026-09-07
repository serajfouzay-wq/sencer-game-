import { useEffect } from 'react'

/** Keeps a canvas matched to its parent box and crisp on high-DPI screens. */
export function useCanvasSize(canvasRef) {
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const parent = canvas.parentElement
    const fit = () => {
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const w = parent.clientWidth
      const h = parent.clientHeight
      if (!w || !h) return
      canvas.width = Math.floor(w * dpr)
      canvas.height = Math.floor(h * dpr)
      canvas.style.width = w + 'px'
      canvas.style.height = h + 'px'
      canvas.getContext('2d').setTransform(dpr, 0, 0, dpr, 0, 0)
    }
    fit()
    const ro = new ResizeObserver(fit)
    ro.observe(parent)
    return () => ro.disconnect()
  }, [canvasRef])
}

/** Logical (CSS pixel) size of a canvas that useCanvasSize is managing. */
export function logicalSize(canvas) {
  const dpr = Math.min(window.devicePixelRatio || 1, 2)
  return { W: canvas.width / dpr, H: canvas.height / dpr }
}

export function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath()
  ctx.moveTo(x + r, y)
  ctx.arcTo(x + w, y, x + w, y + h, r)
  ctx.arcTo(x + w, y + h, x, y + h, r)
  ctx.arcTo(x, y + h, x, y, r)
  ctx.arcTo(x, y, x + w, y, r)
  ctx.closePath()
}

/** Red through amber to green, for match-quality feedback. */
export function scoreColor(s) {
  const hue = Math.round(s * 130) // 0 = red, 130 = green
  return `hsl(${hue} 85% 55%)`
}

/**
 * A stylised .44 revolver drawn from the grip outward.
 * `lift` runs 0 (holstered, muzzle down) to 1 (levelled and ready).
 */
export function drawRevolver(ctx, x, y, scale, lift, facing, cocked) {
  const s = scale
  ctx.save()
  ctx.translate(x, y)
  ctx.scale(facing, 1)
  // Holstered points down; fully drawn points level.
  ctx.rotate((1 - lift) * 1.15)

  const steel = ctx.createLinearGradient(0, -8 * s, 0, 8 * s)
  steel.addColorStop(0, '#D8DCE6')
  steel.addColorStop(0.45, '#8E94A6')
  steel.addColorStop(0.55, '#5A5F70')
  steel.addColorStop(1, '#2E313D')

  const wood = ctx.createLinearGradient(0, 0, 0, 20 * s)
  wood.addColorStop(0, '#7A4A2B')
  wood.addColorStop(1, '#43261492')

  // Grip
  ctx.fillStyle = wood
  ctx.beginPath()
  ctx.moveTo(-1 * s, 2 * s)
  ctx.lineTo(6 * s, 2 * s)
  ctx.lineTo(4 * s, 20 * s)
  ctx.lineTo(-4 * s, 19 * s)
  ctx.closePath()
  ctx.fill()

  // Frame + barrel
  ctx.fillStyle = steel
  roundRect(ctx, -3 * s, -6 * s, 15 * s, 9 * s, 2 * s)
  ctx.fill()
  roundRect(ctx, 10 * s, -4.5 * s, 22 * s, 5 * s, 1.5 * s)
  ctx.fill()

  // Cylinder
  ctx.beginPath()
  ctx.arc(6 * s, -1 * s, 5 * s, 0, Math.PI * 2)
  ctx.fill()
  ctx.strokeStyle = 'rgba(20,22,30,0.85)'
  ctx.lineWidth = 1 * s
  ctx.stroke()
  ctx.fillStyle = 'rgba(20,22,30,0.7)'
  for (let i = 0; i < 6; i++) {
    const a = (i / 6) * Math.PI * 2
    ctx.beginPath()
    ctx.arc(6 * s + Math.cos(a) * 2.6 * s, -1 * s + Math.sin(a) * 2.6 * s, 0.9 * s, 0, Math.PI * 2)
    ctx.fill()
  }

  // Hammer — snaps back when cocked
  ctx.fillStyle = '#3C404E'
  ctx.beginPath()
  ctx.moveTo(-2 * s, -5 * s)
  ctx.lineTo(cocked ? -6 * s : -3.5 * s, cocked ? -10 * s : -9 * s)
  ctx.lineTo(cocked ? -3 * s : -0.5 * s, cocked ? -9 * s : -8.5 * s)
  ctx.closePath()
  ctx.fill()

  // Trigger guard
  ctx.strokeStyle = '#6A7080'
  ctx.lineWidth = 1.6 * s
  ctx.beginPath()
  ctx.arc(3.5 * s, 5 * s, 3.4 * s, Math.PI * 0.9, Math.PI * 2.15)
  ctx.stroke()

  ctx.restore()
}

/** Muzzle flash burst, fading with `life` (1 → 0). */
export function drawMuzzleFlash(ctx, x, y, dir, life, scale = 1) {
  if (life <= 0) return
  const r = (26 + (1 - life) * 46) * scale
  ctx.save()
  ctx.translate(x, y)
  ctx.rotate(Math.atan2(dir.y, dir.x))
  ctx.globalAlpha = life
  const g = ctx.createRadialGradient(0, 0, 1, 0, 0, r)
  g.addColorStop(0, '#FFFFFF')
  g.addColorStop(0.3, '#FFD36E')
  g.addColorStop(0.65, '#FF8A2B')
  g.addColorStop(1, 'rgba(255,120,0,0)')
  ctx.fillStyle = g
  ctx.beginPath()
  ctx.ellipse(r * 0.45, 0, r, r * 0.55, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}
