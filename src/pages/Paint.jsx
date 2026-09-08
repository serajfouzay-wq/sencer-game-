import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings } from '../lib/storage.js'
import { HAND_CONNECTIONS, isPointing, palmCenter, handSpan } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, roundRect } from '../lib/canvas.js'
import { sfx, playMusic } from '../lib/audio.js'
import { Loading, ErrorScreen } from '../components/ui.jsx'

const INKS = [
  '#00E5B0', '#7C5CFF', '#FF7A45', '#FFB000',
  '#00D4FF', '#FF4D8D', '#B6FF3C', '#FFFFFF',
]
const PAPERS = [
  { name: 'Ink', color: '#0A0A12' },
  { name: 'Slate', color: '#232838' },
  { name: 'Bone', color: '#EFE9DC' },
  { name: 'Blueprint', color: '#0E2A4A' },
]
const SIZES = [6, 14, 26]
const HOVER_MS = 600

export default function Paint() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const inkRef = useRef(null)          // offscreen canvas holding the artwork
  const [paper, setPaper] = useState(0)
  const [hands, setHands] = useState(0)

  const g = useRef({
    tracker: createTracker({ maxDist: 0.25, maxAge: 500 }),
    pens: new Map(),   // track id -> { color, size, last, hoverKey, hoverSince }
    buttons: [],
    paper: 0,
    clearFlash: 0,
    lastTime: 0,
  }).current

  function clearArt() {
    const ink = inkRef.current
    if (ink) ink.getContext('2d').clearRect(0, 0, ink.width, ink.height)
    g.clearFlash = 1
    sfx.clear()
  }

  function download() {
    const src = inkRef.current
    if (!src) return
    const out = document.createElement('canvas')
    out.width = src.width
    out.height = src.height
    const c = out.getContext('2d')
    c.fillStyle = PAPERS[g.paper].color
    c.fillRect(0, 0, out.width, out.height)
    c.drawImage(src, 0, 0)
    const a = document.createElement('a')
    a.download = 'air-canvas.png'
    a.href = out.toDataURL('image/png')
    a.click()
  }

  useEffect(() => { g.paper = paper }, [paper, g])
  useEffect(() => { if (status === 'ready') playMusic('chill') }, [status])

  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    function frame(now) {
      raf = requestAnimationFrame(frame)
      const { W, H } = logicalSize(canvas)
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.05) : 0
      g.lastTime = now

      // The artwork lives on its own canvas so strokes persist between frames.
      if (!inkRef.current || inkRef.current.width !== Math.round(W) || inkRef.current.height !== Math.round(H)) {
        const prev = inkRef.current
        const next = document.createElement('canvas')
        next.width = Math.round(W)
        next.height = Math.round(H)
        if (prev) next.getContext('2d').drawImage(prev, 0, 0)
        inkRef.current = next
      }
      const ink = inkRef.current.getContext('2d')

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      layoutButtons(W, H)

      for (const t of tracks) {
        if (!t.data) continue
        let pen = g.pens.get(t.id)
        if (!pen) {
          pen = {
            color: INKS[(g.pens.size * 3) % INKS.length],
            size: SIZES[1],
            last: null,
            hoverKey: null,
            hoverSince: 0,
          }
          g.pens.set(t.id, pen)
        }
        const lm = t.data
        const tip = lm[8]
        const x = (settings.mirror ? 1 - tip.x : tip.x) * W
        const y = tip.y * H
        const drawing = isPointing(lm)

        const btn = hitButton(x, y)
        if (btn && !drawing) {
          if (pen.hoverKey !== btn.key) {
            pen.hoverKey = btn.key
            pen.hoverSince = now
          } else if (now - pen.hoverSince > HOVER_MS) {
            applyButton(btn, pen)
            pen.hoverSince = now + 100000 // one action per dwell
          }
          pen.last = null
        } else {
          pen.hoverKey = null
        }

        if (drawing && !pen.last && !btn) sfx.penDown()
        if (drawing && !btn) {
          // Stroke width tracks how close the hand is, so leaning in draws bolder.
          const scale = Math.max(0.6, Math.min(1.8, handSpan(lm) / 0.12))
          const w = pen.size * scale
          if (pen.last) {
            ink.strokeStyle = pen.color
            ink.lineWidth = w
            ink.lineCap = 'round'
            ink.lineJoin = 'round'
            ink.beginPath()
            ink.moveTo(pen.last.x, pen.last.y)
            ink.lineTo(x, y)
            ink.stroke()
          }
          pen.last = { x, y }
        } else if (!drawing) {
          pen.last = null
        }

        t.screen = { x, y, drawing, pen }
      }

      // Forget pens whose hand is long gone.
      const liveIds = new Set(tracks.map((t) => t.id))
      for (const id of [...g.pens.keys()]) if (!liveIds.has(id)) g.pens.delete(id)

      render(ctx, W, H, now, dt, tracks)
      if (tracks.length !== hands) setHands(tracks.length)
    }

    /* ------------------------------- UI strip ------------------------------ */

    function layoutButtons(W, H) {
      const b = []
      const sw = 34
      const gap = 8
      const totalInk = INKS.length * (sw + gap) - gap
      let x = W / 2 - totalInk / 2
      const y = H - 62
      for (const c of INKS) {
        b.push({ key: 'ink:' + c, kind: 'ink', color: c, x, y, w: sw, h: sw })
        x += sw + gap
      }
      let sx = 20
      for (const s of SIZES) {
        b.push({ key: 'size:' + s, kind: 'size', size: s, x: sx, y, w: sw, h: sw })
        sx += sw + gap
      }
      let px = W - 20 - (PAPERS.length * (sw + gap) - gap)
      for (let i = 0; i < PAPERS.length; i++) {
        b.push({ key: 'paper:' + i, kind: 'paper', index: i, x: px, y, w: sw, h: sw })
        px += sw + gap
      }
      b.push({ key: 'clear', kind: 'clear', x: W / 2 - 44, y: H - 108, w: 88, h: 32 })
      g.buttons = b
    }

    function hitButton(x, y) {
      for (const b of g.buttons) {
        if (x >= b.x - 6 && x <= b.x + b.w + 6 && y >= b.y - 6 && y <= b.y + b.h + 6) return b
      }
      return null
    }

    function applyButton(b, pen) {
      sfx.pick()
      if (b.kind === 'ink') pen.color = b.color
      else if (b.kind === 'size') pen.size = b.size
      else if (b.kind === 'paper') setPaper(b.index)
      else if (b.kind === 'clear') clearArt()
    }

    /* ------------------------------ rendering ------------------------------ */

    function render(ctx, W, H, now, dt, tracks) {
      ctx.fillStyle = PAPERS[g.paper].color
      ctx.fillRect(0, 0, W, H)
      const light = PAPERS[g.paper].color === '#EFE9DC'

      ctx.drawImage(inkRef.current, 0, 0)

      if (g.clearFlash > 0) {
        g.clearFlash = Math.max(0, g.clearFlash - dt * 2)
        ctx.fillStyle = `rgba(255,255,255,${g.clearFlash * 0.25})`
        ctx.fillRect(0, 0, W, H)
      }

      // Faint skeletons so people can see the tracking working
      if (settings.showSkeleton) {
        for (const t of tracks) {
          if (!t.data) continue
          const lm = t.data
          const pt = (k) => ({
            x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
            y: lm[k].y * H,
          })
          ctx.save()
          ctx.globalAlpha = 0.22
          ctx.strokeStyle = light ? '#333' : '#fff'
          ctx.lineWidth = 2
          for (const [a, b] of HAND_CONNECTIONS) {
            const u = pt(a), v = pt(b)
            ctx.beginPath()
            ctx.moveTo(u.x, u.y)
            ctx.lineTo(v.x, v.y)
            ctx.stroke()
          }
          ctx.restore()
        }
      }

      drawToolbar(ctx, W, H, light)

      // Cursors on top of everything
      for (const t of tracks) {
        if (!t.screen) continue
        const { x, y, drawing, pen } = t.screen
        ctx.save()
        ctx.strokeStyle = pen.color
        ctx.lineWidth = drawing ? 4 : 2
        ctx.shadowColor = pen.color
        ctx.shadowBlur = drawing ? 20 : 8
        ctx.beginPath()
        ctx.arc(x, y, drawing ? pen.size * 0.7 + 6 : 16, 0, Math.PI * 2)
        ctx.stroke()
        if (drawing) {
          ctx.fillStyle = pen.color
          ctx.beginPath()
          ctx.arc(x, y, 3, 0, Math.PI * 2)
          ctx.fill()
        }
        ctx.restore()

        // Dwell progress on a tool
        if (pen.hoverKey) {
          const b = g.buttons.find((v) => v.key === pen.hoverKey)
          const p = Math.min(1, (now - pen.hoverSince) / HOVER_MS)
          if (b && p < 1) {
            ctx.save()
            ctx.strokeStyle = pen.color
            ctx.lineWidth = 3
            ctx.beginPath()
            ctx.arc(b.x + b.w / 2, b.y + b.h / 2, b.w * 0.78, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p)
            ctx.stroke()
            ctx.restore()
          }
        }
      }
    }

    function drawToolbar(ctx, W, H, light) {
      const fg = light ? '#1A1A22' : '#EAEAF2'
      ctx.save()
      ctx.fillStyle = light ? 'rgba(255,255,255,0.55)' : 'rgba(10,10,18,0.55)'
      roundRect(ctx, 8, H - 122, W - 16, 114, 18)
      ctx.fill()

      for (const b of g.buttons) {
        if (b.kind === 'ink') {
          ctx.fillStyle = b.color
          ctx.beginPath()
          ctx.arc(b.x + b.w / 2, b.y + b.h / 2, b.w / 2 - 2, 0, Math.PI * 2)
          ctx.fill()
        } else if (b.kind === 'size') {
          ctx.fillStyle = fg
          ctx.beginPath()
          ctx.arc(b.x + b.w / 2, b.y + b.h / 2, b.size / 2.4, 0, Math.PI * 2)
          ctx.fill()
        } else if (b.kind === 'paper') {
          ctx.fillStyle = PAPERS[b.index].color
          roundRect(ctx, b.x, b.y, b.w, b.h, 8)
          ctx.fill()
          ctx.strokeStyle = g.paper === b.index ? '#00E5B0' : 'rgba(128,128,140,0.5)'
          ctx.lineWidth = g.paper === b.index ? 3 : 1
          ctx.stroke()
        } else if (b.kind === 'clear') {
          ctx.strokeStyle = '#FF7A45'
          ctx.lineWidth = 1.5
          roundRect(ctx, b.x, b.y, b.w, b.h, 10)
          ctx.stroke()
          ctx.fillStyle = '#FF7A45'
          ctx.font = '600 13px Inter, system-ui, sans-serif'
          ctx.textAlign = 'center'
          ctx.fillText('clear all', b.x + b.w / 2, b.y + 21)
          ctx.textAlign = 'left'
        }
      }

      ctx.fillStyle = light ? 'rgba(0,0,0,0.45)' : 'rgba(255,255,255,0.4)'
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillText('brush', 20, H - 70)
      ctx.textAlign = 'right'
      ctx.fillText('background', W - 20, H - 70)
      ctx.textAlign = 'left'
      ctx.restore()
    }

    raf = requestAnimationFrame(frame)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  const loading = status === 'loading-model' || status === 'starting-camera'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {status === 'ready' && (
        <div className="absolute left-5 top-5 flex items-center gap-3">
          <span className="rounded-full bg-ink/60 px-3 py-1.5 text-xs text-fg backdrop-blur">
            {hands === 0 ? 'no hands yet' : hands === 1 ? '1 hand drawing' : `${hands} hands drawing`}
          </span>
          <button onClick={download} className="rounded-full bg-ink/60 px-3 py-1.5 text-xs text-fg backdrop-blur hover:bg-ink/80">
            Save PNG
          </button>
        </div>
      )}

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent="#FF7A45" label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />
      )}
    </div>
  )
}
