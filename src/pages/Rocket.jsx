import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { palmCenter } from '../lib/gestures.js'
import { createTracker, createRoster } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, roundRect } from '../lib/canvas.js'

const COLORS = ['#FFB000', '#00D4FF', '#FF4D8D', '#B6FF3C']
const NAMES = ['Player 1', 'Player 2', 'Player 3', 'Player 4']
const TEAM_COLORS = ['#FFB000', '#00D4FF']

export default function Rocket() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({ phase: 'menu', claimed: 0, standing: [], winner: '' })
  const cfgRef = useRef({ count: 2, teams: false })

  const g = useRef({
    phase: 'menu',
    tracker: createTracker({ maxDist: 0.28, maxAge: 600 }),
    roster: null,
    ships: [],
    walls: [],
    sparks: [],
    stars: [],
    scroll: 0,
    speed: 260,
    dist: 0,
    spawnAt: 0,
    readyAt: 0,
    lastTime: 0,
    shake: 0,
    logged: false,
  }).current

  function begin(count, teams) {
    cfgRef.current = { count, teams }
    g.tracker.reset()
    g.roster = createRoster(count)
    g.phase = 'claim'
    g.readyAt = 0
    g.logged = false
    setUi({ phase: 'claim', claimed: 0, standing: [], winner: '' })
  }

  function launch() {
    const { count, teams } = cfgRef.current
    g.ships = Array.from({ length: count }, (_, i) => ({
      i,
      y: 0.5,
      vy: 0,
      alive: true,
      dist: 0,
      team: teams ? i % 2 : i,
      color: teams ? TEAM_COLORS[i % 2] : COLORS[i],
      trail: [],
    }))
    g.walls = []
    g.sparks = []
    g.scroll = 0
    g.speed = 260
    g.dist = 0
    g.spawnAt = 0
    g.phase = 'flying'
  }

  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    if (!g.stars.length) {
      for (let i = 0; i < 130; i++) {
        g.stars.push({ x: Math.random(), y: Math.random(), z: 0.3 + Math.random() * 0.7 })
      }
    }

    function frame(now) {
      raf = requestAnimationFrame(frame)
      const { W, H } = logicalSize(canvas)
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.05) : 0
      g.lastTime = now

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      if (g.phase === 'claim') runClaim(now, tracks)
      else if (g.phase === 'flying') runFlight(dt, now, tracks, H)

      draw(ctx, W, H, dt, now, tracks)
    }

    function runClaim(now, tracks) {
      const need = cfgRef.current.count
      const have = Math.min(tracks.length, need)
      if (have >= need) {
        if (!g.readyAt) g.readyAt = now
        else if (now - g.readyAt > 1500) {
          g.roster.lock(tracks)
          g.readyAt = 0
          launch()
        }
      } else {
        g.readyAt = 0
      }
      setUiIfChanged({ phase: 'claim', claimed: have, standing: [], winner: '' })
    }

    function runFlight(dt, now, tracks, H) {
      const slots = g.roster.resolve(tracks)
      g.speed += dt * 9
      g.dist += g.speed * dt
      g.scroll += g.speed * dt

      for (const s of g.ships) {
        if (!s.alive) continue
        s.dist = g.dist
        const t = slots[s.i]
        if (t) {
          // Hand height maps to lane height, eased so it glides rather than snaps.
          const target = Math.max(0.06, Math.min(0.94, (t.y - 0.15) / 0.7))
          s.y += (target - s.y) * Math.min(1, dt * 9)
        } else {
          s.y += (0.5 - s.y) * Math.min(1, dt * 1.5)
        }
        s.trail.unshift({ y: s.y })
        if (s.trail.length > 22) s.trail.pop()
      }

      // Spawn wall pairs with a gap that narrows as speed climbs.
      if (g.scroll > g.spawnAt) {
        g.spawnAt = g.scroll + 300 + Math.random() * 120
        const gap = Math.max(0.20, 0.42 - g.dist / 60000)
        const centre = 0.18 + Math.random() * 0.64
        g.walls.push({ x: 1.15, gapTop: centre - gap / 2, gapBottom: centre + gap / 2, hit: new Set() })
      }

      const norm = g.speed / 1200
      for (const w of g.walls) w.x -= norm * dt * 1.9

      for (const s of g.ships) {
        if (!s.alive) continue
        const sx = 0.18
        for (const w of g.walls) {
          if (Math.abs(w.x - sx) > 0.035) continue
          if (s.y < w.gapTop || s.y > w.gapBottom) {
            s.alive = false
            g.shake = 1
            burst(sx, s.y, s.color)
          }
        }
      }
      g.walls = g.walls.filter((w) => w.x > -0.15)

      for (const p of g.sparks) {
        p.x += p.vx * dt
        p.y += p.vy * dt
        p.life -= dt * 1.4
      }
      g.sparks = g.sparks.filter((p) => p.life > 0)

      const alive = g.ships.filter((s) => s.alive)
      const { teams } = cfgRef.current
      const aliveTeams = new Set(alive.map((s) => s.team))
      if ((teams && aliveTeams.size <= 1) || (!teams && alive.length <= 1)) {
        finish(alive, aliveTeams)
      }
    }

    function finish(alive, aliveTeams) {
      const { teams } = cfgRef.current
      g.phase = 'over'
      const km = (g.dist / 100).toFixed(0)
      let winner
      if (teams) {
        const t = [...aliveTeams][0]
        winner = t === undefined ? 'Nobody' : `Team ${t + 1}`
      } else {
        winner = alive.length ? NAMES[alive[0].i] : 'Nobody'
      }
      const standing = [...g.ships]
        .sort((a, b) => (b.alive ? 1 : 0) - (a.alive ? 1 : 0))
        .map((s) => ({ name: NAMES[s.i], color: s.color, alive: s.alive }))
      if (!g.logged) {
        g.logged = true
        addSession({ game: 'rocket', score: Number(km), detail: `${winner} · ${km}km` })
      }
      setUiIfChanged({ phase: 'over', claimed: 0, standing, winner })
    }

    function burst(x, y, color) {
      for (let i = 0; i < 30; i++) {
        const a = Math.random() * Math.PI * 2
        const sp = 0.1 + Math.random() * 0.5
        g.sparks.push({ x, y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp, life: 1, color })
      }
    }

    /* ------------------------------ rendering ------------------------------ */

    function draw(ctx, W, H, dt, now, tracks) {
      ctx.save()
      if (g.shake > 0) {
        g.shake = Math.max(0, g.shake - dt * 3)
        const m = g.shake * 12
        ctx.translate((Math.random() - 0.5) * m, (Math.random() - 0.5) * m)
      }

      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#05030F')
      sky.addColorStop(0.5, '#0E0A28')
      sky.addColorStop(1, '#1B0E33')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      // Parallax starfield
      for (const st of g.stars) {
        st.x -= (g.phase === 'flying' ? 0.00018 * g.speed : 0.02) * st.z * dt * 6
        if (st.x < 0) { st.x += 1; st.y = Math.random() }
        ctx.globalAlpha = 0.25 + st.z * 0.6
        ctx.fillStyle = '#CFE4FF'
        ctx.fillRect(st.x * W, st.y * H, 1.6 * st.z, 1.6 * st.z)
      }
      ctx.globalAlpha = 1

      if (g.phase === 'flying' || g.phase === 'over') {
        for (const w of g.walls) drawWall(ctx, W, H, w)
        for (const s of g.ships) drawShip(ctx, W, H, s, now)
        for (const p of g.sparks) {
          ctx.globalAlpha = Math.max(0, p.life)
          ctx.fillStyle = p.color
          ctx.beginPath()
          ctx.arc(p.x * W, p.y * H, 2.5, 0, Math.PI * 2)
          ctx.fill()
        }
        ctx.globalAlpha = 1
        drawHud(ctx, W)
      }

      if (g.phase === 'claim') drawClaim(ctx, W, H, tracks, now)
      ctx.restore()
    }

    function drawWall(ctx, W, H, w) {
      const x = w.x * W
      const bw = 26
      const grd = ctx.createLinearGradient(x, 0, x + bw, 0)
      grd.addColorStop(0, '#4B2A6B')
      grd.addColorStop(0.5, '#8B4BC7')
      grd.addColorStop(1, '#4B2A6B')
      ctx.fillStyle = grd
      ctx.shadowColor = '#B06BFF'
      ctx.shadowBlur = 22
      ctx.fillRect(x, 0, bw, w.gapTop * H)
      ctx.fillRect(x, w.gapBottom * H, bw, H - w.gapBottom * H)
      ctx.shadowBlur = 0
      ctx.fillStyle = 'rgba(220,170,255,0.85)'
      ctx.fillRect(x, w.gapTop * H - 4, bw, 4)
      ctx.fillRect(x, w.gapBottom * H, bw, 4)
    }

    function drawShip(ctx, W, H, s, now) {
      const x = 0.18 * W
      const y = s.y * H
      if (!s.alive) return

      // Exhaust trail
      ctx.save()
      for (let i = s.trail.length - 1; i >= 0; i--) {
        const t = s.trail[i]
        ctx.globalAlpha = (1 - i / s.trail.length) * 0.5
        ctx.fillStyle = s.color
        ctx.beginPath()
        ctx.arc(x - i * 5, t.y * H, Math.max(1, 7 - i * 0.3), 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.restore()

      ctx.save()
      ctx.translate(x, y)
      ctx.shadowColor = s.color
      ctx.shadowBlur = 20
      ctx.fillStyle = s.color
      ctx.beginPath()
      ctx.moveTo(20, 0)
      ctx.lineTo(-10, -10)
      ctx.lineTo(-5, 0)
      ctx.lineTo(-10, 10)
      ctx.closePath()
      ctx.fill()
      const flick = 8 + Math.sin(now * 0.05) * 4
      ctx.globalAlpha = 0.8
      ctx.fillStyle = '#FFD36E'
      ctx.beginPath()
      ctx.moveTo(-8, -4)
      ctx.lineTo(-8 - flick, 0)
      ctx.lineTo(-8, 4)
      ctx.closePath()
      ctx.fill()
      ctx.restore()
    }

    function drawHud(ctx, W) {
      ctx.save()
      ctx.font = '600 30px "Space Grotesk", system-ui, sans-serif'
      ctx.fillStyle = '#EAEAF2'
      ctx.fillText((g.dist / 100).toFixed(0) + 'km', 22, 44)
      let x = W - 22
      ctx.textAlign = 'right'
      ctx.font = '600 13px Inter, system-ui, sans-serif'
      for (let i = g.ships.length - 1; i >= 0; i--) {
        const s = g.ships[i]
        ctx.globalAlpha = s.alive ? 1 : 0.3
        ctx.fillStyle = s.color
        ctx.fillText(NAMES[s.i].replace('Player ', 'P'), x, 40)
        x -= 42
      }
      ctx.restore()
    }

    function drawClaim(ctx, W, H, tracks, now) {
      const need = cfgRef.current.count
      ctx.save()
      ctx.fillStyle = 'rgba(5,3,15,0.65)'
      ctx.fillRect(0, 0, W, H)
      ctx.textAlign = 'center'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText('Raise one hand each', W / 2, H * 0.34)
      ctx.font = '500 15px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.6)'
      ctx.fillText(
        `${Math.min(tracks.length, need)} of ${need} pilots ready — stand left to right`,
        W / 2, H * 0.34 + 30
      )

      const size = 54
      const total = need * (size + 16) - 16
      for (let i = 0; i < need; i++) {
        const x = W / 2 - total / 2 + i * (size + 16)
        const y = H * 0.46
        const on = i < tracks.length
        ctx.strokeStyle = on ? (cfgRef.current.teams ? TEAM_COLORS[i % 2] : COLORS[i]) : 'rgba(255,255,255,0.2)'
        ctx.lineWidth = on ? 3 : 1.5
        roundRect(ctx, x, y, size, size, 14)
        ctx.stroke()
        if (on) {
          ctx.fillStyle = cfgRef.current.teams ? TEAM_COLORS[i % 2] : COLORS[i]
          ctx.globalAlpha = 0.2
          ctx.fill()
          ctx.globalAlpha = 1
        }
      }

      if (g.readyAt) {
        const p = Math.min(1, (now - g.readyAt) / 1500)
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 4
        ctx.beginPath()
        ctx.arc(W / 2, H * 0.62, 28, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p)
        ctx.stroke()
      }
      ctx.restore()
    }

    let lastKey = ''
    function setUiIfChanged(next) {
      const key = JSON.stringify(next)
      if (key !== lastKey) {
        lastKey = key
        setUi(next)
      }
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

      {status === 'error' && (
        <Overlay><h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p></Overlay>
      )}
      {loading && (
        <Overlay><div className="calibrate mb-5" />
          <p className="text-muted">{status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}</p></Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-p2 mb-2">Fly with your palm. Last one flying wins.</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-6 text-center">Rocket Rush</h1>
          <p className="text-white/70 mb-7 max-w-md text-center">
            Raise your hand and move it up and down to fly. Thread the gaps in the gates — one
            clip and you're out. The walls get faster and the gaps get tighter.
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <button onClick={() => begin(2, false)} className="btn-primary">1 v 1</button>
            <button onClick={() => begin(3, false)} className="btn-ghost">3 players</button>
            <button onClick={() => begin(4, false)} className="btn-ghost">4 players</button>
            <button onClick={() => begin(4, true)} className="btn-ghost">2 v 2 teams</button>
          </div>
        </Overlay>
      )}

      {ui.phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Flight over</p>
          <div className="font-display text-4xl md:text-5xl font-700 mb-6 text-center">{ui.winner} wins</div>
          <ul className="w-full max-w-xs space-y-1.5 mb-7">
            {ui.standing.map((s, i) => (
              <li key={i} className="flex items-center justify-between rounded-lg bg-white/5 px-4 py-2 text-sm">
                <span style={{ color: s.color }}>{s.name}</span>
                <span className="text-muted">{s.alive ? 'survived' : 'wrecked'}</span>
              </li>
            ))}
          </ul>
          <div className="flex gap-3">
            <button onClick={() => begin(cfgRef.current.count, cfgRef.current.teams)} className="btn-primary">Fly again</button>
            <button onClick={() => { g.phase = 'menu'; setUi({ phase: 'menu', claimed: 0, standing: [], winner: '' }) }} className="btn-ghost">Change mode</button>
          </div>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
