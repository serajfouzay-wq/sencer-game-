import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { HAND_CONNECTIONS, palmCenter, openness, isFist } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ROUND_SECONDS = 75
const ORB_COLORS = ['#00E5B0', '#7C5CFF', '#00D4FF', '#FF4D8D', '#FFB000']
const GRAB_RADIUS = 95
const FIELD_RADIUS = 200

export default function Kinetic() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', score: 0, banked: 0, timeLeft: ROUND_SECONDS, hands: 0 })

  const g = useRef({
    phase: 'menu',
    tracker: createTracker({ maxDist: 0.26, maxAge: 400 }),
    bloom: createBloom(0.5),
    orbs: [],
    dust: [],
    shocks: [],
    bursts: [],
    grips: new Map(),   // track id -> orb
    score: 0,
    banked: 0,
    timeLeft: ROUND_SECONDS,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    g.orbs = []
    g.dust = []
    g.shocks = []
    g.bursts = []
    g.grips.clear()
    g.score = 0
    g.banked = 0
    g.timeLeft = ROUND_SECONDS
    g.logged = false
    g.phase = 'playing'
    playMusic('space')
  }

  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    function frame(now) {
      raf = requestAnimationFrame(frame)
      const { W, H } = logicalSize(canvas)
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.04) : 0
      g.lastTime = now

      if (!g.dust.length) {
        for (let i = 0; i < 90; i++) {
          g.dust.push({ x: Math.random(), y: Math.random(), z: 0.2 + Math.random() * 0.8 })
        }
      }

      const goal = { x: W * 0.87, y: H * 0.5, r: Math.min(H * 0.15, 110) }

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      const hands = tracks
        .filter((t) => t.data)
        .map((t) => ({
          id: t.id,
          x: t.x * W,
          y: t.y * H,
          vx: t.vx * W,
          vy: t.vy * H,
          lm: t.data,
          open: openness(t.data),
          closed: isFist(t.data),
        }))

      if (g.phase === 'playing') {
        g.timeLeft -= dt
        if (g.timeLeft <= 0) {
          g.timeLeft = 0
          g.phase = 'over'
          if (!g.logged) {
            g.logged = true
            addSession({ game: 'kinetic', score: g.score, detail: `${g.banked} orbs banked` })
            stopMusic()
            sfx.win()
          }
        }
        spawnOrbs(W, H)
        applyHands(hands, dt, W, H)
        stepOrbs(dt, W, H, goal, now)
      }

      render(ctx, W, H, dt, now, hands, goal)
      syncUi(hands.length)
    }

    function spawnOrbs(W, H) {
      const want = 5 + Math.min(4, Math.floor(g.banked / 3))
      while (g.orbs.length < want) {
        g.orbs.push({
          x: W * (0.08 + Math.random() * 0.28),
          y: H * (0.15 + Math.random() * 0.7),
          vx: 0, vy: 0,
          r: 16 + Math.random() * 12,
          color: ORB_COLORS[(Math.random() * ORB_COLORS.length) | 0],
          held: null,
          trail: [],
          spin: Math.random() * Math.PI * 2,
        })
      }
    }

    function applyHands(hands, dt, W, H) {
      const liveIds = new Set(hands.map((h) => h.id))
      for (const [id, orb] of [...g.grips]) {
        if (!liveIds.has(id)) { orb.held = null; g.grips.delete(id) }
      }

      for (const h of hands) {
        const gripped = g.grips.get(h.id)

        if (h.closed) {
          if (!gripped) {
            // Grab the nearest free orb inside reach.
            let best = null, bestD = GRAB_RADIUS
            for (const o of g.orbs) {
              if (o.held) continue
              const d = Math.hypot(o.x - h.x, o.y - h.y)
              if (d < bestD) { bestD = d; best = o }
            }
            if (best) {
              best.held = h.id
              g.grips.set(h.id, best)
              g.shocks.push({ x: h.x, y: h.y, r: 10, max: 70, life: 1, color: '#FFFFFF' })
              sfx.grab()
            }
          } else {
            // Carry it, and remember the hand's motion for the throw.
            gripped.x += (h.x - gripped.x) * Math.min(1, dt * 18)
            gripped.y += (h.y - gripped.y) * Math.min(1, dt * 18)
            gripped.vx = h.vx
            gripped.vy = h.vy
          }
        } else {
          if (gripped) {
            // Let go: the orb keeps the hand's velocity.
            gripped.held = null
            gripped.vx = h.vx * 1.15
            gripped.vy = h.vy * 1.15
            g.grips.delete(h.id)
            g.shocks.push({ x: h.x, y: h.y, r: 12, max: 110, life: 1, color: '#00E5B0' })
            sfx.release()
          }
          // An open palm pushes everything nearby away.
          const power = h.open
          if (power > 0.25) {
            for (const o of g.orbs) {
              if (o.held) continue
              const dx = o.x - h.x
              const dy = o.y - h.y
              const d = Math.hypot(dx, dy)
              if (d < FIELD_RADIUS && d > 1) {
                const f = (1 - d / FIELD_RADIUS) * power * 2600
                o.vx += (dx / d) * f * dt
                o.vy += (dy / d) * f * dt
              }
            }
          }
        }
      }
    }

    function stepOrbs(dt, W, H, goal, now) {
      for (const o of g.orbs) {
        o.spin += dt * 1.5
        if (!o.held) {
          o.x += o.vx * dt
          o.y += o.vy * dt
          o.vx *= 0.985
          o.vy *= 0.985
          // The goal exerts a gentle pull once an orb drifts close.
          const dx = goal.x - o.x
          const dy = goal.y - o.y
          const d = Math.hypot(dx, dy)
          if (d < goal.r * 2.4 && d > 1) {
            const f = (1 - d / (goal.r * 2.4)) * 340
            o.vx += (dx / d) * f * dt
            o.vy += (dy / d) * f * dt
          }
          if (o.x < o.r) { o.x = o.r; o.vx = Math.abs(o.vx) * 0.55 }
          if (o.x > W - o.r) { o.x = W - o.r; o.vx = -Math.abs(o.vx) * 0.55 }
          if (o.y < o.r) { o.y = o.r; o.vy = Math.abs(o.vy) * 0.55 }
          if (o.y > H - o.r) { o.y = H - o.r; o.vy = -Math.abs(o.vy) * 0.55 }
        }
        o.trail.unshift({ x: o.x, y: o.y })
        if (o.trail.length > 14) o.trail.pop()
      }

      // Bank orbs that land in the ring.
      const scored = []
      for (const o of g.orbs) {
        if (o.held) continue
        if (Math.hypot(o.x - goal.x, o.y - goal.y) < goal.r * 0.72) {
          const speed = Math.hypot(o.vx, o.vy)
          const pts = 100 + Math.min(200, Math.round(speed / 6))
          g.score += pts
          g.banked += 1
          sfx.bank(g.banked)
          g.bursts.push({ x: o.x, y: o.y, color: o.color, life: 1, pts })
          g.shocks.push({ x: goal.x, y: goal.y, r: goal.r * 0.5, max: goal.r * 1.8, life: 1, color: o.color })
          for (let i = 0; i < 26; i++) {
            const a = Math.random() * Math.PI * 2
            const sp = 80 + Math.random() * 260
            g.bursts.push({ x: o.x, y: o.y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp, color: o.color, life: 1, particle: true })
          }
          scored.push(o)
        }
      }
      g.orbs = g.orbs.filter((o) => !scored.includes(o))

      for (const s of g.shocks) { s.r += (s.max - s.r) * dt * 6; s.life -= dt * 1.6 }
      g.shocks = g.shocks.filter((s) => s.life > 0)
      for (const b of g.bursts) {
        if (b.particle) { b.x += b.vx * dt; b.y += b.vy * dt; b.vx *= 0.94; b.vy *= 0.94 }
        b.life -= dt * (b.particle ? 1.3 : 0.9)
      }
      g.bursts = g.bursts.filter((b) => b.life > 0)
    }

    /* ------------------------------ rendering ------------------------------ */

    function render(ctx, W, H, dt, now, hands, goal) {
      const bg = ctx.createRadialGradient(W * 0.3, H * 0.4, 40, W * 0.3, H * 0.4, Math.max(W, H))
      bg.addColorStop(0, '#121033')
      bg.addColorStop(0.55, '#0A0820')
      bg.addColorStop(1, '#04030C')
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, W, H)

      for (const d of g.dust) {
        d.x += 0.006 * d.z * dt
        if (d.x > 1) d.x -= 1
        ctx.globalAlpha = 0.1 + d.z * 0.35
        ctx.fillStyle = '#9FB4FF'
        ctx.fillRect(d.x * W, d.y * H, 1.5 * d.z, 1.5 * d.z)
      }
      ctx.globalAlpha = 1

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.16,
          grade: 'grayscale(0.9) brightness(0.45) contrast(1.2)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      drawGoal(ctx, goal, now)
      if (bctx) drawGoal(bctx, goal, now)

      for (const s of g.shocks) {
        ctx.save()
        ctx.globalAlpha = Math.max(0, s.life) * 0.6
        ctx.strokeStyle = s.color
        ctx.lineWidth = 3
        ctx.beginPath()
        ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2)
        ctx.stroke()
        ctx.restore()
      }

      for (const o of g.orbs) { drawOrb(ctx, o, now); if (bctx) drawOrb(bctx, o, now) }
      for (const h of hands) { drawHand(ctx, h, W, H, now); if (bctx) drawHand(bctx, h, W, H, now) }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 13, alpha: 0.6 })
      drawVignette(ctx, W, H, 0.45)

      ctx.save()
      for (const b of g.bursts) {
        ctx.globalAlpha = Math.max(0, b.life)
        if (b.particle) {
          ctx.fillStyle = b.color
          ctx.beginPath()
          ctx.arc(b.x, b.y, 3, 0, Math.PI * 2)
          ctx.fill()
        } else {
          ctx.fillStyle = '#FFFFFF'
          ctx.font = '700 26px "Space Grotesk", system-ui, sans-serif'
          ctx.textAlign = 'center'
          ctx.fillText('+' + b.pts, b.x, b.y - (1 - b.life) * 70)
        }
      }
      ctx.restore()

      if (g.phase === 'playing') drawHud(ctx, W, H)
    }

    function drawGoal(ctx, goal, now) {
      ctx.save()
      const pull = ctx.createRadialGradient(goal.x, goal.y, 4, goal.x, goal.y, goal.r * 2)
      pull.addColorStop(0, 'rgba(0,229,176,0.30)')
      pull.addColorStop(0.5, 'rgba(0,229,176,0.08)')
      pull.addColorStop(1, 'rgba(0,229,176,0)')
      ctx.fillStyle = pull
      ctx.beginPath()
      ctx.arc(goal.x, goal.y, goal.r * 2, 0, Math.PI * 2)
      ctx.fill()

      ctx.translate(goal.x, goal.y)
      ctx.rotate(now * 0.0006)
      ctx.strokeStyle = '#00E5B0'
      ctx.shadowColor = '#00E5B0'
      ctx.shadowBlur = 26
      for (let ring = 0; ring < 3; ring++) {
        ctx.globalAlpha = 0.85 - ring * 0.22
        ctx.lineWidth = 3 - ring * 0.6
        ctx.setLineDash([26 - ring * 6, 16])
        ctx.beginPath()
        ctx.arc(0, 0, goal.r * (1 - ring * 0.17), 0, Math.PI * 2)
        ctx.stroke()
      }
      ctx.setLineDash([])
      ctx.restore()
    }

    function drawOrb(ctx, o, now) {
      ctx.save()
      for (let i = o.trail.length - 1; i > 0; i--) {
        const t = o.trail[i]
        ctx.globalAlpha = (1 - i / o.trail.length) * 0.25
        ctx.fillStyle = o.color
        ctx.beginPath()
        ctx.arc(t.x, t.y, o.r * (1 - i / o.trail.length) * 0.7, 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.globalAlpha = 1
      const glow = ctx.createRadialGradient(o.x, o.y, 1, o.x, o.y, o.r * 2.6)
      glow.addColorStop(0, '#FFFFFF')
      glow.addColorStop(0.22, o.color)
      glow.addColorStop(1, 'rgba(0,0,0,0)')
      ctx.fillStyle = glow
      ctx.beginPath()
      ctx.arc(o.x, o.y, o.r * 2.6, 0, Math.PI * 2)
      ctx.fill()

      if (o.held) {
        ctx.strokeStyle = '#FFFFFF'
        ctx.globalAlpha = 0.7
        ctx.lineWidth = 2
        ctx.setLineDash([6, 6])
        ctx.beginPath()
        ctx.arc(o.x, o.y, o.r * 1.9, o.spin, o.spin + Math.PI * 1.5)
        ctx.stroke()
        ctx.setLineDash([])
      }
      ctx.restore()
    }

    function drawHand(ctx, h, W, H, now) {
      const lm = h.lm
      const pt = (k) => ({
        x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
        y: lm[k].y * H,
      })
      const col = h.closed ? '#FFB000' : '#7C5CFF'

      // Force field when the palm is open
      if (!h.closed && h.open > 0.25) {
        ctx.save()
        const rr = FIELD_RADIUS * (0.5 + h.open * 0.5)
        const f = ctx.createRadialGradient(h.x, h.y, rr * 0.2, h.x, h.y, rr)
        f.addColorStop(0, `rgba(124,92,255,${0.05 + h.open * 0.12})`)
        f.addColorStop(1, 'rgba(124,92,255,0)')
        ctx.fillStyle = f
        ctx.beginPath()
        ctx.arc(h.x, h.y, rr, 0, Math.PI * 2)
        ctx.fill()
        ctx.strokeStyle = `rgba(160,130,255,${0.15 + h.open * 0.3})`
        ctx.lineWidth = 1.5
        for (let i = 0; i < 3; i++) {
          const p = ((now * 0.0006 + i / 3) % 1)
          ctx.globalAlpha = (1 - p) * (0.3 + h.open * 0.5)
          ctx.beginPath()
          ctx.arc(h.x, h.y, rr * p, 0, Math.PI * 2)
          ctx.stroke()
        }
        ctx.restore()
      }

      ctx.save()
      ctx.strokeStyle = col
      ctx.lineWidth = 3
      ctx.shadowColor = col
      ctx.shadowBlur = 16
      ctx.globalAlpha = 0.9
      for (const [a, b] of HAND_CONNECTIONS) {
        const u = pt(a), v = pt(b)
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawHud(ctx, W, H) {
      ctx.save()
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 38px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(g.score), 24, 50)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`${g.banked} banked`, 24, 70)

      const t = Math.ceil(g.timeLeft)
      ctx.textAlign = 'right'
      ctx.font = '600 38px "Space Grotesk", system-ui, sans-serif'
      ctx.fillStyle = t <= 10 ? '#FF4D8D' : '#EAEAF2'
      ctx.fillText(t + 's', W - 24, 50)
      ctx.restore()
    }

    let lastKey = ''
    function syncUi(handCount) {
      const next = {
        phase: g.phase,
        score: g.score,
        banked: g.banked,
        timeLeft: Math.ceil(g.timeLeft),
        hands: handCount,
      }
      const key = JSON.stringify(next)
      if (key !== lastKey) { lastKey = key; setUi(next) }
    }

    raf = requestAnimationFrame(frame)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  const loading = status === 'loading-model' || status === 'starting-camera'
  const ACCENT = '#00E5B0'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Move things without touching them" accent={ACCENT}>Kinetic</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="openPalm" title="Open palm" body="A force field pushes every orb away from you. Spread your fingers wider for more power." delay={80} />
            <HowTo glyph="fist" title="Close your fist" body="Snatch the nearest orb out of the air. It follows your hand." delay={160} />
            <HowTo glyph="wave" title="Open again to throw" body="Release, and the orb flies off with whatever speed your hand was moving." delay={240} />
          </div>
          <p className="text-white/70 mb-7 text-center max-w-md">
            Land orbs in the ring on the right. The faster they arrive, the more they score.
            Up to four hands at once, so bring a friend.
          </p>
          <Button accent={ACCENT} onClick={start}>Enter the arena</Button>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Time</p>
          <div className="font-display text-7xl font-700 text-mint mb-2 animate-pop">
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">{ui.banked} orbs banked</p>
          <Button accent={ACCENT} onClick={start}>Go again</Button>
        </Screen>
      )}
    </div>
  )
}
