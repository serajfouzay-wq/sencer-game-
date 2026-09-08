import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { palmCenter, isPointing, HAND_CONNECTIONS } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { spawnNpc, stepNpc, hitNpc, buildWave } from '../lib/combat.js'
import { recognizeShape, SPELLS } from '../lib/shapes.js'
import { createCamera, drawFloorGrid, drawGroundShadow, fogAlpha, byDepth } from '../lib/scene3d.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'
import { limb, lighten, darken, withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ACCENT = '#B06BFF'
const MAX_HP = 100
const FLOOR_Y = 3.0
const MAX_STROKE = 90

export default function Arcane() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 2,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', hp: MAX_HP, score: 0, wave: 0, spell: '', ward: 0 })

  const g = useRef({
    phase: 'menu',
    cam: createCamera({ parallax: 1.1 }),
    bloom: createBloom(0.5),
    tracker: createTracker({ maxDist: 0.3, maxAge: 350 }),
    stroke: [],
    drawing: false,
    lastCast: null,
    lastCastAt: 0,
    npcs: [],
    bolts: [],
    ward: 0,
    wardUntil: 0,
    hp: MAX_HP,
    score: 0,
    wave: 0,
    waveAt: 0,
    hurt: 0,
    runes: [],
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    Object.assign(g, {
      phase: 'casting', stroke: [], drawing: false, lastCast: null, npcs: [], bolts: [],
      ward: 0, wardUntil: 0, hp: MAX_HP, score: 0, wave: 0, waveAt: 0, hurt: 0, runes: [], logged: false,
    })
    g.cam.reset()
    nextWave(performance.now())
    playMusic('space')
  }

  function nextWave(now) {
    g.wave += 1
    g.waveAt = now
    for (const s of buildWave(g.wave)) g.npcs.push(spawnNpc(s.kind, s.lane, s.z + 12))
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
      const hands = tracks.map((t) => ({ ...t, lm: t.data }))

      if (hands.length) {
        const avg = hands.reduce((a, h) => a + h.x, 0) / hands.length
        g.cam.track(avg, 0.5, dt)
      } else {
        g.cam.track(0.5, 0.55, dt)
      }

      if (g.phase === 'casting') {
        handleCasting(hands, now)
        step(dt, now)
      }
      draw(ctx, W, H, dt, now, hands)
      sync()
    }

    function handleCasting(hands, now) {
      // The first pointing hand is the wand. Pointing draws, anything else
      // releases the stroke and casts whatever was drawn.
      const wand = hands.find((h) => h.lm && isPointing(h.lm))
      if (wand) {
        const tip = wand.lm[8]
        const p = { x: settings.mirror ? 1 - tip.x : tip.x, y: tip.y }
        if (!g.drawing) {
          g.drawing = true
          g.stroke = []
          sfx.penDown()
        }
        const last = g.stroke[g.stroke.length - 1]
        if (!last || Math.hypot(p.x - last.x, p.y - last.y) > 0.004) g.stroke.push(p)
        if (g.stroke.length > MAX_STROKE) g.stroke.shift()
      } else if (g.drawing) {
        g.drawing = false
        cast(g.stroke, now)
        g.stroke = []
      }
    }

    function cast(stroke, now) {
      const r = recognizeShape(stroke)
      if (!r.name) {
        g.lastCast = { name: null, label: 'fizzled', color: '#8A8AA0' }
        g.lastCastAt = now
        sfx.back()
        return
      }
      const spell = SPELLS[r.name]
      g.lastCast = { name: r.name, label: spell.label, color: spell.color }
      g.lastCastAt = now

      if (r.name === 'circle') {
        g.ward = 1
        g.wardUntil = now + 5000
        sfx.bank(1)
        g.runes.push({ kind: 'circle', life: 1, color: spell.color })
        return
      }

      const targets = [...g.npcs]
        .filter((n) => n.state !== 'dead')
        .sort((a, b) => a.z - b.z)

      if (!targets.length) { sfx.whoosh(); return }

      if (r.name === 'bolt') {
        const t = targets[0]
        g.bolts.push({ to: t, life: 1, color: spell.color, chain: false })
        applyDamage(t, spell.damage, now)
        sfx.shot()
      } else if (r.name === 'zigzag') {
        // Chain arcs through up to three of them.
        const chain = targets.slice(0, 3)
        chain.forEach((t, i) => {
          g.bolts.push({ to: t, from: i ? chain[i - 1] : null, life: 1, color: spell.color, chain: true })
          applyDamage(t, spell.damage, now)
        })
        sfx.ricochet()
      }
      g.runes.push({ kind: r.name, life: 1, color: spell.color })
    }

    function applyDamage(npc, dmg, now) {
      const killed = hitNpc(npc, dmg, now)
      g.score += killed ? 150 : 45
      g.cam.kick(killed ? 0.7 : 0.35)
      if (killed) sfx.crash()
    }

    function step(dt, now) {
      if (g.ward && now > g.wardUntil) g.ward = 0
      const player = { x: 0 }
      for (const npc of [...g.npcs]) {
        const ev = stepNpc(npc, dt, now, player)
        if (ev === 'strike') {
          if (g.ward) {
            g.ward = 0
            g.cam.kick(0.6)
            sfx.ricochet()
          } else {
            g.hp -= npc.damage
            g.hurt = 1
            g.cam.kick(1)
            sfx.miss()
          }
        }
        if (ev === 'gone') g.npcs = g.npcs.filter((n) => n !== npc)
      }

      for (const b of g.bolts) b.life -= dt * 2.6
      g.bolts = g.bolts.filter((b) => b.life > 0)
      for (const r of g.runes) r.life -= dt * 1.2
      g.runes = g.runes.filter((r) => r.life > 0)
      g.hurt = Math.max(0, g.hurt - dt * 1.6)

      const alive = g.npcs.filter((n) => n.state !== 'dead')
      if (!alive.length && now - g.waveAt > 900) nextWave(now)

      if (g.hp <= 0) {
        g.hp = 0
        g.phase = 'over'
        stopMusic()
        sfx.lose()
        if (!g.logged) {
          g.logged = true
          addSession({ game: 'arcane', score: g.score, detail: `wave ${g.wave}` })
        }
      }
    }

    /* ------------------------------ rendering ----------------------------- */

    function draw(ctx, W, H, dt, now, hands) {
      const cam = g.cam
      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#0B0524')
      sky.addColorStop(0.6, '#170A33')
      sky.addColorStop(1, '#05030E')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.13,
          grade: 'grayscale(0.9) brightness(0.4) contrast(1.3)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const layers = bctx ? [ctx, bctx] : [ctx]

      for (const c of layers) drawFloorGrid(c, cam, W, H, { y: FLOOR_Y, depth: 52, step: 4, color: ACCENT })

      for (const npc of [...g.npcs].sort(byDepth)) {
        drawGroundShadow(ctx, cam, W, H, npc.x, npc.z, npc.size * 2.2, FLOOR_Y)
        for (const c of layers) drawWraith(c, cam, W, H, npc, now)
      }
      for (const b of g.bolts) for (const c of layers) drawBolt(c, cam, W, H, b)
      if (g.ward) for (const c of layers) drawWard(c, W, H, now)
      for (const c of layers) drawStroke(c, W, H, now)
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 13, alpha: 0.65 })

      drawHands(ctx, W, H, hands)
      drawVignette(ctx, W, H, 0.55)

      if (g.hurt > 0) {
        ctx.save()
        ctx.globalAlpha = g.hurt * 0.4
        const v = ctx.createRadialGradient(W / 2, H / 2, Math.min(W, H) * 0.25, W / 2, H / 2, Math.max(W, H) * 0.7)
        v.addColorStop(0, 'rgba(255,0,60,0)')
        v.addColorStop(1, 'rgba(255,0,60,1)')
        ctx.fillStyle = v
        ctx.fillRect(0, 0, W, H)
        ctx.restore()
      }
      if (g.phase === 'casting') drawHud(ctx, W, H, now)
    }

    function drawWraith(ctx, cam, W, H, npc, now) {
      const head = cam.project({ x: npc.x, y: FLOOR_Y - 2.6 * npc.size, z: npc.z }, W, H)
      const foot = cam.project({ x: npc.x, y: FLOOR_Y, z: npc.z }, W, H)
      if (!head || !foot) return
      const a = fogAlpha(npc.z, 6, 46) * (npc.fade ?? 1)
      if (a <= 0.02) return
      const h = foot.y - head.y
      if (h < 4) return
      const unit = h / 7
      const cx = head.x
      const col = npc.flash > 0.1 ? '#FFFFFF' : npc.color
      const drift = Math.sin(npc.bob) * unit * 0.25

      ctx.save()
      ctx.globalAlpha = a * 0.92

      // A robed silhouette that tapers into smoke at the floor.
      const grd = ctx.createLinearGradient(0, head.y, 0, foot.y)
      grd.addColorStop(0, lighten(col, 0.2))
      grd.addColorStop(0.6, col)
      grd.addColorStop(1, withAlpha(darken(col, 0.6), 0))
      ctx.fillStyle = grd
      ctx.beginPath()
      ctx.moveTo(cx, head.y + drift)
      ctx.quadraticCurveTo(cx + unit * 1.9, head.y + unit * 3 + drift, cx + unit * 1.3, foot.y)
      ctx.quadraticCurveTo(cx, foot.y + unit * 0.4, cx - unit * 1.3, foot.y)
      ctx.quadraticCurveTo(cx - unit * 1.9, head.y + unit * 3 + drift, cx, head.y + drift)
      ctx.closePath()
      ctx.fill()

      // Hood and eyes
      ctx.fillStyle = '#0A0716'
      ctx.beginPath()
      ctx.ellipse(cx, head.y + unit * 1.1 + drift, unit * 0.85, unit * 0.95, 0, 0, Math.PI * 2)
      ctx.fill()
      const wind = npc.state === 'windup' ? Math.min(1, (now - npc.stateAt) / npc.windup) : 0
      ctx.fillStyle = wind > 0.1 ? '#FF4040' : '#FFE9A8'
      for (const s of [-1, 1]) {
        ctx.beginPath()
        ctx.ellipse(cx + s * unit * 0.32, head.y + unit * 1.05 + drift, unit * 0.16, unit * 0.1, 0, 0, Math.PI * 2)
        ctx.fill()
      }

      // Arms reach out on the windup
      if (wind > 0.1 || npc.state === 'strike') {
        const ext = npc.state === 'strike' ? 1 : wind
        for (const s of [-1, 1]) {
          limb(ctx,
            { x: cx + s * unit * 1.1, y: head.y + unit * 2.4 + drift },
            { x: cx + s * unit * (1.6 + ext * 1.4), y: head.y + unit * (2.6 - ext * 0.8) + drift },
            unit * 0.26, unit * 0.16, lighten(col, 0.3))
        }
        ctx.strokeStyle = `rgba(255,70,70,${0.25 + wind * 0.6})`
        ctx.lineWidth = 2 + wind * 3
        ctx.beginPath()
        ctx.arc(cx, head.y + unit * 2.8 + drift, unit * (2.2 + wind * 1.5), 0, Math.PI * 2)
        ctx.stroke()
      }

      if (npc.state !== 'dead' && npc.hp < npc.maxHp) {
        const bw = unit * 2.4
        ctx.fillStyle = 'rgba(0,0,0,0.5)'
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.8, bw, unit * 0.26)
        ctx.fillStyle = col
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.8, bw * (npc.hp / npc.maxHp), unit * 0.26)
      }
      ctx.restore()
    }

    function drawBolt(ctx, cam, W, H, b) {
      const t = b.to
      if (!t) return
      const p = cam.project({ x: t.x, y: FLOOR_Y - 1.6, z: Math.max(1, t.z) }, W, H)
      if (!p) return
      const from = b.from
        ? cam.project({ x: b.from.x, y: FLOOR_Y - 1.6, z: Math.max(1, b.from.z) }, W, H)
        : { x: W / 2, y: H * 0.82 }
      if (!from) return

      ctx.save()
      ctx.globalAlpha = b.life
      ctx.strokeStyle = b.color
      ctx.lineWidth = 3 + b.life * 4
      ctx.lineCap = 'round'
      ctx.beginPath()
      ctx.moveTo(from.x, from.y)
      // A jagged path reads as energy rather than a drawn line.
      const segs = 7
      for (let i = 1; i <= segs; i++) {
        const f = i / segs
        const jx = (Math.random() - 0.5) * 26 * (1 - Math.abs(f - 0.5) * 2) * b.life
        const jy = (Math.random() - 0.5) * 26 * (1 - Math.abs(f - 0.5) * 2) * b.life
        ctx.lineTo(from.x + (p.x - from.x) * f + jx, from.y + (p.y - from.y) * f + jy)
      }
      ctx.stroke()
      ctx.restore()
    }

    function drawWard(ctx, W, H, now) {
      ctx.save()
      const pulse = 0.5 + Math.sin(now * 0.005) * 0.5
      ctx.globalAlpha = 0.35 + pulse * 0.25
      ctx.strokeStyle = SPELLS.circle.color
      ctx.lineWidth = 4
      ctx.beginPath()
      ctx.ellipse(W / 2, H * 0.58, W * 0.36, H * 0.4, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.globalAlpha = 0.12 + pulse * 0.08
      const gg = ctx.createRadialGradient(W / 2, H * 0.58, 30, W / 2, H * 0.58, W * 0.4)
      gg.addColorStop(0, 'rgba(0,229,176,0)')
      gg.addColorStop(1, 'rgba(0,229,176,0.7)')
      ctx.fillStyle = gg
      ctx.fillRect(0, 0, W, H)
      ctx.restore()
    }

    function drawStroke(ctx, W, H, now) {
      if (g.stroke.length < 2) return
      ctx.save()
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      for (let i = 1; i < g.stroke.length; i++) {
        const a = i / g.stroke.length
        const p0 = g.stroke[i - 1]
        const p1 = g.stroke[i]
        ctx.globalAlpha = a
        ctx.strokeStyle = ACCENT
        ctx.lineWidth = 2 + a * 7
        ctx.beginPath()
        ctx.moveTo(p0.x * W, p0.y * H)
        ctx.lineTo(p1.x * W, p1.y * H)
        ctx.stroke()
      }
      const tip = g.stroke[g.stroke.length - 1]
      ctx.globalAlpha = 1
      ctx.fillStyle = '#FFFFFF'
      ctx.beginPath()
      ctx.arc(tip.x * W, tip.y * H, 5, 0, Math.PI * 2)
      ctx.fill()
      ctx.restore()
    }

    function drawHands(ctx, W, H, hands) {
      for (const h of hands) {
        if (!h.lm) continue
        const lm = h.lm
        const pt = (k) => ({
          x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
          y: lm[k].y * H,
        })
        ctx.save()
        ctx.globalAlpha = 0.4
        ctx.strokeStyle = isPointing(lm) ? ACCENT : '#8A8AA0'
        ctx.lineWidth = 2.5
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
      const bw = Math.min(340, W * 0.36)
      ctx.fillStyle = 'rgba(255,255,255,0.12)'
      ctx.fillRect(24, 26, bw, 14)
      const frac = Math.max(0, g.hp / MAX_HP)
      ctx.fillStyle = frac > 0.5 ? '#00E5B0' : frac > 0.25 ? '#FFB000' : '#FF4D8D'
      ctx.fillRect(24, 26, bw * frac, 14)
      ctx.fillStyle = '#8A8AA0'
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillText('LIFE', 24, 58)

      ctx.textAlign = 'right'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 32px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(g.score), W - 24, 46)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`WAVE ${g.wave}`, W - 24, 66)

      // What you just cast, so a fizzle is never a mystery.
      if (g.lastCast && now - g.lastCastAt < 1400) {
        const a = 1 - (now - g.lastCastAt) / 1400
        ctx.globalAlpha = a
        ctx.textAlign = 'center'
        ctx.fillStyle = g.lastCast.color
        ctx.font = '700 30px "Space Grotesk", system-ui, sans-serif'
        ctx.fillText(g.lastCast.label.toUpperCase(), W / 2, H * 0.3)
        ctx.globalAlpha = 1
      }

      // Spellbook along the bottom.
      ctx.textAlign = 'center'
      const book = [['line', 'Bolt', SPELLS.bolt.color], ['circle', 'Ward', SPELLS.circle.color], ['zigzag', 'Chain', SPELLS.zigzag.color]]
      book.forEach((b, i) => {
        const x = W / 2 + (i - 1) * 150
        const y = H - 40
        ctx.strokeStyle = b[2]
        ctx.globalAlpha = 0.85
        ctx.lineWidth = 2.5
        ctx.beginPath()
        if (b[0] === 'line') { ctx.moveTo(x - 22, y + 6); ctx.lineTo(x + 22, y - 6) }
        else if (b[0] === 'circle') { ctx.arc(x, y, 15, 0, Math.PI * 2) }
        else {
          ctx.moveTo(x - 24, y)
          for (let k = 1; k <= 4; k++) ctx.lineTo(x - 24 + k * 12, y + (k % 2 ? -9 : 9))
        }
        ctx.stroke()
        ctx.globalAlpha = 0.65
        ctx.fillStyle = b[2]
        ctx.font = '600 11px Inter, system-ui, sans-serif'
        ctx.fillText(b[1], x, y + 32)
      })
      ctx.restore()
    }

    let lastKey = ''
    function sync() {
      const next = {
        phase: g.phase, hp: Math.max(0, g.hp), score: g.score, wave: g.wave,
        spell: g.lastCast ? g.lastCast.label : '', ward: g.ward,
      }
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
          <Title kicker="Write the shape · release the spell" accent={ACCENT}>Arcane</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="point" title="Point to draw" body="Your fingertip leaves a trail in the air. Lower your hand or open it to release and cast." delay={80} />
            <HowTo glyph="gun" title="A straight line is a Bolt" body="Strikes the nearest wraith hard. Any direction works." delay={160} />
            <HowTo glyph="openPalm" title="A circle is a Ward" body="Raises a shield that absorbs the next strike aimed at you." delay={240} />
            <HowTo glyph="wave" title="A zigzag is a Chain" body="Arcs through up to three wraiths at once — best when they cluster." delay={320} />
          </div>
          <Button accent={ACCENT} onClick={start}>Begin the rite</Button>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Overwhelmed</p>
          <div className="font-display text-7xl font-700 mb-2 animate-pop" style={{ color: ACCENT }}>
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">Survived to wave {ui.wave}</p>
          <Button accent={ACCENT} onClick={start}>Cast again</Button>
        </Screen>
      )}
    </div>
  )
}
