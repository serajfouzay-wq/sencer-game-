import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, ROUTINES, scorePose, boneScore } from '../lib/poses.js'
import { createTracker, createRoster } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette, drawFrameGuide, drawColorGrade } from '../lib/render.js'
import { drawCharacter, withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, Choice, Results, Loading, ErrorScreen, Stagger, Odometer } from '../components/ui.jsx'

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
    bloom: createBloom(0.5),
    roster: null,
    players: [],
    step: -1,
    stepEndsAt: 0,
    readyAt: 0,
    countStart: 0,
    live: [],
    popups: [],
    beat: 0,
    beeped: -1,
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
          g.beeped = -1
          sfx.whoosh()
        }
      } else g.readyAt = 0
    }

    function runCountdown(now) {
      const n = Math.ceil((3200 - (now - g.countStart)) / 1000)
      if (n !== g.beeped && n > 0) { g.beeped = n; sfx.beep(3 - n) }
      if (now - g.countStart > 3200) {
        sfx.go()
        playMusic('dance')
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
        if (i === 0) {
          if (gr.label === 'PERFECT') sfx.perfect()
          else if (gr.label === 'GREAT') sfx.great()
          else if (gr.label === 'GOOD') sfx.good()
          else sfx.miss()
          if (p.combo > 1 && gr.points > 0) sfx.combo(p.combo)
        }
      }
      g.step += 1
      if (g.step >= routine.steps.length) {
        g.phase = 'over'
        stopMusic()
        sfx.win()
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

      // The dancers themselves, behind everything.
      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror,
          alpha: 0.34,
          grade: 'grayscale(0.7) brightness(0.5) contrast(1.2)',
        })
        drawColorGrade(ctx, W, H, '#FF4D8D', 0.10)
      }
      drawFloor(ctx, W, H, now)

      // Everything that glows goes into the bloom pass, then gets added back
      // once — far cheaper and prettier than blurring each shape separately.
      const useBloom = settings.bloom
      const bctx = useBloom ? g.bloom.layer(W, H) : null

      // With bloom on, the visible pass skips per-shape shadowBlur entirely and
      // lets the blurred layer supply the glow. Cheaper and softer.
      const mainGlow = useBloom ? 0 : null
      if (target) {
        drawTarget(ctx, W, H, target, now, mainGlow ?? 26)
        if (bctx) drawTarget(bctx, W, H, target, now, 0)
      }
      for (let i = 0; i < g.live.length; i++) {
        const l = g.live[i]
        if (!l) continue
        drawPerson(ctx, W, H, l, COLORS[i], mainGlow ?? 16)
        if (bctx) drawPerson(bctx, W, H, l, COLORS[i], 0)
      }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 10, alpha: 0.55 })

      drawVignette(ctx, W, H, 0.5)
      if (g.phase === 'dancing') drawBeat(ctx, W, H)
      drawPopups(ctx, W, H, dt)

      const anyoneSeen = g.live.some(Boolean)
      drawFrameGuide(ctx, W, H, anyoneSeen || g.phase !== 'dancing', Math.sin(now * 0.006) * 0.5 + 0.5)

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

    function drawTarget(ctx, W, H, target, now, glow = 26) {
      const h = H * 0.52
      const box = { x: W * 0.5 - h / 2, y: H * 0.09, w: h, h }
      const pts = {}
      for (const k of Object.keys(target.points)) {
        const p = target.points[k]
        const x = settings.mirror ? 1 - p.x : p.x
        pts[k] = { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      // Projector cone from above sells the hologram.
      ctx.save()
      const cone = ctx.createLinearGradient(W / 2, 0, W / 2, box.y + box.h)
      cone.addColorStop(0, 'rgba(176,107,255,0.16)')
      cone.addColorStop(1, 'rgba(176,107,255,0)')
      ctx.fillStyle = cone
      ctx.beginPath()
      ctx.moveTo(W / 2 - 30, 0)
      ctx.lineTo(W / 2 - box.w * 0.44, box.y + box.h)
      ctx.lineTo(W / 2 + box.w * 0.44, box.y + box.h)
      ctx.lineTo(W / 2 + 30, 0)
      ctx.closePath()
      ctx.fill()
      // Platform the figure stands on, pulsing with the beat.
      const beatPulse = 1 - Math.min(1, g.beat)
      ctx.strokeStyle = withAlpha('#B06BFF', 0.35 + beatPulse * 0.4)
      ctx.lineWidth = 2 + beatPulse * 3
      ctx.beginPath()
      ctx.ellipse(W / 2, box.y + box.h + 6, box.w * 0.32 * (1 + beatPulse * 0.06), box.w * 0.06, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()

      drawCharacter(ctx, pts, {
        color: '#B06BFF',
        accent: '#EBDBFF',
        alpha: 0.55 + (1 - g.beat) * 0.3,
        hologram: true,
        glow,
      })
    }

    function drawPerson(ctx, W, H, l, color, glow = 16) {
      const lm = l.lm
      const pts = {}
      for (const i of [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]) {
        if (!lm[i] || (lm[i].visibility ?? 1) < 0.4) continue
        pts[i] = { x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W, y: lm[i].y * H }
      }
      // Ground shadow anchors the character instead of leaving it floating.
      const feet = [pts[27], pts[28]].filter(Boolean)
      if (feet.length) {
        const fx = feet.reduce((a, p) => a + p.x, 0) / feet.length
        const fy = Math.max(...feet.map((p) => p.y))
        ctx.save()
        ctx.globalAlpha = 0.3
        ctx.fillStyle = '#000'
        ctx.beginPath()
        ctx.ellipse(fx, fy + 8, 46, 10, 0, 0, Math.PI * 2)
        ctx.fill()
        ctx.restore()
      }
      drawCharacter(ctx, pts, {
        color,
        accent: '#FFFFFF',
        glow,
        limbColor: l.result
          ? (a, b) => {
              const sc = boneScore(l.result.bones, a, b)
              return sc == null ? null : scoreColor(sc)
            }
          : null,
      })
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
  const ACCENT = '#FF4D8D'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase === 'dancing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-5 animate-riseIn" key={ui.poseName}>
            <div className="text-[11px] uppercase tracking-[0.2em] text-white/45">
              Move {ui.step + 1} of {ui.total}
            </div>
            <div className="font-display text-3xl md:text-4xl font-700 mt-0.5">{ui.poseName}</div>
            <div className="text-white/60 text-sm max-w-[15rem] mt-1">{ui.hint}</div>
          </div>
          <div className="pointer-events-none absolute right-6 top-5 flex flex-col gap-2 items-end">
            {ui.players.map((p, i) => (
              <div
                key={i}
                className="flex items-center gap-3 rounded-xl border px-3.5 py-2 backdrop-blur-md"
                style={{ background: p.color + '14', borderColor: p.color + '44' }}
              >
                <span className="text-xs" style={{ color: p.color }}>{p.name}</span>
                <Odometer value={p.score} className="font-display text-xl" />
                {p.combo > 1 && (
                  <span className="text-xs font-medium text-mint animate-pop" key={p.combo}>×{p.combo}</span>
                )}
              </div>
            ))}
          </div>
        </>
      )}

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading
          accent={ACCENT}
          label={status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'}
        />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Follow the dancer" accent={ACCENT}>Dance Floor</Title>
          <p className="text-white/70 mb-7 max-w-md text-center animate-riseIn" style={{ animationDelay: '90ms', animationFillMode: 'backwards' }}>
            A figure moves through a routine. Match each shape before the bar runs out — your limbs
            light up green as they line up. Chain hits for a combo multiplier.
          </p>
          <Stagger className="w-full max-w-sm space-y-5 mb-7" gap={110}>
            <Choice
              label="Routine"
              accent={ACCENT}
              options={ROUTINES.map((r, i) => ({ v: i, l: `${r.name} · ${r.level}` }))}
              value={cfg.current.routine}
              onChange={(v) => { cfg.current = { ...cfg.current, routine: v }; setUi((u) => ({ ...u })) }}
            />
            <Choice
              label="Dancers"
              accent={ACCENT}
              options={[1, 2, 3, 4].map((n) => ({ v: n, l: n === 1 ? 'Solo' : n === 2 ? '1 v 1' : `${n} players` }))}
              value={cfg.current.count}
              onChange={(v) => { cfg.current = { ...cfg.current, count: v }; setUi((u) => ({ ...u })) }}
            />
          </Stagger>
          <Button accent={ACCENT} onClick={() => begin(cfg.current.count, cfg.current.routine)}>
            Start the music
          </Button>
          <p className="text-muted text-xs mt-5">Stand back so everyone's legs are in frame.</p>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Routine complete</p>
          <div className="font-display text-4xl md:text-5xl font-700 mb-7 text-center animate-pop">
            {ranked.length > 1 ? `${ranked[0].name} wins` : 'Nice moves'}
          </div>
          <Results
            accent={ACCENT}
            rows={ranked.map((p) => ({ name: p.name, color: p.color, value: p.score, note: `best ×${p.best}` }))}
          />
          <div className="flex gap-3 mt-8">
            <Button accent={ACCENT} onClick={() => begin(cfg.current.count, cfg.current.routine)}>Dance again</Button>
            <Button variant="ghost" onClick={() => { g.phase = 'menu'; setUi((u) => ({ ...u, phase: 'menu' })) }}>
              Change routine
            </Button>
          </div>
        </Screen>
      )}
    </div>
  )
}
