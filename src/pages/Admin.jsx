import { useMemo, useState } from 'react'
import { loadSettings, saveSettings, loadSessions, clearSessions, defaultSettings } from '../lib/storage.js'

const GAMES = {
  duelall: { label: 'All games' },
  kinetic: { label: 'Kinetic', accent: 'text-mint' },
  rocket: { label: 'Rocket Rush', accent: 'text-p2' },
  dance: { label: 'Dance Floor', accent: 'text-violet' },
  quickdraw: { label: 'The Fastest in the Hood', accent: 'text-p1' },
  posematch: { label: 'Copy That', accent: 'text-violet' },
  paint: { label: 'Air Canvas', accent: 'text-ember' },
  orbs: { label: 'Orb Catcher', accent: 'text-mint' },
}

export default function Admin() {
  const [settings, setSettings] = useState(loadSettings())
  const [sessions, setSessions] = useState(loadSessions())
  const [filter, setFilter] = useState('duelall')
  const [saved, setSaved] = useState(false)

  const shown = useMemo(
    () => (filter === 'duelall' ? sessions : sessions.filter((s) => s.game === filter)),
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

  function update(patch) {
    const next = { ...settings, ...patch }
    setSettings(next)
    saveSettings(next)
    setSaved(true)
    setTimeout(() => setSaved(false), 1200)
  }

  function reset() {
    clearSessions()
    setSessions([])
  }

  return (
    <div className="mx-auto max-w-5xl px-5 py-8">
      <div className="flex items-end justify-between mb-6">
        <div>
          <h1 className="font-display text-2xl font-700">Dashboard</h1>
          <p className="text-muted text-sm mt-1">
            Results and camera settings. Everything saves to this browser automatically.
          </p>
        </div>
        {saved && <span className="text-mint text-sm">Saved</span>}
      </div>

      <div className="flex flex-wrap gap-2 mb-5">
        {Object.entries(GAMES).map(([key, g]) => (
          <button
            key={key}
            onClick={() => setFilter(key)}
            className={
              'rounded-lg px-3 py-1.5 text-sm border transition-colors ' +
              (filter === key
                ? 'border-fg/40 bg-surface2 text-fg'
                : 'border-line text-muted hover:text-fg')
            }
          >
            {g.label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
        <Stat label="Rounds played" value={stats.count} />
        <Stat label="High score" value={stats.best} accent />
        <Stat label="Average score" value={stats.avg} />
        <Stat label="Fastest draw" value={stats.fastest != null ? stats.fastest + 'ms' : '—'} />
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <section className="rounded-2xl border border-line bg-surface p-5">
          <h2 className="font-display text-lg mb-4">Camera & tracking</h2>

          <Toggle
            label="Mirror the camera"
            hint="Feels natural, like looking in a mirror"
            checked={settings.mirror}
            onChange={(v) => update({ mirror: v })}
          />
          <Toggle
            label="Show the tracked skeleton"
            hint="Draw hands and body on screen"
            checked={settings.showSkeleton}
            onChange={(v) => update({ showSkeleton: v })}
          />

          <div className="mt-5">
            <div className="flex justify-between text-sm mb-1">
              <span>Hands to track in Orb Catcher</span>
              <span className="text-muted">{settings.numHands}</span>
            </div>
            <div className="flex gap-2">
              {[1, 2].map((n) => (
                <button
                  key={n}
                  onClick={() => update({ numHands: n })}
                  className={
                    'flex-1 py-2 rounded-lg border text-sm transition-colors ' +
                    (settings.numHands === n
                      ? 'border-mint text-mint bg-mint/10'
                      : 'border-line text-muted hover:text-fg')
                  }
                >
                  {n} {n === 1 ? 'hand' : 'hands'}
                </button>
              ))}
            </div>
            <p className="text-xs text-muted mt-1">The duel always tracks two hands.</p>
          </div>

          <div className="mt-5">
            <div className="flex justify-between text-sm mb-1">
              <span>Detection sensitivity</span>
              <span className="text-muted">{settings.sensitivity.toFixed(2)}</span>
            </div>
            <input
              type="range"
              min="0.3"
              max="0.9"
              step="0.05"
              value={settings.sensitivity}
              onChange={(e) => update({ sensitivity: parseFloat(e.target.value) })}
              className="w-full accent-mint"
            />
            <p className="text-xs text-muted mt-1">
              Lower it in dim rooms so hands are picked up more easily. Raise it in busy rooms to
              cut out false detections.
            </p>
          </div>

          <button
            onClick={() => update({ ...defaultSettings })}
            className="mt-5 text-sm text-muted hover:text-fg underline underline-offset-4"
          >
            Reset to defaults
          </button>
        </section>

        <section className="rounded-2xl border border-line bg-surface p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-display text-lg">Recent rounds</h2>
            {sessions.length > 0 && (
              <button onClick={reset} className="text-sm text-ember hover:opacity-80">
                Clear history
              </button>
            )}
          </div>

          {shown.length === 0 ? (
            <p className="text-muted text-sm py-8 text-center">
              Nothing here yet. Play a round and the result lands on this page.
            </p>
          ) : (
            <ul className="space-y-2 max-h-[24rem] overflow-auto pr-1">
              {shown.map((s, i) => {
                const g = GAMES[s.game] || GAMES.orbs
                return (
                  <li key={i} className="rounded-xl bg-surface2 px-4 py-3">
                    <div className="flex items-center justify-between">
                      <span className={'text-xs ' + (g.accent || 'text-muted')}>{g.label}</span>
                      <span className="font-display text-lg">{s.score}</span>
                    </div>
                    <div className="flex items-center justify-between mt-0.5">
                      <span className="text-xs text-muted">{new Date(s.at).toLocaleString()}</span>
                      {s.detail && <span className="text-xs text-muted">{s.detail}</span>}
                    </div>
                  </li>
                )
              })}
            </ul>
          )}
        </section>
      </div>
    </div>
  )
}

function Stat({ label, value, accent }) {
  return (
    <div className="rounded-2xl border border-line bg-surface p-4">
      <div className={'font-display text-3xl font-700 ' + (accent ? 'text-mint' : 'text-fg')}>{value}</div>
      <div className="text-xs text-muted mt-1">{label}</div>
    </div>
  )
}

function Toggle({ label, hint, checked, onChange }) {
  return (
    <div className="flex items-start justify-between gap-4 py-2">
      <span>
        <span className="block text-sm">{label}</span>
        {hint && <span className="block text-xs text-muted">{hint}</span>}
      </span>
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        aria-label={label}
        onClick={() => onChange(!checked)}
        className={
          'mt-1 h-6 w-11 shrink-0 rounded-full transition-colors relative ' +
          (checked ? 'bg-mint' : 'bg-line')
        }
      >
        <span
          className={
            'absolute top-0.5 h-5 w-5 rounded-full bg-white transition-all ' +
            (checked ? 'left-[22px]' : 'left-0.5')
          }
        />
      </button>
    </div>
  )
}
