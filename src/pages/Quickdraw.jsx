import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { assignPlayers, HAND_CONNECTIONS, BELT_Y } from '../lib/gestures.js'
import { useCanvasSize, logicalSize, drawRevolver, drawMuzzleFlash } from '../lib/canvas.js'
import { drawVignette } from '../lib/render.js'
import { drawGunslinger } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen } from '../components/ui.jsx'

const WINS_NEEDED = 3
const P_COLORS = ['#FFB000', '#00D4FF']
const P_NAMES = ['Player 1', 'Player 2']

// Phases: 'menu' | 'holster' | 'steady' | 'draw' | 'round' | 'match'
export default function Quickdraw() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 2,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({
    phase: 'menu',
    wins: [0, 0],
    message: '',
    sub: '',
    winner: null,
    reaction: null,
    falseStart: false,
    present: [false, false],
  })

  const vsCpuRef = useRef(false)
  const g = useRef({
    phase: 'menu',
    wins: [0, 0],
    holsterSince: 0,
    steadyUntil: 0,
    drawAt: 0,
    roundEndsAt: 0,
    winner: null,
    reaction: null,
    falseStart: false,
    cpuReaction: 400,
    shake: 0,
    flash: [0, 0],
    lift: [0, 0],
    lastTime: 0,
    logged: false,
  }).current

  function setPhase(next, patch = {}) {
    g.phase = next
    Object.assign(g, patch)
  }

  // The render loop rewrites React state from `g` every frame, so anything the
  // UI changes has to change `g` too or it snaps straight back.
  function toMenu() {
    g.wins = [0, 0]
    g.winner = null
    g.reaction = null
    g.falseStart = false
    setPhase('menu', { holsterSince: 0 })
  }

  function start(vsCpu) {
    vsCpuRef.current = vsCpu
    g.wins = [0, 0]
    g.winner = null
    g.reaction = null
    g.falseStart = false
    g.logged = false
    playMusic('western')
    setPhase('holster', { holsterSince: 0 })
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
      const hands = res && res.landmarks ? res.landmarks : []
      const players = assignPlayers(hands, settings.mirror)

      // Player 2 is simulated when duelling the machine.
      if (vsCpuRef.current) {
        const cpuFired =
          g.phase === 'draw' && now - g.drawAt >= g.cpuReaction
        players[1] = {
          cpu: true,
          holstered: true,
          raised: false,
          gun: cpuFired,
          cocked: g.phase === 'steady' || g.phase === 'draw',
          firing: cpuFired,
          sx: 0.75,
          sy: cpuFired ? 0.42 : 0.72,
          aim: { x: -1, y: -0.1 },
          lm: null,
        }
      }

      runLogic(now, players)
      render(ctx, W, H, now, dt, players)
    }

    function runLogic(now, players) {
      const p1 = players[0]
      const p2 = players[1]
      const both = !!p1 && !!p2

      if (g.phase === 'holster') {
        const ready = both && p1.holstered && p2.holstered
        if (!ready) {
          g.holsterSince = 0
        } else if (!g.holsterSince) {
          g.holsterSince = now
        } else if (now - g.holsterSince > 900) {
          // Random tension window so nobody can time the draw.
          sfx.holster()
          setPhase('steady', {
            steadyUntil: now + 1400 + Math.random() * 2600,
            cpuReaction: 260 + Math.random() * 340,
          })
        }
        return
      }

      if (g.phase === 'steady') {
        // Twitch before the call and you lose the round.
        for (let i = 0; i < 2; i++) {
          const p = players[i]
          if (p && !p.cpu && p.raised) {
            g.flash[i] = 0
            sfx.ricochet()
            awardRound(1 - i, null, true)
            return
          }
        }
        if (!both) {
          setPhase('holster', { holsterSince: 0 })
          return
        }
        if (now >= g.steadyUntil) { sfx.go(); setPhase('draw', { drawAt: now }) }
        return
      }

      if (g.phase === 'draw') {
        for (let i = 0; i < 2; i++) {
          const p = players[i]
          if (p && p.firing) {
            g.flash[i] = 1
            g.shake = 1
            sfx.shot()
            awardRound(i, Math.round(now - g.drawAt), false)
            return
          }
        }
        return
      }

      if (g.phase === 'round' && now >= g.roundEndsAt) {
        if (g.wins[0] >= WINS_NEEDED || g.wins[1] >= WINS_NEEDED) {
          setPhase('match')
          stopMusic()
          sfx.win()
          if (!g.logged) {
            g.logged = true
            const champ = g.wins[0] > g.wins[1] ? 0 : 1
            addSession({
              game: 'quickdraw',
              score: g.wins[champ],
              detail: `${P_NAMES[champ]} won ${g.wins[0]}–${g.wins[1]}`,
              bestReaction: g.reaction,
            })
          }
        } else {
          setPhase('holster', { holsterSince: 0 })
        }
      }
    }

    function awardRound(winner, reaction, falseStart) {
      g.wins[winner] += 1
      g.winner = winner
      g.reaction = reaction
      g.falseStart = falseStart
      setPhase('round', { roundEndsAt: performance.now() + 2600 })
    }

    /* ------------------------------ rendering ------------------------------ */

    function render(ctx, W, H, now, dt, players) {
      ctx.save()
      if (g.shake > 0) {
        g.shake = Math.max(0, g.shake - dt * 3.5)
        const m = g.shake * 14
        ctx.translate((Math.random() - 0.5) * m, (Math.random() - 0.5) * m)
      }

      drawScene(ctx, W, H, now)

      const beltY = BELT_Y * H
      // Belt line
      ctx.save()
      ctx.setLineDash([10, 12])
      ctx.strokeStyle = 'rgba(255,225,180,0.4)'
      ctx.lineWidth = 2
      ctx.beginPath()
      ctx.moveTo(0, beltY)
      ctx.lineTo(W, beltY)
      ctx.stroke()
      ctx.setLineDash([])
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,225,180,0.65)'
      ctx.fillText('belt line — keep your hand below this', 16, beltY - 10)
      ctx.restore()

      // Centre divider
      ctx.strokeStyle = 'rgba(255,255,255,0.10)'
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(W / 2, 0)
      ctx.lineTo(W / 2, H)
      ctx.stroke()

      for (let i = 0; i < 2; i++) {
        drawPlayer(ctx, W, H, now, dt, players[i], i)
      }

      drawVignette(ctx, W, H, 0.5)
      drawScoreboard(ctx, W)
      ctx.restore()

      // React state only when something the UI cares about actually changed.
      syncUi(players)
    }

    function drawPlayer(ctx, W, H, now, dt, p, i) {
      const color = P_COLORS[i]
      const half = W / 2
      const x0 = i === 0 ? 0 : half
      const cx = x0 + half / 2

      // Hand skeleton
      if (p && p.lm && settings.showSkeleton) {
        const pt = (k) => ({
          x: (settings.mirror ? 1 - p.lm[k].x : p.lm[k].x) * W,
          y: p.lm[k].y * H,
        })
        ctx.save()
        ctx.strokeStyle = color
        ctx.globalAlpha = 0.85
        ctx.lineWidth = 3
        ctx.shadowColor = color
        ctx.shadowBlur = 14
        for (const [a, b] of HAND_CONNECTIONS) {
          const u = pt(a), v = pt(b)
          ctx.beginPath()
          ctx.moveTo(u.x, u.y)
          ctx.lineTo(v.x, v.y)
          ctx.stroke()
        }
        ctx.fillStyle = '#fff'
        ctx.shadowBlur = 0
        for (let k = 0; k < 21; k++) {
          const q = pt(k)
          ctx.beginPath()
          ctx.arc(q.x, q.y, 2.5, 0, Math.PI * 2)
          ctx.fill()
        }
        ctx.restore()

        // Aim beam once the gun is up
        if (p.gun) {
          const tip = pt(8)
          const dir = { x: settings.mirror ? -p.aim.x : p.aim.x, y: p.aim.y }
          ctx.save()
          ctx.globalAlpha = 0.5
          ctx.strokeStyle = color
          ctx.lineWidth = 2
          ctx.setLineDash([6, 8])
          ctx.beginPath()
          ctx.moveTo(tip.x, tip.y)
          ctx.lineTo(tip.x + dir.x * 900, tip.y + dir.y * 900)
          ctx.stroke()
          ctx.restore()
          if (g.flash[i] > 0) {
            drawMuzzleFlash(ctx, tip.x, tip.y, dir, g.flash[i], 1.2)
          }
        }
      }

      if (g.flash[i] > 0) g.flash[i] = Math.max(0, g.flash[i] - dt * 2.6)

      // Gunslinger, whose arm swings up as the player draws
      const target = p && p.gun ? 1 : 0
      g.lift[i] += (target - g.lift[i]) * Math.min(1, dt * 12)
      const facing = i === 0 ? 1 : -1
      const scale = Math.min(1.5, H / 460)
      const beaten = g.phase === 'round' && g.winner != null && g.winner !== i
      const hand = drawGunslinger(ctx, cx, H - 54, scale, {
        color: color,
        raise: g.lift[i],
        facing,
        cocked: !!(p && p.cocked),
        defeated: beaten,
        t: now,
      })
      drawRevolver(ctx, hand.x, hand.y, scale * 0.8, g.lift[i], facing, !!(p && p.cocked))
      if (g.flash[i] > 0 && !(p && p.lm)) {
        drawMuzzleFlash(ctx, hand.x + facing * 26 * scale, hand.y, { x: facing, y: -0.1 }, g.flash[i], scale)
      }

      // Nameplate
      ctx.save()
      ctx.textAlign = 'center'
      ctx.font = '600 15px "Space Grotesk", system-ui, sans-serif'
      ctx.fillStyle = color
      ctx.fillText(P_NAMES[i] + (i === 1 && vsCpuRef.current ? ' (machine)' : ''), cx, H - 36)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.55)'
      const state = !p
        ? 'show your hand'
        : p.cpu
          ? 'ready'
          : p.holstered
            ? 'holstered'
            : p.gun
              ? 'drawn'
              : 'hand up'
      ctx.fillText(state, cx, H - 18)
      ctx.restore()
    }

    function drawScoreboard(ctx, W) {
      const cx = W / 2
      ctx.save()
      ctx.textAlign = 'center'
      for (let i = 0; i < 2; i++) {
        for (let k = 0; k < WINS_NEEDED; k++) {
          const filled = g.wins[i] > k
          const dx = i === 0 ? cx - 46 - k * 22 : cx + 46 + k * 22
          ctx.beginPath()
          ctx.arc(dx, 34, 7, 0, Math.PI * 2)
          ctx.fillStyle = filled ? P_COLORS[i] : 'rgba(255,255,255,0.16)'
          ctx.fill()
        }
      }
      ctx.font = '600 13px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.5)'
      ctx.fillText('first to ' + WINS_NEEDED, cx, 38)
      ctx.restore()
    }

    function drawScene(ctx, W, H, now) {
      // Dusk sky
      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#2A1B4A')
      sky.addColorStop(0.42, '#7B3B6B')
      sky.addColorStop(0.66, '#D9683F')
      sky.addColorStop(0.78, '#F2A057')
      sky.addColorStop(1, '#2B1A18')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      // Sun
      const sunY = H * 0.62
      const sun = ctx.createRadialGradient(W / 2, sunY, 10, W / 2, sunY, H * 0.3)
      sun.addColorStop(0, 'rgba(255,236,180,0.95)')
      sun.addColorStop(0.35, 'rgba(255,180,90,0.5)')
      sun.addColorStop(1, 'rgba(255,140,60,0)')
      ctx.fillStyle = sun
      ctx.beginPath()
      ctx.arc(W / 2, sunY, H * 0.3, 0, Math.PI * 2)
      ctx.fill()
      ctx.fillStyle = 'rgba(255,231,164,0.9)'
      ctx.beginPath()
      ctx.arc(W / 2, sunY, H * 0.09, 0, Math.PI * 2)
      ctx.fill()

      // Mesa silhouettes
      ctx.fillStyle = 'rgba(38,20,32,0.85)'
      const mesas = [
        [0.02, 0.30, 0.14], [0.20, 0.20, 0.10], [0.70, 0.24, 0.13], [0.88, 0.17, 0.11],
      ]
      for (const [mx, mw, mh] of mesas) {
        const x = mx * W, w = mw * W, h = mh * H
        const base = H * 0.72
        ctx.beginPath()
        ctx.moveTo(x, base)
        ctx.lineTo(x + w * 0.16, base - h)
        ctx.lineTo(x + w * 0.84, base - h)
        ctx.lineTo(x + w, base)
        ctx.closePath()
        ctx.fill()
      }

      // Ground
      const ground = ctx.createLinearGradient(0, H * 0.72, 0, H)
      ground.addColorStop(0, '#3A2320')
      ground.addColorStop(1, '#160D0F')
      ctx.fillStyle = ground
      ctx.fillRect(0, H * 0.72, W, H * 0.28)

      // Dust motes drifting across the light
      ctx.save()
      ctx.fillStyle = 'rgba(255,214,160,0.35)'
      for (let i = 0; i < 26; i++) {
        const px = ((i * 137 + now * 0.012 * (1 + (i % 3))) % (W + 60)) - 30
        const py = H * 0.35 + ((i * 53) % (H * 0.5))
        ctx.globalAlpha = 0.15 + ((i % 5) / 12)
        ctx.beginPath()
        ctx.arc(px, py, 1.4, 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.restore()
    }

    let lastKey = ''
    function syncUi(players) {
      const present = [!!players[0], !!players[1]]
      let message = ''
      let sub = ''
      if (g.phase === 'holster') {
        message = 'Hands at your belt'
        sub = !players[0] || !players[1]
          ? 'Both duellists step into frame — one on each side'
          : 'Hold steady below the line…'
      } else if (g.phase === 'steady') {
        message = 'Steady…'
        sub = 'Do not move until the call'
      } else if (g.phase === 'draw') {
        message = 'DRAW!'
        sub = ''
      } else if (g.phase === 'round') {
        message = P_NAMES[g.winner] + ' takes it'
        sub = g.falseStart
          ? P_NAMES[1 - g.winner] + ' drew early'
          : g.reaction != null
            ? g.reaction + 'ms on the trigger'
            : ''
      } else if (g.phase === 'match') {
        const champ = g.wins[0] > g.wins[1] ? 0 : 1
        message = P_NAMES[champ] + ' is fastest in the hood'
        sub = g.wins[0] + ' – ' + g.wins[1]
      }
      const key = [g.phase, message, sub, g.wins.join('|'), present.join('|')].join('~')
      if (key !== lastKey) {
        lastKey = key
        setUi({
          phase: g.phase,
          wins: [...g.wins],
          message,
          sub,
          winner: g.winner,
          reaction: g.reaction,
          falseStart: g.falseStart,
          present,
        })
      }
    }

    raf = requestAnimationFrame(frame)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  const loading = status === 'loading-model' || status === 'starting-camera'
  const ACCENT = '#FFB000'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase !== 'menu' && !loading && status === 'ready' && (
        <div className="pointer-events-none absolute inset-x-0 top-[20%] flex flex-col items-center px-6 text-center">
          <div
            key={ui.message}
            className={
              'font-display font-700 tracking-tight drop-shadow-[0_4px_28px_rgba(0,0,0,0.75)] animate-pop ' +
              (ui.phase === 'draw'
                ? 'text-7xl md:text-9xl text-white'
                : 'text-3xl md:text-4xl text-white/90')
            }
            style={ui.phase === 'draw' ? { textShadow: '0 0 50px rgba(255,176,0,0.75)' } : undefined}
          >
            {ui.message}
          </div>
          {ui.sub && <p className="mt-3 text-white/70 max-w-md animate-fadeIn">{ui.sub}</p>}
          {ui.phase === 'round' && ui.reaction != null && (
            <div className="mt-4 font-display text-6xl text-white animate-pop">
              {ui.reaction}<span className="text-2xl text-white/60">ms</span>
            </div>
          )}
        </div>
      )}

      {ui.phase === 'match' && (
        <div className="absolute inset-x-0 bottom-20 flex justify-center gap-3">
          <Button accent={ACCENT} onClick={() => start(vsCpuRef.current)} className="pointer-events-auto">Rematch</Button>
          <Button variant="ghost" onClick={toMenu} className="pointer-events-auto">Change mode</Button>
        </div>
      )}

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Sundown · two hands · one winner" accent={ACCENT}>
            The Fastest in the Hood
          </Title>
          <div className="grid gap-2.5 mb-8 max-w-md w-full mt-2">
            <HowTo glyph="wave" title="Take your side" body="One duellist on the left of the frame, one on the right." delay={80} />
            <HowTo glyph="fist" title="Hands at your belt" body="Drop your hand below the dotted line and hold it there." delay={160} />
            <HowTo glyph="gun" title="On DRAW!" body="Snap into a finger gun and raise it. Fastest hand takes the round." delay={240} />
            <HowTo glyph="point" title="Don't twitch" body="Move before the call and you hand the round to your rival." delay={320} />
          </div>
          <div className="flex gap-3">
            <Button accent={ACCENT} onClick={() => start(false)}>Two players</Button>
            <Button variant="ghost" onClick={() => start(true)}>Duel the machine</Button>
          </div>
        </Screen>
      )}
    </div>
  )
}
