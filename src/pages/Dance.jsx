import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, POSE_CONNECTIONS, ROUTINES, scorePose, boneScore } from '../lib/poses.js'
import { createTracker, createRoster } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'

const COLORS = ['#00E5B0', '#FF4D8D', '#FFB000', '#00D4FF']
const NAMES = ['Player 1', 'Player 2', 'Player 3', 'Player 4']

const GRADES = [
  { min: 0.86, label: 'PERFECT', points: 100, color: '#00E5B0' },
  { min: 0.72, label: 'GREAT', points: 70, color: '#B6FF3C' },
  { min: 0.55, label: 'GOOD', points: 40, color: '#FFB000' },
  { min: 0, label: 'MISS', points: 0, color: '#FF4D8D' },
]
const gradeFor = (s) => GRADES.find((gr) => s >= gr.min)

export default function Dance() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'pose',
    numPoses: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({
    phase: 'menu', step: 0, total: 0, poseName: '', hint: '',
    players: [], claimed: 0, need: 0, countdown: 0,
  })

  const cfg = useRef({ count: 2, routine: 0 })
  const g = useRef({
    phase: 'menu',
    tracker: createTracker({ maxDist: 0.3, maxAge: 900 }),
    roster: null,
    players: [],
    step: -1,
    stepEndsAt: 0,
    readyAt: 0,
    countStart: 0,
    live: [],
    popups: [],
    beat: 0,
    lastTime: 0,
    logged: false,
  }).current

  function begin(count, routine) {
    cfg.current = { count, routine }
    g.tracker.reset()
    g.roster = createRoster(count)
    g.players = Array.from({ length: count }, (_, i) => ({
      i, score: 0, combo: 0, best: 0, grades: [],
    }))
    g.step = -1
    g.popups = []
    g.logged = false
    g.phase = 'claim'
    g.readyAt = 0
  }

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

      const video = videoRef.current
      const aspect = video && video.videoHeight ? video.videoWidth / video.videoHeight : 16 / 9

      const res = status === 'ready' ? detect(now) : null
      const people = res && res.landmarks ? res.landmarks : []
      const points = people.map((lm) => {
        // Hips are the steadiest anchor for identifying a person.
        const hx = ((lm[23]?.x ?? 0.5) + (lm[24]?.x ?? 0.5)) / 2
        const hy = ((lm[23]?.y ?? 0.5) + (lm[24]?.y ?? 0.5)) / 2
        return { x: settings.mirror ? 1 - hx : hx, y: hy, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      const routine = ROUTINES[cfg.current.routine]
      const target = g.step >= 0 && g.step < routine.steps.length
        ? POSES[routine.steps[g.step]]
        : null

      // Score every rostered player against the current step.
      g.live = []
      if (g.roster) {
        const slots = g.roster.resolve(tracks)
        for (let i = 0; i < slots.length; i++) {
          const t = slots[i]
          if (!t || !t.data) { g.live.push(null); continue }
          const r = target ? scorePose(t.data, target, aspect) : null
          g.live.push({ lm: t.data, result: r, score: r ? r.score : 0 })
        }
      }

      if (g.phase === 'claim') runClaim(now, tracks)
      else if (g.phase === 'countdown') runCountdown(now)
      else if (g.phase === 'dancing') runDance(now, routine)

      g.beat = target ? (1 - (g.stepEndsAt - now) / routine.beatMs) : 0
      draw(ctx, W, H, dt, now, target, tracks)
      syncUi(routine, target, tracks)
    }

    function runClaim(now, tracks) {
      const need = cfg.current.count
      if (tracks.length >= need) {
        if (!g.readyAt) g.readyAt = now
        else if (now - g.readyAt > 1600) {
          g.roster.lock(tracks)
          g.phase = 'countdown'
          g.countStart = now
        }
      } else g.readyAt = 0
    }

    function runCountdown(now) {
      if (now - g.countStart > 3200) {
        g.phase = 'dancing'
        g.step = 0
        g.stepEndsAt = now + ROUTINES[cfg.current.routine].beatMs
      }
    }

    function runDance(now, routine) {
      if (now < g.stepEndsAt) return
      // Grade everyone on the shape they were holding as the beat landed.
      for (let i = 0; i < g.players.length; i++) {
        const p = g.players[i]
        const s = g.live[i] ? g.live[i].score : 0
        const gr = gradeFor(s)
        p.score += gr.points + (gr.points > 0 ? Math.min(p.combo, 10) * 5 : 0)
        p.combo = gr.points > 0 ? p.combo + 1 : 0
        p.best = Math.max(p.best, p.combo)
        p.grades.push(gr.label)
        g.popups.push({ i, label: gr.label, color: gr.color, life: 1 })
      }
      g.step += 1
      if (g.step >= routine.steps.length) {
        g.phase = 'over'
        if (!g.logged) {
          g.logged = true
          const best = [...g.players].sort((a, b) => b.score - a.score)[0]
          addSession({
            game: 'dance',
            score: best.score,
            detail: `${NAMES[best.i]} · ${routine.name}`,
          })
        }
      } else {
        g.stepEndsAt = now + routine.beatMs
      }
    }

    /* ------------------------------ rendering ------------------------------ */

    function draw(ctx, W, H, dt, now, target, tracks) {
      const bg = ctx.createLinearGradient(0, 0, W, H)
      bg.addColorStop(0, '#0B0620')
      bg.addColorStop(0.5, '#160B33')
      bg.addColorStop(1, '#0A0A18')
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, W, H)
      drawFloor(ctx, W, H, now)

      if (target) drawTarget(ctx, W, H, target, now)
      for (let i = 0; i < g.live.length; i++) {
        const l = g.live[i]
        if (l) drawPerson(ctx, W, H, l, COLORS[i])
      }
      if (g.phase === 'dancing') drawBeat(ctx, W, H)
      drawPopups(ctx, W, H, dt)
      if (g.phase === 'claim') drawClaim(ctx, W, H, tracks, now)
      if (g.phase === 'countdown') drawCountdown(ctx, W, H, now)
    }

    function drawFloor(ctx, W, H, now) {
      const hz = H * 0.66
      ctx.save()
      const pulse = 0.5 + Math.sin(now * 0.004) * 0.5
      for (let i = 0; i <= 18; i++) {
        const t = i / 18
        ctx.strokeStyle = `rgba(150,90,255,${0.08 + (i % 2 ? 0.06 : 0) * pulse})`
        ctx.lineWidth = 1
        ctx.beginPath()
        ctx.moveTo(t * W, H)
        ctx.lineTo(W * 0.5 + (t * W - W * 0.5) * 0.2, hz)
        ctx.stroke()
      }
      // Sweeping stage lights
      for (let i = 0; i < 3; i++) {
        const a = now * 0.0004 + (i * Math.PI * 2) / 3
        const x = W * 0.5 + Math.sin(a) * W * 0.42
        const grd = ctx.createLinearGradient(x, 0, W * 0.5, H)
        const c = ['0,229,176', '255,77,141', '0,212,255'][i]
        grd.addColorStop(0, `rgba(${c},0.16)`)
        grd.addColorStop(1, `rgba(${c},0)`)
        ctx.fillStyle = grd
        ctx.beginPath()
        ctx.moveTo(x, 0)
        ctx.lineTo(x - 90, H)
        ctx.lineTo(x + 90, H)
        ctx.closePath()
        ctx.fill()
      }
      ctx.restore()
    }

    function drawTarget(ctx, W, H, target, now) {
      const h = H * 0.5
      const box = { x: W * 0.5 - h / 2, y: H * 0.10, w: h, h }
      const pt = (i) => {
        const p = target.points[i]
        const x = settings.mirror ? 1 - p.x : p.x
        return { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      ctx.save()
      ctx.globalAlpha = 0.4 + (1 - g.beat) * 0.25
      ctx.strokeStyle = '#FFFFFF'
      ctx.lineWidth = 14
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.shadowColor = '#B06BFF'
      ctx.shadowBlur = 34
      for (const [a, b] of POSE_CONNECTIONS) {
        const u = pt(a), v = pt(b)
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      const head = pt(0)
      const gap = Math.hypot(pt(11).x - pt(12).x, pt(11).y - pt(12).y)
      ctx.beginPath()
      ctx.arc(head.x, head.y, Math.max(13, gap * 0.42), 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()
    }

    function drawPerson(ctx, W, H, l, color) {
      const lm = l.lm
      const pt = (i) => ({
        x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W,
        y: lm[i].y * H,
      })
      ctx.save()
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.lineWidth = 6
      for (const [a, b] of POSE_CONNECTIONS) {
        const va = lm[a], vb = lm[b]
        if (!va || !vb || (va.visibility ?? 1) < 0.4 || (vb.visibility ?? 1) < 0.4) continue
        const s = l.result ? boneScore(l.result.bones, a, b) : null
        const col = s == null ? color : scoreColor(s)
        const u = pt(a), v = pt(b)
        ctx.strokeStyle = col
        ctx.shadowColor = col
        ctx.shadowBlur = 12
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawBeat(ctx, W, H) {
      const p = Math.max(0, Math.min(1, g.beat))
      ctx.save()
      ctx.fillStyle = 'rgba(255,255,255,0.10)'
      ctx.fillRect(0, H - 6, W, 6)
      ctx.fillStyle = p > 0.8 ? '#FF4D8D' : '#00E5B0'
      ctx.fillRect(0, H - 6, W * p, 6)
      ctx.restore()
    }

    function drawPopups(ctx, W, H, dt) {
      for (const p of g.popups) p.life -= dt * 1.1
      g.popups = g.popups.filter((p) => p.life > 0)
      const n = Math.max(1, g.players.length)
      ctx.save()
      ctx.textAlign = 'center'
      for (const p of g.popups) {
        const x = (W / n) * (p.i + 0.5)
        ctx.globalAlpha = Math.min(1, p.life * 1.4)
        ctx.fillStyle = p.color
        ctx.font = '700 30px "Space Grotesk", system-ui, sans-serif'
        ctx.fillText(p.label, x, H * 0.5 - (1 - p.life) * 60)
      }
      ctx.restore()
    }

    function drawClaim(ctx, W, H, tracks, now) {
      const need = cfg.current.count
      ctx.save()
      ctx.fillStyle = 'rgba(8,5,20,0.7)'
      ctx.fillRect(0, 0, W, H)
      ctx.textAlign = 'center'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText('Step onto the floor', W / 2, H * 0.4)
      ctx.font = '500 15px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.6)'
      ctx.fillText(
        `${Math.min(tracks.length, need)} of ${need} dancers — stand side by side, full body in frame`,
        W / 2, H * 0.4 + 30
      )
      if (g.readyAt) {
        const p = Math.min(1, (now - g.readyAt) / 1600)
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 5
        ctx.beginPath()
        ctx.arc(W / 2, H * 0.55, 32, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawCountdown(ctx, W, H, now) {
      const left = 3200 - (now - g.countStart)
      const n = Math.ceil(left / 1000)
      const frac = (left % 1000) / 1000
      ctx.save()
      ctx.textAlign = 'center'
      ctx.globalAlpha = 0.35 + frac * 0.65
      ctx.fillStyle = '#FFFFFF'
      ctx.font = '700 140px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(Math.max(1, n)), W / 2, H * 0.56)
      ctx.restore()
    }

    let lastKey = ''
    function syncUi(routine, target, tracks) {
      const next = {
        phase: g.phase,
        step: Math.max(0, g.step),
        total: routine.steps.length,
        poseName: target ? target.name : '',
        hint: target ? target.hint : '',
        need: cfg.current.count,
        claimed: Math.min(tracks.length, cfg.current.count),
        countdown: 0,
        players: g.players.map((p) => ({
          name: NAMES[p.i], color: COLORS[p.i], score: p.score, combo: p.combo, best: p.best,
        })),
      }
      const key = JSON.stringify(next)
      if (key !== lastKey) { lastKey = key; setUi(next) }
    }

    raf = requestAnimationFrame(frame)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  const loading = status === 'loading-model' || status === 'starting-camera'
  const ranked = [...ui.players].sort((a, b) => b.score - a.score)

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase === 'dancing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-5">
            <div className="text-xs text-white/50">Move {ui.step + 1} of {ui.total}</div>
            <div className="font-display text-3xl font-700">{ui.poseName}</div>
            <div className="text-white/60 text-sm max-w-[15rem]">{ui.hint}</div>
          </div>
          <div className="pointer-events-none absolute right-6 top-5 flex flex-col gap-1.5 items-end">
            {ui.players.map((p, i) => (
              <div key={i} className="flex items-center gap-3 rounded-lg bg-ink/50 px-3 py-1.5 backdrop-blur">
                <span className="text-xs" style={{ color: p.color }}>{p.name}</span>
                <span className="font-display text-lg">{p.score}</span>
                {p.combo > 1 && <span className="text-xs text-mint">×{p.combo}</span>}
              </div>
            ))}
          </div>
        </>
      )}

      {status === 'error' && (
        <Overlay><h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p></Overlay>
      )}
      {loading && (
        <Overlay><div className="calibrate mb-5" />
          <p className="text-muted">{status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'}</p></Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-violet mb-2">Follow the dancer. Hit every beat.</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-5 text-center">Dance Floor</h1>
          <p className="text-white/70 mb-7 max-w-md text-center">
            A figure moves through a routine. Match each shape before the bar runs out — your limbs
            light up green as they line up. Chain hits for a combo multiplier.
          </p>
          <div className="w-full max-w-sm space-y-4">
            <Choice label="Routine" options={ROUTINES.map((r, i) => ({ v: i, l: `${r.name} · ${r.level}` }))}
              value={cfg.current.routine} onChange={(v) => { cfg.current = { ...cfg.current, routine: v }; setUi((u) => ({ ...u })) }} />
            <Choice label="Dancers" options={[1, 2, 3, 4].map((n) => ({ v: n, l: n === 1 ? 'Solo' : n === 2 ? '1 v 1' : `${n} players` }))}
              value={cfg.current.count} onChange={(v) => { cfg.current = { ...cfg.current, count: v }; setUi((u) => ({ ...u })) }} />
          </div>
          <button onClick={() => begin(cfg.current.count, cfg.current.routine)} className="btn-primary mt-7">
            Start the music
          </button>
          <p className="text-muted text-xs mt-4">Stand back so everyone's legs are in frame.</p>
        </Overlay>
      )}

      {ui.phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Routine complete</p>
          <div className="font-display text-4xl font-700 mb-6 text-center">
            {ranked.length > 1 ? `${ranked[0].name} wins` : 'Nice moves'}
          </div>
          <ul className="w-full max-w-sm space-y-1.5 mb-7">
            {ranked.map((p, i) => (
              <li key={i} className="flex items-center justify-between rounded-lg bg-white/5 px-4 py-2.5">
                <span className="flex items-center gap-3">
                  <span className="text-muted text-sm w-4">{i + 1}</span>
                  <span style={{ color: p.color }}>{p.name}</span>
                </span>
                <span className="flex items-center gap-4 text-sm">
                  <span className="text-muted">best ×{p.best}</span>
                  <span className="font-display text-xl text-fg">{p.score}</span>
                </span>
              </li>
            ))}
          </ul>
          <div className="flex gap-3">
            <button onClick={() => begin(cfg.current.count, cfg.current.routine)} className="btn-primary">Dance again</button>
            <button onClick={() => { g.phase = 'menu'; setUi((u) => ({ ...u, phase: 'menu' })) }} className="btn-ghost">Change routine</button>
          </div>
        </Overlay>
      )}
    </div>
  )
}

function Choice({ label, options, value, onChange }) {
  return (
    <div>
      <div className="text-xs text-muted mb-1.5">{label}</div>
      <div className="flex flex-wrap gap-2">
        {options.map((o) => (
          <button
            key={o.v}
            onClick={() => onChange(o.v)}
            className={
              'rounded-lg border px-3 py-1.5 text-sm transition-colors ' +
              (value === o.v ? 'border-mint text-mint bg-mint/10' : 'border-line text-muted hover:text-fg')
            }
          >
            {o.l}
          </button>
        ))}
      </div>
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
