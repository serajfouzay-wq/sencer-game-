import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { palmCenter, openness, handSpan, HAND_CONNECTIONS } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { createPunchDetector, spawnNpc, stepNpc, hitNpc, buildWave } from '../lib/combat.js'
import { createCamera, drawFloorGrid, drawCorridor, drawGroundShadow, fogAlpha, byDepth } from '../lib/scene3d.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'
import { limb, lighten, darken } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ACCENT = '#FF4D8D'
const MAX_HP = 100
const FLOOR_Y = 3.0

export default function Dojo() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 2,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', hp: MAX_HP, wave: 0, score: 0, combo: 0, kills: 0 })

  const g = useRef({
    phase: 'menu',
    cam: createCamera({ parallax: 1.2 }),
    bloom: createBloom(0.5),
    tracker: createTracker({ maxDist: 0.3, maxAge: 400 }),
    punch: [createPunchDetector(), createPunchDetector()],
    npcs: [],
    hits: [],
    wave: 0,
    waveAt: 0,
    hp: MAX_HP,
    score: 0,
    kills: 0,
    combo: 0,
    comboAt: 0,
    guard: 0,
    playerX: 0,
    hurt: 0,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    Object.assign(g, {
      phase: 'fighting', npcs: [], hits: [], wave: 0, waveAt: 0,
      hp: MAX_HP, score: 0, kills: 0, combo: 0, guard: 0, playerX: 0, hurt: 0, logged: false,
    })
    g.cam.reset()
    g.punch.forEach((p) => p.reset())
    nextWave(performance.now())
    playMusic('dance')
  }

  function nextWave(now) {
    g.wave += 1
    g.waveAt = now
    for (const s of buildWave(g.wave)) g.npcs.push(spawnNpc(s.kind, s.lane, s.z))
    sfx.whoosh()
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

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now).slice(0, 2)

      // Hands drive the camera as well as the fists: moving bodily left shifts
      // the viewpoint, which is what makes the arena feel like a real space.
      if (tracks.length) {
        const avgX = tracks.reduce((a, t) => a + t.x, 0) / tracks.length
        const avgY = tracks.reduce((a, t) => a + t.y, 0) / tracks.length
        g.cam.track(avgX, avgY, dt)
        g.playerX = (avgX - 0.5) * 5
      } else {
        g.cam.track(0.5, 0.55, dt)
      }

      const hands = tracks.map((t) => ({ ...t, lm: t.data }))
      const openCount = hands.filter((h) => h.lm && openness(h.lm) > 0.45).length
      g.guard = openCount >= 2 ? Math.min(1, g.guard + dt * 6) : Math.max(0, g.guard - dt * 5)

      if (g.phase === 'fighting') runFight(dt, now, hands)
      draw(ctx, W, H, dt, now, hands)
      sync()
    }

    function runFight(dt, now, hands) {
      // Punches
      hands.forEach((h, i) => {
        const det = g.punch[i]
        if (!det) return
        const r = det.update(h.lm, now)
        if (r.punching && g.guard < 0.5) throwPunch(h, now, r.power)
      })
      // Detectors for hands that vanished must forget their history.
      for (let i = hands.length; i < g.punch.length; i++) g.punch[i].reset()

      const player = { x: g.playerX }
      for (const npc of [...g.npcs]) {
        const ev = stepNpc(npc, dt, now, player)
        if (ev === 'strike') resolveEnemyStrike(npc, now)
        if (ev === 'windup') sfx.tick()
        if (ev === 'gone') g.npcs = g.npcs.filter((n) => n !== npc)
      }

      for (const h of g.hits) h.life -= dt * 1.8
      g.hits = g.hits.filter((h) => h.life > 0)
      g.hurt = Math.max(0, g.hurt - dt * 1.6)

      if (now - g.comboAt > 2600 && g.combo) g.combo = 0

      const alive = g.npcs.filter((n) => n.state !== 'dead')
      if (!alive.length && now - g.waveAt > 900) nextWave(now)

      if (g.hp <= 0) {
        g.hp = 0
        g.phase = 'over'
        stopMusic()
        sfx.lose()
        if (!g.logged) {
          g.logged = true
          addSession({ game: 'dojo', score: g.score, detail: `wave ${g.wave} · ${g.kills} downed` })
        }
      }
    }

    function throwPunch(hand, now, power) {
      // The nearest enemy inside arm's reach, roughly in front of that fist.
      const aimX = (hand.x - 0.5) * 6
      let best = null
      let bestZ = Infinity
      for (const npc of g.npcs) {
        if (npc.state === 'dead') continue
        if (npc.z > 4.6) continue
        if (Math.abs(npc.x - aimX) > 2.4) continue
        if (npc.z < bestZ) { bestZ = npc.z; best = npc }
      }
      if (!best) {
        sfx.whoosh()
        return
      }
      const dmg = 1 + (power > 0.75 ? 1 : 0)
      const killed = hitNpc(best, dmg, now)
      g.combo += 1
      g.comboAt = now
      g.score += (killed ? 120 : 40) + Math.min(g.combo, 12) * 10
      g.cam.kick(killed ? 0.9 : 0.5)
      g.hits.push({ x: best.x, z: best.z, life: 1, killed, power })
      if (killed) { g.kills += 1; sfx.crash() } else sfx.shot()
      if (g.combo > 1) sfx.combo(g.combo)
    }

    function resolveEnemyStrike(npc, now) {
      const dodged = Math.abs(npc.x - g.playerX) > 1.9
      if (dodged) { sfx.whoosh(); return }
      if (g.guard > 0.5) {
        g.hp -= Math.round(npc.damage * 0.25)
        g.cam.kick(0.4)
        sfx.ricochet()
      } else {
        g.hp -= npc.damage
        g.hurt = 1
        g.combo = 0
        g.cam.kick(1.1)
        sfx.miss()
      }
    }

    /* ------------------------------ rendering ----------------------------- */

    function draw(ctx, W, H, dt, now, hands) {
      const cam = g.cam
      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#12061F')
      sky.addColorStop(0.55, '#1E0A2E')
      sky.addColorStop(1, '#07040F')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.14,
          grade: 'grayscale(0.9) brightness(0.4) contrast(1.3)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const layers = bctx ? [ctx, bctx] : [ctx]

      for (const c of layers) {
        drawCorridor(c, cam, W, H, { radius: 7.5, spacing: 5, count: 11, color: '#7C5CFF', roll: now * 0.00008 })
        drawFloorGrid(c, cam, W, H, { y: FLOOR_Y, depth: 48, step: 3.5, color: ACCENT })
      }

      // Far to near so nearer fighters occlude the ones behind them.
      const order = [...g.npcs].sort(byDepth)
      for (const npc of order) {
        drawGroundShadow(ctx, cam, W, H, npc.x, npc.z, npc.size * 2.2, FLOOR_Y)
        for (const c of layers) drawFighter(c, cam, W, H, npc, now)
      }

      for (const h of g.hits) for (const c of layers) drawImpact(c, cam, W, H, h)
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 12, alpha: 0.6 })

      if (g.guard > 0.05) drawGuard(ctx, W, H, g.guard, now)
      drawFists(ctx, W, H, hands)
      drawVignette(ctx, W, H, 0.55)

      if (g.hurt > 0) {
        ctx.save()
        ctx.globalAlpha = g.hurt * 0.45
        const v = ctx.createRadialGradient(W / 2, H / 2, Math.min(W, H) * 0.25, W / 2, H / 2, Math.max(W, H) * 0.7)
        v.addColorStop(0, 'rgba(255,0,60,0)')
        v.addColorStop(1, 'rgba(255,0,60,1)')
        ctx.fillStyle = v
        ctx.fillRect(0, 0, W, H)
        ctx.restore()
      }
      if (g.phase === 'fighting') drawHud(ctx, W, H, now)
    }

    function drawFighter(ctx, cam, W, H, npc, now) {
      const head = cam.project({ x: npc.x, y: FLOOR_Y - 2.5 * npc.size, z: npc.z }, W, H)
      const foot = cam.project({ x: npc.x, y: FLOOR_Y, z: npc.z }, W, H)
      if (!head || !foot) return
      const a = fogAlpha(npc.z, 6, 40) * (npc.fade ?? 1)
      if (a <= 0.02) return

      const h = foot.y - head.y
      if (h < 4) return
      const unit = h / 7
      const cx = head.x
      const wind = npc.state === 'windup'
        ? Math.min(1, (now - npc.stateAt) / npc.windup)
        : 0
      const striking = npc.state === 'strike'
      const bob = Math.sin(npc.bob) * unit * 0.16
      const col = npc.flash > 0.1 ? '#FFFFFF' : npc.color

      ctx.save()
      ctx.globalAlpha = a
      if (npc.state === 'dead') ctx.globalAlpha = a * 0.7

      const shoulderY = head.y + unit * 1.5 + bob
      const hipY = head.y + unit * 4 + bob
      const sw = unit * 1.15
      const lS = { x: cx - sw, y: shoulderY }
      const rS = { x: cx + sw, y: shoulderY }
      const lH = { x: cx - sw * 0.7, y: hipY }
      const rH = { x: cx + sw * 0.7, y: hipY }

      // Legs
      limb(ctx, lH, { x: cx - sw * 0.8, y: foot.y }, unit * 0.34, unit * 0.22, darken(col, 0.5))
      limb(ctx, rH, { x: cx + sw * 0.8, y: foot.y }, unit * 0.34, unit * 0.22, darken(col, 0.5))

      // Torso
      ctx.beginPath()
      ctx.moveTo(lS.x, lS.y); ctx.lineTo(rS.x, rS.y); ctx.lineTo(rH.x, rH.y); ctx.lineTo(lH.x, lH.y)
      ctx.closePath()
      const tg = ctx.createLinearGradient(0, shoulderY, 0, hipY)
      tg.addColorStop(0, lighten(col, 0.15))
      tg.addColorStop(1, darken(col, 0.4))
      ctx.fillStyle = tg
      ctx.fill()

      // Arms — one cocks back on the windup, then drives at the camera.
      const reach = striking ? 1.5 : wind * -0.6
      const armEnd = { x: cx + sw * 2.1, y: shoulderY + unit * (1.4 - reach * 1.2) }
      const armEndL = { x: cx - sw * 1.5, y: shoulderY + unit * 1.7 }
      limb(ctx, rS, armEnd, unit * 0.3, unit * (striking ? 0.6 : 0.22), lighten(col, 0.1))
      limb(ctx, lS, armEndL, unit * 0.3, unit * 0.2, darken(col, 0.25))

      // Head
      ctx.fillStyle = lighten(col, 0.25)
      ctx.beginPath()
      ctx.arc(cx, head.y + unit * 0.7 + bob, unit * 0.75, 0, Math.PI * 2)
      ctx.fill()
      ctx.fillStyle = '#0A0A12'
      ctx.beginPath()
      ctx.ellipse(cx, head.y + unit * 0.65 + bob, unit * 0.5, unit * 0.2, 0, 0, Math.PI * 2)
      ctx.fill()

      // Health pip
      if (npc.state !== 'dead' && npc.hp < npc.maxHp) {
        const bw = unit * 2.4
        ctx.fillStyle = 'rgba(0,0,0,0.5)'
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.6, bw, unit * 0.28)
        ctx.fillStyle = col
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.6, bw * (npc.hp / npc.maxHp), unit * 0.28)
      }

      // Windup telegraph — the player needs a readable warning.
      if (wind > 0.15) {
        ctx.strokeStyle = `rgba(255,80,80,${0.3 + wind * 0.6})`
        ctx.lineWidth = 2 + wind * 3
        ctx.beginPath()
        ctx.arc(cx, (shoulderY + hipY) / 2, unit * (2.4 + wind * 1.6), 0, Math.PI * 2)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawImpact(ctx, cam, W, H, hit) {
      const p = cam.project({ x: hit.x, y: FLOOR_Y - 1.6, z: hit.z }, W, H)
      if (!p) return
      const r = (1 - hit.life) * 90 * p.s * 0.1 + 18
      ctx.save()
      ctx.globalAlpha = hit.life
      ctx.strokeStyle = hit.killed ? '#FFFFFF' : '#FFD36E'
      ctx.lineWidth = 4 * hit.life
      ctx.beginPath()
      ctx.arc(p.x, p.y, r, 0, Math.PI * 2)
      ctx.stroke()
      for (let i = 0; i < 8; i++) {
        const a = (i / 8) * Math.PI * 2
        ctx.beginPath()
        ctx.moveTo(p.x + Math.cos(a) * r, p.y + Math.sin(a) * r)
        ctx.lineTo(p.x + Math.cos(a) * r * 1.5, p.y + Math.sin(a) * r * 1.5)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawGuard(ctx, W, H, amount, now) {
      ctx.save()
      ctx.globalAlpha = amount * 0.55
      const g2 = ctx.createRadialGradient(W / 2, H * 0.6, 40, W / 2, H * 0.6, Math.max(W, H) * 0.55)
      g2.addColorStop(0, 'rgba(0,229,176,0)')
      g2.addColorStop(0.75, 'rgba(0,229,176,0.22)')
      g2.addColorStop(1, 'rgba(0,229,176,0.5)')
      ctx.fillStyle = g2
      ctx.fillRect(0, 0, W, H)
      ctx.strokeStyle = `rgba(140,255,225,${0.3 + Math.sin(now * 0.01) * 0.15})`
      ctx.lineWidth = 3
      ctx.beginPath()
      ctx.ellipse(W / 2, H * 0.6, W * 0.42, H * 0.46, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()
    }

    function drawFists(ctx, W, H, hands) {
      for (const h of hands) {
        if (!h.lm) continue
        const lm = h.lm
        const pt = (k) => ({
          x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
          y: lm[k].y * H,
        })
        const span = handSpan(lm)
        const near = Math.min(1, Math.max(0, (span - 0.06) / 0.12))
        ctx.save()
        ctx.globalAlpha = 0.55 + near * 0.45
        ctx.strokeStyle = openness(lm) > 0.45 ? '#00E5B0' : '#FFD36E'
        ctx.lineWidth = 3 + near * 5
        ctx.lineCap = 'round'
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

    function drawHud(ctx, W, H, now) {
      ctx.save()
      // Health
      const bw = Math.min(360, W * 0.4)
      ctx.fillStyle = 'rgba(255,255,255,0.12)'
      ctx.fillRect(24, 26, bw, 14)
      const frac = Math.max(0, g.hp / MAX_HP)
      ctx.fillStyle = frac > 0.5 ? '#00E5B0' : frac > 0.25 ? '#FFB000' : '#FF4D8D'
      ctx.fillRect(24, 26, bw * frac, 14)
      ctx.strokeStyle = 'rgba(255,255,255,0.25)'
      ctx.lineWidth = 1
      ctx.strokeRect(24, 26, bw, 14)
      ctx.fillStyle = '#8A8AA0'
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillText('HEALTH', 24, 58)

      ctx.textAlign = 'right'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(g.score), W - 24, 46)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`WAVE ${g.wave}`, W - 24, 66)

      if (g.combo > 1) {
        ctx.textAlign = 'center'
        ctx.fillStyle = '#FFD36E'
        ctx.font = '700 26px "Space Grotesk", system-ui, sans-serif'
        ctx.fillText(`${g.combo} HIT`, W / 2, 48)
      }
      ctx.restore()
    }

    let lastKey = ''
    function sync() {
      const next = { phase: g.phase, hp: Math.max(0, g.hp), wave: g.wave, score: g.score, combo: g.combo, kills: g.kills }
      const key = JSON.stringify(next)
      if (key !== lastKey) { lastKey = key; setUi(next) }
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

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="They come to you · you are the camera" accent={ACCENT}>Shadow Dojo</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="fist" title="Punch the air toward the lens" body="A fist thrown at the camera lands on whatever is in front of it. Fast, committed jabs hit hardest." delay={80} />
            <HowTo glyph="openPalm" title="Both palms up to guard" body="Blocks most of the damage, but you cannot punch while guarding." delay={160} />
            <HowTo glyph="wave" title="Move sideways to dodge" body="Step out of a fighter's line and the strike misses completely. The room moves with you." delay={240} />
          </div>
          <p className="text-white/65 mb-7 text-center max-w-md text-sm">
            A red ring means someone is about to swing. Waves get bigger and the brutes take more
            than one clean hit.
          </p>
          <Button accent={ACCENT} onClick={start}>Enter the dojo</Button>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">You went down</p>
          <div className="font-display text-7xl font-700 mb-2 animate-pop" style={{ color: ACCENT }}>
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">Wave {ui.wave} · {ui.kills} fighters downed</p>
          <Button accent={ACCENT} onClick={start}>Back in</Button>
        </Screen>
      )}
    </div>
  )
}
