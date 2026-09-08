import { useEffect, useMemo, useRef, useState } from 'react'
import { loadSettings, saveSettings, loadSessions, clearSessions, defaultSettings } from '../lib/storage.js'
import { useVision } from '../lib/useVision.js'
import { handSpan, HAND_CONNECTIONS } from '../lib/gestures.js'
import { sfx } from '../lib/audio.js'
import { Odometer } from '../components/ui.jsx'

const GAMES = {
  dojo: { label: 'Shadow Dojo', color: '#FF4D8D' },
  rift: { label: 'The Rift', color: '#00D4FF' },
  arcane: { label: 'Arcane', color: '#B06BFF' },
  kinetic: { label: 'Kinetic', color: '#00E5B0' },
  rocket: { label: 'Rocket Rush', color: '#7CC5FF' },
  dance: { label: 'Dance Floor', color: '#FF7AC8' },
  quickdraw: { label: 'Fastest in the Hood', color: '#FFB000' },
  paint: { label: 'Air Canvas', color: '#FF7A45' },
  posematch: { label: 'Copy That', color: '#7C5CFF' },
  orbs: { label: 'Orb Catcher', color: '#B6FF3C' },
}

const TABS = [
  { id: 'overview', label: 'Overview' },
  { id: 'setup', label: 'Camera setup' },
  { id: 'check', label: 'Live check' },
]

export default function Admin() {
  const [tab, setTab] = useState('overview')
  const [settings, setSettings] = useState(loadSettings())
  const [sessions, setSessions] = useState(loadSessions())
  const [filter, setFilter] = useState('all')
  const [saved, setSaved] = useState(false)

  function update(patch) {
    const next = { ...settings, ...patch }
    setSettings(next)
    saveSettings(next)
    setSaved(true)
    setTimeout(() => setSaved(false), 1400)
  }

  return (
    <div className="mx-auto max-w-5xl px-5 md:px-8 py-8 md:py-12">
      <header className="mb-7">
        <h1 className="font-display text-3xl md:text-4xl font-700">Dashboard</h1>
        <p className="text-muted mt-2">
          Scores, camera settings, and a live check you can run before doors open.
        </p>
      </header>

      <div className="flex gap-1.5 p-1.5 rounded-2xl bg-surface border border-line mb-7 w-full sm:w-auto sm:inline-flex">
        {TABS.map((t) => (
          <button
            key={t.id}
            onClick={() => { sfx.click(); setTab(t.id) }}
            onPointerEnter={() => sfx.hover()}
            aria-pressed={tab === t.id}
            className={
              'flex-1 sm:flex-none rounded-xl px-5 py-2.5 text-sm transition-all active:scale-[0.97] ' +
              (tab === t.id ? 'bg-surface2 text-fg font-medium' : 'text-muted hover:text-fg')
            }
          >
            {t.label}
          </button>
        ))}
        {saved && <span className="hidden sm:flex items-center px-3 text-mint text-sm animate-fadeIn">Saved</span>}
      </div>

      {tab === 'overview' && (
        <Overview
          sessions={sessions}
          filter={filter}
          setFilter={setFilter}
          onClear={() => { clearSessions(); setSessions([]) }}
        />
      )}
      {tab === 'setup' && <Setup settings={settings} update={update} />}
      {tab === 'check' && <LiveCheck settings={settings} />}
    </div>
  )
}

/* -------------------------------- overview -------------------------------- */

function Overview({ sessions, filter, setFilter, onClear }) {
  const shown = useMemo(
    () => (filter === 'all' ? sessions : sessions.filter((s) => s.game === filter)),
    [sessions, filter]
  )
  const stats = useMemo(() => {
    if (!shown.length) return { count: 0, best: 0, avg: 0, fastest: null }
    const scores = shown.map((s) => s.score || 0)
    const reactions = shown.map((s) => s.bestReaction).filter((r) => typeof r === 'number')
    return {
      count: shown.length,
      best: Math.max(...scores),
      avg: Math.round(scores.reduce((a, b) => a + b, 0) / scores.length),
      fastest: reactions.length ? Math.min(...reactions) : null,
    }
  }, [shown])

  const played = useMemo(() => {
    const set = new Set(sessions.map((s) => s.game))
    return Object.keys(GAMES).filter((k) => set.has(k))
  }, [sessions])

  return (
    <>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-7">
        <Stat label="Rounds played" value={stats.count} />
        <Stat label="High score" value={stats.best} accent="#00E5B0" />
        <Stat label="Average score" value={stats.avg} />
        <Stat label="Fastest draw" raw={stats.fastest != null ? stats.fastest + 'ms' : '—'} />
      </div>

      {played.length > 0 && (
        <div className="flex flex-wrap gap-2 mb-5">
          <Chip on={filter === 'all'} onClick={() => setFilter('all')}>All games</Chip>
          {played.map((k) => (
            <Chip key={k} on={filter === k} color={GAMES[k].color} onClick={() => setFilter(k)}>
              {GAMES[k].label}
            </Chip>
          ))}
        </div>
      )}

      <section className="rounded-2xl border border-line bg-surface p-5 md:p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-display text-lg">Recent rounds</h2>
          {sessions.length > 0 && (
            <button
              onClick={() => { sfx.back(); onClear() }}
              className="rounded-lg border border-ember/40 px-3 py-2 text-sm text-ember hover:bg-ember/10 transition-colors active:scale-95"
            >
              Clear history
            </button>
          )}
        </div>

        {shown.length === 0 ? (
          <div className="py-14 text-center">
            <p className="text-muted mb-1">Nothing here yet.</p>
            <p className="text-muted text-sm">Play a round and the result lands on this page.</p>
          </div>
        ) : (
          <ul className="space-y-2 max-h-[26rem] overflow-auto pr-1">
            {shown.map((s, i) => {
              const g = GAMES[s.game] || { label: s.game || 'Game', color: '#8A8AA0' }
              return (
                <li
                  key={i}
                  className="flex items-center gap-4 rounded-xl bg-surface2 px-4 py-3.5"
                >
                  <span className="h-9 w-1 rounded-full shrink-0" style={{ background: g.color }} />
                  <span className="min-w-0 flex-1">
                    <span className="block text-sm truncate" style={{ color: g.color }}>{g.label}</span>
                    <span className="block text-xs text-muted truncate">
                      {new Date(s.at).toLocaleString()}
                      {s.detail ? ` · ${s.detail}` : ''}
                    </span>
                  </span>
                  <span className="font-display text-xl shrink-0">{s.score}</span>
                </li>
              )
            })}
          </ul>
        )}
      </section>
    </>
  )
}

/* ---------------------------------- setup --------------------------------- */

function Setup({ settings, update }) {
  return (
    <div className="grid md:grid-cols-2 gap-5">
      <section className="rounded-2xl border border-line bg-surface p-5 md:p-6">
        <h2 className="font-display text-lg mb-1">What players see</h2>
        <p className="text-muted text-sm mb-5">Safe to change while a game is running.</p>
        <Toggle
          label="Mirror the camera"
          hint="On by default, so moving right moves right on screen"
          checked={settings.mirror}
          onChange={(v) => update({ mirror: v })}
        />
        <Toggle
          label="Show the camera behind the game"
          hint="Players can see themselves and stay in frame"
          checked={settings.cameraFeed}
          onChange={(v) => update({ cameraFeed: v })}
        />
        <Toggle
          label="Show the tracked skeleton"
          hint="Useful for demos, cleaner without it"
          checked={settings.showSkeleton}
          onChange={(v) => update({ showSkeleton: v })}
        />
        <Toggle
          label="Glow effects"
          hint="Turn off first if the frame rate drops"
          checked={settings.bloom}
          onChange={(v) => update({ bloom: v })}
        />
      </section>

      <section className="rounded-2xl border border-line bg-surface p-5 md:p-6">
        <h2 className="font-display text-lg mb-1">Tracking</h2>
        <p className="text-muted text-sm mb-5">Changing these restarts the camera in a game.</p>

        <div className="mb-6">
          <div className="flex justify-between text-sm mb-2">
            <span>Hands to track in Orb Catcher</span>
            <span className="text-muted">{settings.numHands}</span>
          </div>
          <div className="flex gap-2">
            {[1, 2].map((n) => (
              <button
                key={n}
                onClick={() => { sfx.click(); update({ numHands: n }) }}
                className={
                  'flex-1 py-3 rounded-xl border text-sm transition-all active:scale-[0.97] ' +
                  (settings.numHands === n
                    ? 'border-mint text-mint bg-mint/10 font-medium'
                    : 'border-line text-muted hover:text-fg')
                }
              >
                {n} {n === 1 ? 'hand' : 'hands'}
              </button>
            ))}
          </div>
          <p className="text-xs text-muted mt-2">Other games set their own number.</p>
        </div>

        <div>
          <div className="flex justify-between text-sm mb-2">
            <span>Detection sensitivity</span>
            <span className="text-muted font-display">{settings.sensitivity.toFixed(2)}</span>
          </div>
          <input
            type="range"
            min="0.3"
            max="0.9"
            step="0.05"
            value={settings.sensitivity}
            onChange={(e) => update({ sensitivity: parseFloat(e.target.value) })}
            className="w-full h-2 accent-mint cursor-pointer"
            aria-label="Detection sensitivity"
          />
          <div className="flex justify-between text-[11px] text-muted mt-1">
            <span>Finds hands easily</span>
            <span>Ignores the background</span>
          </div>
          <p className="text-xs text-muted mt-3 leading-relaxed">
            Lower it in a dim room. Raise it in a busy room so people walking past are ignored.
            Use the <span className="text-fg">Live check</span> tab to see the effect immediately.
          </p>
        </div>

        <button
          onClick={() => { sfx.back(); update({ ...defaultSettings }) }}
          className="mt-6 w-full rounded-xl border border-line py-3 text-sm text-muted hover:text-fg transition-colors active:scale-[0.97]"
        >
          Reset everything to defaults
        </button>
      </section>
    </div>
  )
}

/* -------------------------------- live check ------------------------------- */

/**
 * A camera preview with tracking drawn on top and a plain-language verdict.
 * On site this answers "is this going to work here" in about five seconds,
 * which no amount of settings copy can do.
 */
function LiveCheck({ settings }) {
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })
  const canvasRef = useRef(null)
  const [report, setReport] = useState({ hands: 0, fps: 0, quality: 'waiting' })

  useEffect(() => {
    let raf
    let frames = 0
    let lastFps = performance.now()
    let fps = 0
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    function loop(now) {
      raf = requestAnimationFrame(loop)
      const parent = canvas.parentElement
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const W = parent.clientWidth
      const H = parent.clientHeight
      if (canvas.width !== Math.floor(W * dpr)) {
        canvas.width = Math.floor(W * dpr)
        canvas.height = Math.floor(H * dpr)
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
      }

      frames += 1
      if (now - lastFps > 500) {
        fps = Math.round((frames * 1000) / (now - lastFps))
        frames = 0
        lastFps = now
      }

      ctx.clearRect(0, 0, W, H)
      const video = videoRef.current
      if (video && video.readyState >= 2 && video.videoWidth) {
        const scale = Math.max(W / video.videoWidth, H / video.videoHeight)
        const dw = video.videoWidth * scale
        const dh = video.videoHeight * scale
        ctx.save()
        ctx.globalAlpha = 0.55
        if (settings.mirror) { ctx.translate(W, 0); ctx.scale(-1, 1) }
        ctx.drawImage(video, (W - dw) / 2, (H - dh) / 2, dw, dh)
        ctx.restore()
      }

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      let closest = 0
      for (const lm of list) {
        closest = Math.max(closest, handSpan(lm))
        const pt = (k) => ({
          x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
          y: lm[k].y * H,
        })
        ctx.save()
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 2.5
        ctx.shadowColor = '#00E5B0'
        ctx.shadowBlur = 8
        for (const [a, b] of HAND_CONNECTIONS) {
          const u = pt(a), v = pt(b)
          ctx.beginPath(); ctx.moveTo(u.x, u.y); ctx.lineTo(v.x, v.y); ctx.stroke()
        }
        ctx.restore()
      }

      let quality = 'waiting'
      if (status === 'ready') {
        if (!list.length) quality = 'none'
        else if (closest < 0.06) quality = 'far'
        else if (fps && fps < 24) quality = 'slow'
        else quality = 'good'
      }
      setReport((r) =>
        r.hands === list.length && r.fps === fps && r.quality === quality
          ? r
          : { hands: list.length, fps, quality }
      )
    }
    raf = requestAnimationFrame(loop)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status, settings.mirror])

  const VERDICT = {
    waiting: { text: 'Starting the camera…', color: '#8A8AA0' },
    none: { text: 'No hands detected. Hold a hand up in front of the camera.', color: '#FFB000' },
    far: { text: 'Hands look small. Move the camera closer or step forward.', color: '#FFB000' },
    slow: { text: 'Tracking works but the frame rate is low. Turn off glow effects.', color: '#FF7A45' },
    good: { text: 'Tracking looks good. You are ready to go.', color: '#00E5B0' },
  }
  const v = VERDICT[report.quality]

  return (
    <div className="grid lg:grid-cols-[1.4fr_1fr] gap-5">
      <div className="relative aspect-video rounded-2xl border border-line bg-ink overflow-hidden">
        <video ref={videoRef} className="hidden" playsInline muted />
        <canvas ref={canvasRef} className="block h-full w-full" />
        {status === 'error' && (
          <div className="absolute inset-0 flex items-center justify-center p-8 text-center">
            <p className="text-muted text-sm">{error}</p>
          </div>
        )}
      </div>

      <section className="rounded-2xl border border-line bg-surface p-5 md:p-6">
        <h2 className="font-display text-lg mb-4">Live check</h2>
        <div
          className="rounded-xl px-4 py-3.5 mb-5 text-sm"
          style={{ background: v.color + '18', color: v.color, border: `1px solid ${v.color}44` }}
        >
          {v.text}
        </div>
        <dl className="space-y-3 text-sm">
          <Row label="Hands detected" value={report.hands} />
          <Row label="Frame rate" value={report.fps ? report.fps + ' fps' : '—'} />
          <Row label="Sensitivity" value={settings.sensitivity.toFixed(2)} />
        </dl>
        <p className="text-xs text-muted mt-5 leading-relaxed">
          Stand where players will stand. If hands flicker in and out, add light in front of them —
          a window behind a player is the most common cause of poor tracking.
        </p>
      </section>
    </div>
  )
}

function Row({ label, value }) {
  return (
    <div className="flex items-center justify-between border-b border-line/60 pb-2.5">
      <dt className="text-muted">{label}</dt>
      <dd className="font-display text-lg">{value}</dd>
    </div>
  )
}

/* --------------------------------- shared --------------------------------- */

function Stat({ label, value, raw, accent }) {
  return (
    <div className="rounded-2xl border border-line bg-surface p-4 md:p-5">
      <div className="font-display text-3xl md:text-4xl font-700" style={{ color: accent || '#EAEAF2' }}>
        {raw != null ? raw : <Odometer value={value ?? 0} />}
      </div>
      <div className="text-xs text-muted mt-1.5">{label}</div>
    </div>
  )
}

function Chip({ on, color = '#EAEAF2', onClick, children }) {
  return (
    <button
      onClick={() => { sfx.click(); onClick() }}
      onPointerEnter={() => sfx.hover()}
      aria-pressed={on}
      className={
        'rounded-full border px-4 py-2 text-sm transition-all active:scale-95 ' +
        (on ? 'font-medium' : 'border-line text-muted hover:text-fg')
      }
      style={on ? { borderColor: color, color, background: color + '1A' } : undefined}
    >
      {children}
    </button>
  )
}

function Toggle({ label, hint, checked, onChange }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      onClick={() => { sfx.click(); onChange(!checked) }}
      className="flex w-full items-start justify-between gap-4 py-3.5 text-left border-b border-line/50 last:border-0 group"
    >
      <span className="min-w-0">
        <span className="block text-sm group-hover:text-fg transition-colors">{label}</span>
        {hint && <span className="block text-xs text-muted mt-0.5">{hint}</span>}
      </span>
      <span
        className={
          'mt-0.5 h-7 w-12 shrink-0 rounded-full transition-colors relative ' +
          (checked ? 'bg-mint' : 'bg-line')
        }
      >
        <span
          className={
            'absolute top-1 h-5 w-5 rounded-full bg-white transition-all duration-200 ' +
            (checked ? 'left-6' : 'left-1')
          }
        />
      </span>
    </button>
  )
}
