import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { leanOf, crouchOf } from '../lib/combat.js'
import { createCamera, drawCorridor, fogAlpha, byDepth } from '../lib/scene3d.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette, drawFrameGuide } from '../lib/render.js'
import { withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ACCENT = '#00D4FF'
const TUNNEL_R = 5.0
const SPAWN_Z = 60

export default function Rift() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'pose',
    numPoses: 1,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', score: 0, dist: 0, shield: 3, visible: true })

  const g = useRef({
    phase: 'menu',
    cam: createCamera({ parallax: 1.35, ease: 8 }),
    bloom: createBloom(0.5),
    obstacles: [],
    motes: [],
    shards: [],
    x: 0,
    y: 0,
    lean: 0,
    crouch: 0,
    speed: 15,
    dist: 0,
    score: 0,
    shield: 3,
    invuln: 0,
    spawnZ: SPAWN_Z,
    visible: false,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    Object.assign(g, {
      phase: 'flying', obstacles: [], shards: [], x: 0, y: 0, lean: 0, crouch: 0,
      speed: 15, dist: 0, score: 0, shield: 3, invuln: 0, spawnZ: SPAWN_Z, logged: false,
    })
    g.cam.reset()
    playMusic('space')
  }

  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    if (!g.motes.length) {
      for (let i = 0; i < 90; i++) {
        const a = Math.random() * Math.PI * 2
        g.motes.push({
          a, r: TUNNEL_R * (0.55 + Math.random() * 0.4), z: Math.random() * SPAWN_Z,
        })
      }
    }

    function frame(now) {
      raf = requestAnimationFrame(frame)
      const { W, H } = logicalSize(canvas)
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.05) : 0
      g.lastTime = now

      const res = status === 'ready' ? detect(now) : null
      const person = res && res.landmarks && res.landmarks.length ? res.landmarks[0] : null
      g.visible = !!person

      if (person) {
        const targetLean = leanOf(person, settings.mirror)
        const targetCrouch = crouchOf(person)
        g.lean += (targetLean - g.lean) * Math.min(1, dt * 8)
        g.crouch += (targetCrouch - g.crouch) * Math.min(1, dt * 8)
        // The head also drives the camera, so looking around peeks round corners.
        const head = person[0]
        if (head) {
          const hx = settings.mirror ? 1 - head.x : head.x
          g.cam.track(hx, head.y, dt)
        }
      } else {
        g.lean *= 1 - Math.min(1, dt * 3)
        g.crouch *= 1 - Math.min(1, dt * 3)
        g.cam.track(0.5, 0.55, dt)
      }

      if (g.phase === 'flying') step(dt, now)
      draw(ctx, W, H, dt, now)
      sync()
    }

    function step(dt, now) {
      // Lean steers, crouch drops you under the high bars.
      g.x += (g.lean * 3.1 - g.x) * Math.min(1, dt * 6)
      g.y += ((g.crouch * 2.2 - 0.4) - g.y) * Math.min(1, dt * 7)
      g.x = Math.max(-TUNNEL_R * 0.72, Math.min(TUNNEL_R * 0.72, g.x))

      g.speed += dt * 0.55
      const travel = g.speed * dt
      g.dist += travel
      g.score += travel * 2
      g.invuln = Math.max(0, g.invuln - dt)

      for (const m of g.motes) {
        m.z -= travel
        if (m.z < 1) { m.z += SPAWN_Z; m.a = Math.random() * Math.PI * 2 }
      }

      // Spawn gates: a wall with a hole, or a bar to duck under.
      g.spawnZ -= travel
      if (g.spawnZ < 30) {
        const kind = Math.random()
        const z = 60
        if (kind < 0.42) {
          g.obstacles.push({ type: 'gap', z, gapX: (Math.random() - 0.5) * 5.4, gapW: Math.max(1.5, 2.9 - g.dist / 900), hit: false })
        } else if (kind < 0.72) {
          g.obstacles.push({ type: 'bar', z, y: -1.9, hit: false })
        } else {
          g.obstacles.push({ type: 'shard', z, x: (Math.random() - 0.5) * 6.5, y: -0.4 + (Math.random() - 0.5) * 2, taken: false })
        }
        g.spawnZ = 60 - Math.max(7, 15 - g.dist / 260)
      }

      for (const o of g.obstacles) o.z -= travel

      for (const o of g.obstacles) {
        if (o.z > 1.4 || o.z < -1.4) continue
        if (o.type === 'shard') {
          if (!o.taken && Math.abs(o.x - g.x) < 1.5 && Math.abs(o.y - g.y) < 1.5) {
            o.taken = true
            g.score += 250
            sfx.pick()
            g.shards.push({ life: 1 })
          }
          continue
        }
        if (o.hit) continue
        let crash = false
        if (o.type === 'gap') crash = Math.abs(g.x - o.gapX) > o.gapW / 2
        if (o.type === 'bar') crash = g.y < o.y + 1.15
        if (crash) {
          o.hit = true
          if (g.invuln <= 0) {
            g.shield -= 1
            g.invuln = 1.4
            g.cam.kick(1.2)
            sfx.crash()
          }
        }
      }
      g.obstacles = g.obstacles.filter((o) => o.z > -3)
      for (const s of g.shards) s.life -= dt * 1.5
      g.shards = g.shards.filter((s) => s.life > 0)

      if (g.shield <= 0) {
        g.phase = 'over'
        stopMusic()
        sfx.lose()
        if (!g.logged) {
          g.logged = true
          addSession({ game: 'rift', score: Math.round(g.score), detail: `${Math.round(g.dist)}m` })
        }
      }
    }

    /* ------------------------------ rendering ----------------------------- */

    function draw(ctx, W, H, dt, now) {
      const cam = g.cam
      ctx.fillStyle = '#03030A'
      ctx.fillRect(0, 0, W, H)
      const glow = ctx.createRadialGradient(W / 2, H / 2, 10, W / 2, H / 2, Math.max(W, H) * 0.6)
      glow.addColorStop(0, 'rgba(0,120,180,0.35)')
      glow.addColorStop(1, 'rgba(0,0,0,0)')
      ctx.fillStyle = glow
      ctx.fillRect(0, 0, W, H)

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.12,
          grade: 'grayscale(0.95) brightness(0.4) contrast(1.3)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const layers = bctx ? [ctx, bctx] : [ctx]

      // The tunnel is drawn relative to the player, so steering banks the world.
      for (const c of layers) {
        drawCorridor(c, cam, W, H, {
          radius: TUNNEL_R, spacing: 4, count: 15, sides: 12,
          color: ACCENT, roll: now * 0.00012, z0: -(g.dist % 4),
        })
      }

      for (const m of g.motes) {
        const p = cam.project({ x: Math.cos(m.a) * m.r - g.x, y: Math.sin(m.a) * m.r - g.y, z: m.z }, W, H)
        if (!p) continue
        const a = fogAlpha(m.z, 4, SPAWN_Z)
        ctx.globalAlpha = a * 0.6
        ctx.fillStyle = '#9FE8FF'
        ctx.fillRect(p.x, p.y, 2 * p.s * 0.2 + 1, 2 * p.s * 0.2 + 1)
      }
      ctx.globalAlpha = 1

      for (const o of [...g.obstacles].sort(byDepth)) {
        for (const c of layers) drawObstacle(c, cam, W, H, o, now)
      }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 12, alpha: 0.6 })

      drawShip(ctx, W, H, now)
      drawVignette(ctx, W, H, 0.5)
      drawFrameGuide(ctx, W, H, g.visible, Math.sin(now * 0.006) * 0.5 + 0.5)
      if (g.phase === 'flying') drawHud(ctx, W, H)
      if (!g.visible && g.phase === 'flying') {
        ctx.save()
        ctx.textAlign = 'center'
        ctx.fillStyle = '#FF4D8D'
        ctx.font = '600 16px Inter, system-ui, sans-serif'
        ctx.fillText('Step back so your whole body is in frame', W / 2, H - 60)
        ctx.restore()
      }
    }

    function drawObstacle(ctx, cam, W, H, o, now) {
      const a = fogAlpha(o.z, 3, SPAWN_Z)
      if (a <= 0.02) return
      ctx.save()
      ctx.globalAlpha = a

      if (o.type === 'gap') {
        // Two slabs with a hole between them.
        const segs = [
          [-TUNNEL_R, o.gapX - o.gapW / 2],
          [o.gapX + o.gapW / 2, TUNNEL_R],
        ]
        for (const [x0, x1] of segs) {
          if (x1 - x0 <= 0.05) continue
          const tl = cam.project({ x: x0 - g.x, y: -TUNNEL_R - g.y, z: o.z }, W, H)
          const tr = cam.project({ x: x1 - g.x, y: -TUNNEL_R - g.y, z: o.z }, W, H)
          const br = cam.project({ x: x1 - g.x, y: TUNNEL_R - g.y, z: o.z }, W, H)
          const bl = cam.project({ x: x0 - g.x, y: TUNNEL_R - g.y, z: o.z }, W, H)
          if (!tl || !tr || !br || !bl) continue
          ctx.beginPath()
          ctx.moveTo(tl.x, tl.y); ctx.lineTo(tr.x, tr.y); ctx.lineTo(br.x, br.y); ctx.lineTo(bl.x, bl.y)
          ctx.closePath()
          ctx.fillStyle = o.hit ? 'rgba(255,77,141,0.35)' : withAlpha('#7C5CFF', 0.30)
          ctx.fill()
          ctx.strokeStyle = o.hit ? '#FF4D8D' : '#B06BFF'
          ctx.lineWidth = 2.5
          ctx.stroke()
        }
      } else if (o.type === 'bar') {
        const l = cam.project({ x: -TUNNEL_R - g.x, y: o.y - g.y, z: o.z }, W, H)
        const r = cam.project({ x: TUNNEL_R - g.x, y: o.y - g.y, z: o.z }, W, H)
        if (l && r) {
          ctx.strokeStyle = o.hit ? '#FF4D8D' : '#FFB000'
          ctx.lineWidth = Math.max(3, 22 * l.s * 0.05)
          ctx.lineCap = 'round'
          ctx.beginPath()
          ctx.moveTo(l.x, l.y)
          ctx.lineTo(r.x, r.y)
          ctx.stroke()
        }
      } else if (o.type === 'shard' && !o.taken) {
        const p = cam.project({ x: o.x - g.x, y: o.y - g.y, z: o.z }, W, H)
        if (p) {
          const r = Math.max(3, 26 * p.s * 0.05)
          const spin = now * 0.004
          ctx.translate(p.x, p.y)
          ctx.rotate(spin)
          ctx.fillStyle = '#00E5B0'
          ctx.beginPath()
          ctx.moveTo(0, -r); ctx.lineTo(r * 0.7, 0); ctx.lineTo(0, r); ctx.lineTo(-r * 0.7, 0)
          ctx.closePath()
          ctx.fill()
        }
      }
      ctx.restore()
    }

    function drawShip(ctx, W, H, now) {
      // A cockpit frame anchors the viewer inside the tunnel.
      const flash = g.invuln > 0 && Math.floor(now / 90) % 2 === 0
      ctx.save()
      ctx.globalAlpha = flash ? 0.35 : 0.85
      ctx.strokeStyle = flash ? '#FF4D8D' : ACCENT
      ctx.lineWidth = 3
      const cx = W / 2
      const cy = H * 0.78
      ctx.beginPath()
      ctx.moveTo(cx - 74, cy + 22)
      ctx.quadraticCurveTo(cx, cy - 26, cx + 74, cy + 22)
      ctx.stroke()
      ctx.globalAlpha = (flash ? 0.2 : 0.5)
      ctx.beginPath()
      ctx.moveTo(cx - 120, cy + 46)
      ctx.quadraticCurveTo(cx, cy - 8, cx + 120, cy + 46)
      ctx.stroke()
      // Crosshair sits where you actually are in the tunnel.
      ctx.globalAlpha = 0.7
      ctx.beginPath()
      ctx.arc(cx, H / 2, 8, 0, Math.PI * 2)
      ctx.moveTo(cx - 18, H / 2); ctx.lineTo(cx - 11, H / 2)
      ctx.moveTo(cx + 11, H / 2); ctx.lineTo(cx + 18, H / 2)
      ctx.stroke()
      ctx.restore()
    }

    function drawHud(ctx, W, H) {
      ctx.save()
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(Math.round(g.score)), 24, 46)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`${Math.round(g.dist)}m · ${Math.round(g.speed)} m/s`, 24, 66)

      for (let i = 0; i < 3; i++) {
        ctx.beginPath()
        ctx.arc(W - 36 - i * 26, 40, 8, 0, Math.PI * 2)
        ctx.fillStyle = i < g.shield ? ACCENT : 'rgba(255,255,255,0.15)'
        ctx.fill()
      }

      // Lean and crouch meters make the controls legible at a glance.
      const bx = W / 2 - 70
      ctx.fillStyle = 'rgba(255,255,255,0.10)'
      ctx.fillRect(bx, 28, 140, 5)
      ctx.fillStyle = ACCENT
      ctx.fillRect(bx + 70 + g.lean * 66 - 3, 26, 6, 9)
      ctx.fillStyle = '#8A8AA0'
      ctx.font = '500 10px Inter, system-ui, sans-serif'
      ctx.textAlign = 'center'
      ctx.fillText('LEAN', W / 2, 50)
      if (g.crouch > 0.2) {
        ctx.fillStyle = '#00E5B0'
        ctx.fillText('DUCKING', W / 2, 64)
      }
      ctx.restore()
    }

    let lastKey = ''
    function sync() {
      const next = {
        phase: g.phase, score: Math.round(g.score), dist: Math.round(g.dist),
        shield: Math.max(0, g.shield), visible: g.visible,
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
      {loading && <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'} />}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Your whole body flies the ship" accent={ACCENT}>The Rift</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="wave" title="Lean to steer" body="Shift your weight left or right and the tunnel banks with you. Line up with the hole in each wall." delay={80} />
            <HowTo glyph="fist" title="Crouch to duck" body="Drop low to slip under the amber bars — they run the full width, so leaning will not save you." delay={160} />
            <HowTo glyph="point" title="Move your head to look" body="The view is tied to your head, so you can lean in and peer down the tunnel ahead." delay={240} />
          </div>
          <p className="text-white/65 mb-7 text-center max-w-md text-sm">
            Three shields, and it only gets faster. Green shards are worth chasing.
          </p>
          <Button accent={ACCENT} onClick={start}>Enter the rift</Button>
          <p className="text-muted text-xs mt-5">Stand back about 2 metres, whole body in frame.</p>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Rift collapsed</p>
          <div className="font-display text-7xl font-700 mb-2 animate-pop" style={{ color: ACCENT }}>
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">{ui.dist} metres deep</p>
          <Button accent={ACCENT} onClick={start}>Dive again</Button>
        </Screen>
      )}
    </div>
  )
}
