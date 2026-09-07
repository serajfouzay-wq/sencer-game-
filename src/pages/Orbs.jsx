import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'

// MediaPipe hand skeleton connections (pairs of landmark indices).
const CONNECTIONS = [
  [0, 1], [1, 2], [2, 3], [3, 4],
  [0, 5], [5, 6], [6, 7], [7, 8],
  [5, 9], [9, 10], [10, 11], [11, 12],
  [9, 13], [13, 14], [14, 15], [15, 16],
  [13, 17], [17, 18], [18, 19], [19, 20],
  [0, 17],
]

const ROUND_SECONDS = 60
const PINCH_THRESHOLD = 0.06

export default function Orbs() {
  const settingsRef = useRef(loadSettings())
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: settingsRef.current.numHands,
    sensitivity: settingsRef.current.sensitivity,
  })

  const canvasRef = useRef(null)
  const [phase, setPhase] = useState('menu') // menu | playing | over
  const [result, setResult] = useState({ score: 0, maxCombo: 0 })

  // Mutable game state kept in a ref so the animation loop never re-renders React.
  const game = useRef({
    orbs: [],
    score: 0,
    combo: 0,
    maxCombo: 0,
    timeLeft: ROUND_SECONDS,
    lastSpawn: 0,
    lastTime: 0,
    wasPinching: false,
    running: false,
  })

  // Resize canvas to its container (crisp on high-DPI screens).
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const parent = canvas.parentElement
    const ro = new ResizeObserver(() => {
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const w = parent.clientWidth
      const h = parent.clientHeight
      canvas.width = Math.floor(w * dpr)
      canvas.height = Math.floor(h * dpr)
      canvas.style.width = w + 'px'
      canvas.style.height = h + 'px'
      const ctx = canvas.getContext('2d')
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
    })
    ro.observe(parent)
    return () => ro.disconnect()
  }, [])

  // Main render + game loop.
  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')

    function loop(now) {
      raf = requestAnimationFrame(loop)
      const g = game.current
      const s = settingsRef.current
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const W = canvas.width / dpr
      const H = canvas.height / dpr
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.05) : 0
      g.lastTime = now

      drawBackground(ctx, W, H, now)

      // Detect hands and gather cursor + pinch.
      const res = status === 'ready' ? detect(now) : null
      let cursor = null
      let pinching = false

      if (res && res.landmarks && res.landmarks.length) {
        for (const hand of res.landmarks) {
          drawHand(ctx, hand, W, H, s.mirror, s.showSkeleton)
        }
        const hand = res.landmarks[0]
        const tip = hand[8]
        const thumb = hand[4]
        const cx = (s.mirror ? 1 - tip.x : tip.x) * W
        const cy = tip.y * H
        cursor = { x: cx, y: cy }
        const dx = tip.x - thumb.x
        const dy = tip.y - thumb.y
        pinching = Math.hypot(dx, dy) < PINCH_THRESHOLD
        drawCursor(ctx, cx, cy, pinching, now)
      }

      if (g.running) {
        // Timer
        g.timeLeft -= dt
        if (g.timeLeft <= 0) {
          g.timeLeft = 0
          endRound()
        }

        // Spawn orbs, faster as the round goes on.
        const elapsed = ROUND_SECONDS - g.timeLeft
        const spawnEvery = Math.max(0.35, 1.1 - elapsed * 0.012)
        if (now - g.lastSpawn > spawnEvery * 1000) {
          g.lastSpawn = now
          spawnOrb(g, W, elapsed)
        }

        // Move + collide orbs
        for (const orb of g.orbs) {
          orb.y += orb.vy * dt
          orb.x += orb.vx * dt
          if (orb.x < orb.r || orb.x > W - orb.r) orb.vx *= -1
          if (cursor) {
            const d = Math.hypot(orb.x - cursor.x, orb.y - cursor.y)
            if (d < orb.r + 26) {
              orb.alive = false
              g.combo += 1
              g.maxCombo = Math.max(g.maxCombo, g.combo)
              g.score += 10 + Math.min(g.combo, 20) * 2
            }
          }
          if (orb.y > H + orb.r) {
            orb.alive = false
            g.combo = 0
          }
        }

        // Pinch blast: clear orbs near the cursor on the pinch's rising edge.
        if (cursor && pinching && !g.wasPinching) {
          for (const orb of g.orbs) {
            if (Math.hypot(orb.x - cursor.x, orb.y - cursor.y) < 150) {
              orb.alive = false
              g.score += 25
              g.combo += 1
              g.maxCombo = Math.max(g.maxCombo, g.combo)
            }
          }
          spawnBlast(g, cursor.x, cursor.y)
        }
        g.wasPinching = pinching

        g.orbs = g.orbs.filter((o) => o.alive)
        drawOrbs(ctx, g.orbs, now)
        drawParticles(ctx, g, dt)
        drawHud(ctx, W, g)
      } else {
        drawParticles(ctx, g, dt)
      }
    }

    raf = requestAnimationFrame(loop)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  function startRound() {
    const g = game.current
    g.orbs = []
    g.particles = []
    g.score = 0
    g.combo = 0
    g.maxCombo = 0
    g.timeLeft = ROUND_SECONDS
    g.lastSpawn = 0
    g.wasPinching = false
    g.running = true
    setPhase('playing')
  }

  function endRound() {
    const g = game.current
    g.running = false
    const r = { score: g.score, maxCombo: g.maxCombo }
    setResult(r)
    addSession({ game: 'orbs', score: r.score, maxCombo: r.maxCombo, duration: ROUND_SECONDS, detail: `best combo x${r.maxCombo}` })
    setPhase('over')
  }

  const loading = status === 'loading-model' || status === 'starting-camera'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {/* Overlays */}
      {status === 'error' && (
        <Overlay>
          <h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p>
        </Overlay>
      )}

      {loading && (
        <Overlay>
          <div className="calibrate mb-5" />
          <p className="text-muted">
            {status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}
          </p>
        </Overlay>
      )}

      {status === 'ready' && phase === 'menu' && (
        <Overlay>
          <h1 className="font-display text-4xl md:text-5xl font-700 mb-3 text-center">
            Catch the orbs <span className="text-mint">with your hand</span>
          </h1>
          <p className="text-muted mb-6 max-w-md text-center">
            Move your hand to sweep up orbs. Pinch your thumb and finger together to blast a cluster.
            You have {ROUND_SECONDS} seconds.
          </p>
          <button onClick={startRound} className="btn-primary">Start round</button>
        </Overlay>
      )}

      {phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Round over</p>
          <div className="font-display text-6xl font-700 text-mint mb-1">{result.score}</div>
          <p className="text-muted mb-6">Best combo ×{result.maxCombo}</p>
          <button onClick={startRound} className="btn-primary">Play again</button>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/55 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}

/* ---------- drawing helpers ---------- */

function drawBackground(ctx, W, H, now) {
  ctx.clearRect(0, 0, W, H)
  ctx.fillStyle = '#0A0A12'
  ctx.fillRect(0, 0, W, H)
  ctx.save()
  ctx.globalAlpha = 0.08
  ctx.strokeStyle = '#7C5CFF'
  ctx.lineWidth = 1
  const step = 48
  const drift = (now * 0.01) % step
  for (let x = -step + drift; x < W; x += step) {
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke()
  }
  for (let y = -step + drift; y < H; y += step) {
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke()
  }
  ctx.restore()
}

function drawHand(ctx, hand, W, H, mirror, showSkeleton) {
  const pt = (i) => ({ x: (mirror ? 1 - hand[i].x : hand[i].x) * W, y: hand[i].y * H })
  if (showSkeleton) {
    ctx.save()
    ctx.strokeStyle = 'rgba(124,92,255,0.7)'
    ctx.lineWidth = 3
    ctx.shadowColor = '#7C5CFF'
    ctx.shadowBlur = 12
    for (const [a, b] of CONNECTIONS) {
      const p = pt(a), q = pt(b)
      ctx.beginPath(); ctx.moveTo(p.x, p.y); ctx.lineTo(q.x, q.y); ctx.stroke()
    }
    ctx.fillStyle = '#EAEAF2'
    for (let i = 0; i < 21; i++) {
      const p = pt(i)
      ctx.beginPath(); ctx.arc(p.x, p.y, 3, 0, Math.PI * 2); ctx.fill()
    }
    ctx.restore()
  }
}

function drawCursor(ctx, x, y, pinching, now) {
  const pulse = 1 + Math.sin(now * 0.008) * 0.15
  ctx.save()
  ctx.shadowColor = '#00E5B0'
  ctx.shadowBlur = 24
  ctx.strokeStyle = '#00E5B0'
  ctx.lineWidth = pinching ? 5 : 3
  ctx.beginPath(); ctx.arc(x, y, (pinching ? 16 : 22) * pulse, 0, Math.PI * 2); ctx.stroke()
  ctx.fillStyle = '#00E5B0'
  ctx.beginPath(); ctx.arc(x, y, 4, 0, Math.PI * 2); ctx.fill()
  ctx.restore()
}

function drawOrbs(ctx, orbs, now) {
  for (const orb of orbs) {
    ctx.save()
    ctx.shadowColor = orb.color
    ctx.shadowBlur = 18
    const grd = ctx.createRadialGradient(orb.x, orb.y, 1, orb.x, orb.y, orb.r)
    grd.addColorStop(0, '#ffffff')
    grd.addColorStop(0.4, orb.color)
    grd.addColorStop(1, 'rgba(0,0,0,0)')
    ctx.fillStyle = grd
    ctx.beginPath(); ctx.arc(orb.x, orb.y, orb.r, 0, Math.PI * 2); ctx.fill()
    ctx.restore()
  }
}

function drawHud(ctx, W, g) {
  ctx.save()
  ctx.fillStyle = '#EAEAF2'
  ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
  ctx.textBaseline = 'top'
  ctx.fillText(String(g.score), 24, 20)
  ctx.font = '500 14px Inter, system-ui, sans-serif'
  ctx.fillStyle = '#8A8AA0'
  ctx.fillText('SCORE', 24, 58)

  const t = Math.ceil(g.timeLeft)
  ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
  ctx.fillStyle = t <= 10 ? '#FF7A45' : '#EAEAF2'
  ctx.textAlign = 'right'
  ctx.fillText(t + 's', W - 24, 20)
  ctx.textAlign = 'left'

  if (g.combo > 1) {
    ctx.fillStyle = '#00E5B0'
    ctx.font = '600 20px "Space Grotesk", system-ui, sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText('combo ×' + g.combo, W / 2, 22)
    ctx.textAlign = 'left'
  }
  ctx.restore()
}

/* ---------- game object helpers ---------- */

const ORB_COLORS = ['#00E5B0', '#7C5CFF', '#FF7A45', '#4DA3FF']

function spawnOrb(g, W, elapsed) {
  const r = 16 + Math.random() * 16
  g.orbs.push({
    x: r + Math.random() * (W - r * 2),
    y: -r,
    r,
    vy: 90 + Math.random() * 70 + elapsed * 3,
    vx: (Math.random() - 0.5) * 60,
    color: ORB_COLORS[(Math.random() * ORB_COLORS.length) | 0],
    alive: true,
  })
}

function spawnBlast(g, x, y) {
  if (!g.particles) g.particles = []
  for (let i = 0; i < 22; i++) {
    const a = Math.random() * Math.PI * 2
    const sp = 120 + Math.random() * 220
    g.particles.push({ x, y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp, life: 1, color: '#00E5B0' })
  }
}

function drawParticles(ctx, g, dt) {
  if (!g.particles) return
  for (const p of g.particles) {
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.life -= dt * 1.8
  }
  g.particles = g.particles.filter((p) => p.life > 0)
  ctx.save()
  for (const p of g.particles) {
    ctx.globalAlpha = Math.max(p.life, 0)
    ctx.fillStyle = p.color
    ctx.beginPath(); ctx.arc(p.x, p.y, 3, 0, Math.PI * 2); ctx.fill()
  }
  ctx.restore()
}
