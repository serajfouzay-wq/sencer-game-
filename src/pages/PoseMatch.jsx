import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, scorePose, boneScore } from '../lib/poses.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette, drawFrameGuide, drawColorGrade } from '../lib/render.js'
import { drawCharacter, withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, Results, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ROUND_POSES = 6
const SECONDS_PER_POSE = 10
const LOCK_SCORE = 0.72   // how close you need to be
const LOCK_HOLD = 0.55    // seconds you must hold it

export default function PoseMatch() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'pose',
    numPoses: 1,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({
    phase: 'menu',
    poseName: '',
    hint: '',
    match: 0,
    index: 0,
    score: 0,
    timeLeft: SECONDS_PER_POSE,
    locked: false,
    visible: true,
    results: [],
  })

  const g = useRef({
    phase: 'menu',
    bloom: createBloom(0.5),
    order: [],
    index: 0,
    score: 0,
    results: [],
    timeLeft: SECONDS_PER_POSE,
    holdFor: 0,
    match: 0,
    smooth: 0,
    lockedAt: 0,
    celebrate: 0,
    bones: {},
    visible: true,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    const order = [...POSES.keys()].sort(() => Math.random() - 0.5).slice(0, ROUND_POSES)
    Object.assign(g, {
      phase: 'playing',
      order,
      index: 0,
      score: 0,
      results: [],
      timeLeft: SECONDS_PER_POSE,
      holdFor: 0,
      match: 0,
      smooth: 0,
      celebrate: 0,
      logged: false,
    })
    playMusic('chill')
    setUi((u) => ({ ...u, phase: 'playing', results: [] }))
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
      const person = res && res.landmarks && res.landmarks.length ? res.landmarks[0] : null

      const target = g.phase === 'playing' ? POSES[g.order[g.index]] : null

      if (person && target) {
        const r = scorePose(person, target, aspect)
        g.bones = r.bones
        g.visible = r.enoughVisible
        g.match = r.enoughVisible ? r.score : 0
      } else {
        g.bones = {}
        g.match = 0
        g.visible = !!person
      }
      // Smooth the meter so it reads steadily instead of twitching.
      g.smooth += (g.match - g.smooth) * Math.min(1, dt * 8)

      if (g.phase === 'playing') advance(dt)

      drawBackdrop(ctx, W, H, now)
      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror,
          alpha: 0.30,
          grade: 'grayscale(0.75) brightness(0.5) contrast(1.15)',
        })
        drawColorGrade(ctx, W, H, '#7C5CFF', 0.10)
      }
      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const mainGlow = bctx ? 0 : null
      if (target) { drawTarget(ctx, W, H, target, now, mainGlow ?? 26); if (bctx) drawTarget(bctx, W, H, target, now, 0) }
      if (person) { drawPlayer(ctx, W, H, person, mainGlow ?? 16); if (bctx) drawPlayer(bctx, W, H, person, 0) }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 10, alpha: 0.55 })
      drawVignette(ctx, W, H, 0.5)
      drawFrameGuide(ctx, W, H, !!person && g.visible, Math.sin(now * 0.006) * 0.5 + 0.5)
      if (g.phase === 'playing') drawHud(ctx, W, H, dt)
      syncUi(target)
    }

    function advance(dt) {
      g.timeLeft -= dt
      if (g.match >= LOCK_SCORE) {
        g.holdFor += dt
        if (g.holdFor >= LOCK_HOLD) return finishPose(true)
      } else {
        g.holdFor = Math.max(0, g.holdFor - dt * 1.5)
      }
      if (g.timeLeft <= 0) finishPose(false)
    }

    function finishPose(locked) {
      if (locked) sfx.perfect(); else sfx.miss()
      const timeBonus = locked ? Math.round(Math.max(0, g.timeLeft) * 12) : 0
      const quality = Math.round(g.match * 100)
      const gained = locked ? 100 + timeBonus : Math.round(quality * 0.5)
      g.score += gained
      g.results.push({
        name: POSES[g.order[g.index]].name,
        quality,
        locked,
        points: gained,
      })
      g.celebrate = locked ? 1 : 0
      g.index += 1
      g.holdFor = 0
      g.timeLeft = SECONDS_PER_POSE
      if (g.index >= g.order.length) {
        g.phase = 'over'
        stopMusic()
        sfx.win()
        if (!g.logged) {
          g.logged = true
          const hits = g.results.filter((r) => r.locked).length
          addSession({
            game: 'posematch',
            score: g.score,
            detail: `${hits}/${g.results.length} poses nailed`,
          })
        }
      }
    }

    /* ------------------------------ rendering ------------------------------ */

    function drawBackdrop(ctx, W, H, now) {
      const bg = ctx.createLinearGradient(0, 0, W, H)
      bg.addColorStop(0, '#0B0A1C')
      bg.addColorStop(0.55, '#141033')
      bg.addColorStop(1, '#0A0A12')
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, W, H)

      // Slow sweeping spotlight
      const sweep = (Math.sin(now * 0.00035) * 0.5 + 0.5) * W
      const beam = ctx.createRadialGradient(sweep, H * 0.1, 20, sweep, H * 0.1, H * 0.95)
      beam.addColorStop(0, 'rgba(124,92,255,0.20)')
      beam.addColorStop(1, 'rgba(124,92,255,0)')
      ctx.fillStyle = beam
      ctx.fillRect(0, 0, W, H)

      // Floor grid for depth
      ctx.save()
      ctx.strokeStyle = 'rgba(124,92,255,0.16)'
      ctx.lineWidth = 1
      const hz = H * 0.68
      for (let i = 0; i <= 16; i++) {
        const t = i / 16
        const x = t * W
        ctx.beginPath()
        ctx.moveTo(x, H)
        ctx.lineTo(W * 0.5 + (x - W * 0.5) * 0.18, hz)
        ctx.stroke()
      }
      for (let i = 1; i <= 9; i++) {
        const t = i / 9
        const y = hz + (H - hz) * t * t
        ctx.globalAlpha = 0.5
        ctx.beginPath()
        ctx.moveTo(0, y)
        ctx.lineTo(W, y)
        ctx.stroke()
      }
      ctx.restore()
    }

    // Maps authored pose space into a centred box that keeps proportions.
    function targetBox(W, H) {
      const h = H * 0.62
      const w = h
      return { x: W * 0.5 - w / 2, y: H * 0.14, w, h }
    }

    function drawTarget(ctx, W, H, target, now, glow = 26) {
      const box = targetBox(W, H)
      const pts = {}
      for (const k of Object.keys(target.points)) {
        const p = target.points[k]
        const x = settings.mirror ? 1 - p.x : p.x
        pts[k] = { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      ctx.save()
      const cone = ctx.createLinearGradient(W / 2, 0, W / 2, box.y + box.h)
      cone.addColorStop(0, 'rgba(124,92,255,0.14)')
      cone.addColorStop(1, 'rgba(124,92,255,0)')
      ctx.fillStyle = cone
      ctx.beginPath()
      ctx.moveTo(W / 2 - 26, 0)
      ctx.lineTo(W / 2 - box.w * 0.42, box.y + box.h)
      ctx.lineTo(W / 2 + box.w * 0.42, box.y + box.h)
      ctx.lineTo(W / 2 + 26, 0)
      ctx.closePath()
      ctx.fill()
      ctx.strokeStyle = withAlpha('#7C5CFF', 0.4)
      ctx.lineWidth = 2
      ctx.beginPath()
      ctx.ellipse(W / 2, box.y + box.h + 6, box.w * 0.30, box.w * 0.055, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()

      drawCharacter(ctx, pts, {
        color: '#7C5CFF',
        accent: '#DED3FF',
        alpha: 0.55 + Math.sin(now * 0.003) * 0.12,
        hologram: true,
        glow,
      })
    }

    function drawPlayer(ctx, W, H, lm, glow = 16) {
      const pts = {}
      for (const i of [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]) {
        if (!lm[i] || (lm[i].visibility ?? 1) < 0.4) continue
        pts[i] = { x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W, y: lm[i].y * H }
      }
      const feet = [pts[27], pts[28]].filter(Boolean)
      if (feet.length) {
        const fx = feet.reduce((a, p) => a + p.x, 0) / feet.length
        const fy = Math.max(...feet.map((p) => p.y))
        ctx.save()
        ctx.globalAlpha = 0.3
        ctx.fillStyle = '#000'
        ctx.beginPath()
        ctx.ellipse(fx, fy + 8, 48, 11, 0, 0, Math.PI * 2)
        ctx.fill()
        ctx.restore()
      }
      drawCharacter(ctx, pts, {
        color: '#00E5B0',
        accent: '#FFFFFF',
        glow,
        limbColor: (a, b) => {
          const sc = boneScore(g.bones, a, b)
          return sc == null ? null : scoreColor(sc)
        },
      })
    }

    function drawHud(ctx, W, H, dt) {
      const pct = Math.round(g.smooth * 100)
      const col = scoreColor(g.smooth)

      // Match ring
      const r = 46
      const cx = W - 78
      const cy = 82
      ctx.save()
      ctx.lineWidth = 10
      ctx.strokeStyle = 'rgba(255,255,255,0.10)'
      ctx.beginPath()
      ctx.arc(cx, cy, r, 0, Math.PI * 2)
      ctx.stroke()
      ctx.strokeStyle = col
      ctx.shadowColor = col
      ctx.shadowBlur = 18
      ctx.lineCap = 'round'
      ctx.beginPath()
      ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * g.smooth)
      ctx.stroke()
      ctx.shadowBlur = 0
      ctx.fillStyle = '#fff'
      ctx.textAlign = 'center'
      ctx.font = '600 26px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(pct + '%', cx, cy + 6)
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.55)'
      ctx.fillText('match', cx, cy + 24)
      ctx.restore()

      // Hold-to-lock arc under the ring
      if (g.holdFor > 0) {
        ctx.save()
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 4
        ctx.lineCap = 'round'
        ctx.beginPath()
        ctx.arc(cx, cy, r + 12, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(1, g.holdFor / LOCK_HOLD))
        ctx.stroke()
        ctx.restore()
      }

      // Time bar
      const barW = W * 0.5
      const bx = W * 0.25
      const frac = Math.max(0, g.timeLeft / SECONDS_PER_POSE)
      ctx.save()
      ctx.fillStyle = 'rgba(255,255,255,0.10)'
      ctx.fillRect(bx, H - 26, barW, 6)
      ctx.fillStyle = frac < 0.25 ? '#FF7A45' : '#7C5CFF'
      ctx.fillRect(bx, H - 26, barW * frac, 6)
      ctx.restore()

      // Lock-in burst
      if (g.celebrate > 0) {
        g.celebrate = Math.max(0, g.celebrate - dt * 1.6)
        ctx.save()
        ctx.globalAlpha = g.celebrate
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 6
        ctx.beginPath()
        ctx.arc(W / 2, H / 2, (1 - g.celebrate) * H * 0.8, 0, Math.PI * 2)
        ctx.stroke()
        ctx.restore()
      }
    }

    let lastKey = ''
    function syncUi(target) {
      const next = {
        phase: g.phase,
        poseName: target ? target.name : '',
        hint: target ? target.hint : '',
        match: Math.round(g.smooth * 100),
        index: g.index,
        score: g.score,
        timeLeft: Math.ceil(Math.max(0, g.timeLeft)),
        locked: g.holdFor > 0,
        visible: g.visible,
        results: g.results,
      }
      const key = [next.phase, next.poseName, next.index, next.score, next.timeLeft, next.visible].join('~')
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
  const ACCENT = '#7C5CFF'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase === 'playing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-6 animate-riseIn" key={ui.poseName}>
            <div className="text-[11px] uppercase tracking-[0.2em] text-white/45">
              Pose {Math.min(ui.index + 1, ROUND_POSES)} of {ROUND_POSES}
            </div>
            <div className="font-display text-3xl md:text-4xl font-700 mt-0.5">{ui.poseName}</div>
            <div className="text-white/60 text-sm mt-1 max-w-[16rem]">{ui.hint}</div>
            <div className="mt-4 font-display text-2xl text-mint">
              <Odometer value={ui.score} />
            </div>
          </div>
          {!ui.visible && (
            <div className="pointer-events-none absolute inset-x-0 bottom-16 text-center">
              <span className="rounded-full bg-ember/20 border border-ember/40 px-4 py-2 text-ember text-sm animate-pulseSoft">
                Step back so your whole body is in frame
              </span>
            </div>
          )}
        </>
      )}

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'} />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Match the shape · hold it · bank it" accent={ACCENT}>Copy That</Title>
          <p className="text-white/70 mb-8 max-w-md text-center animate-riseIn" style={{ animationDelay: '90ms', animationFillMode: 'backwards' }}>
            A glowing figure strikes a pose. Copy it with your own body — your limbs turn green as
            they line up. Hold the shape for half a second to bank the points before the timer runs
            out. {ROUND_POSES} poses per round.
          </p>
          <Button accent={ACCENT} onClick={start}>Start round</Button>
          <p className="text-muted text-xs mt-5">Stand back about 2 metres so your legs are in frame.</p>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Round complete</p>
          <div className="font-display text-6xl font-700 text-mint mb-7 animate-pop">
            <Odometer value={ui.score} />
          </div>
          <Results
            accent={ACCENT}
            rows={ui.results.map((r) => ({ name: r.name, color: scoreColor(r.quality / 100), value: r.points, note: r.quality + '%' }))}
          />
          <Button accent={ACCENT} onClick={start} className="mt-8">Play again</Button>
        </Screen>
      )}
    </div>
  )
}
