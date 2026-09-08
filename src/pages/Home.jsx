import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { sfx } from '../lib/audio.js'

export const GAMES = [
  {
    to: '/dojo', title: 'Shadow Dojo', accent: '#FF4D8D', motif: 'dojo',
    blurb: 'Fighters walk out of the dark toward you. Punch at the lens, guard with both palms, step aside to dodge.',
    players: 'Solo', body: 'Hands', tags: ['fight', 'first person'],
    minutes: '3–8 min', intensity: 3, isNew: true,
  },
  {
    to: '/rift', title: 'The Rift', accent: '#00D4FF', motif: 'rift',
    blurb: 'A tunnel rushes at you. Lean to steer, crouch to duck under the bars, move your head to look around.',
    players: 'Solo', body: 'Full body', tags: ['first person', 'reflex'],
    minutes: '2–5 min', intensity: 3, isNew: true,
  },
  {
    to: '/arcane', title: 'Arcane', accent: '#B06BFF', motif: 'arcane',
    blurb: 'Draw shapes in the air to cast. A line throws a bolt, a circle raises a ward, a zigzag chains through the horde.',
    players: 'Solo', body: 'Hands', tags: ['fight', 'first person'],
    minutes: '3–8 min', intensity: 2, isNew: true,
  },
  {
    to: '/kinetic', title: 'Kinetic', accent: '#00E5B0', motif: 'kinetic',
    blurb: 'Open your palm to push, close your fist to grab, open again to hurl. Land orbs in the ring.',
    players: 'Up to 4 hands', body: 'Hands', tags: ['relaxed'],
    minutes: '75 sec', intensity: 1,
  },
  {
    to: '/rocket', title: 'Rocket Rush', accent: '#7CC5FF', motif: 'rocket',
    blurb: 'Fly with your palm and thread the gates. One clip and you are out.',
    players: '1v1 · up to 4 · 2v2', body: 'Hands', tags: ['versus', 'reflex'],
    minutes: '1–3 min', intensity: 2,
  },
  {
    to: '/dance', title: 'Dance Floor', accent: '#FF7AC8', motif: 'dance',
    blurb: 'Follow the routine and hit every beat. Chain hits for a combo multiplier.',
    players: 'Solo · up to 4', body: 'Full body', tags: ['versus', 'party'],
    minutes: '2–4 min', intensity: 3,
  },
  {
    to: '/duel', title: 'The Fastest in the Hood', accent: '#FFB000', motif: 'revolver',
    blurb: 'Hands at the belt until the call. Snap into a finger gun and raise it.',
    players: '2 · or vs machine', body: 'Hands', tags: ['versus', 'reflex'],
    minutes: '1–2 min', intensity: 1,
  },
  {
    to: '/paint', title: 'Air Canvas', accent: '#FF7A45', motif: 'paint',
    blurb: 'Point to paint in mid air. Several people can draw on one canvas, then save it.',
    players: 'Up to 4 hands', body: 'Hands', tags: ['relaxed', 'party'],
    minutes: 'Open ended', intensity: 1,
  },
  {
    to: '/copy', title: 'Copy That', accent: '#7C5CFF', motif: 'pose',
    blurb: 'A glowing figure holds a shape and you become it. Limbs turn green as they line up.',
    players: 'Solo', body: 'Full body', tags: ['relaxed'],
    minutes: '1–2 min', intensity: 2,
  },
  {
    to: '/orbs', title: 'Orb Catcher', accent: '#B6FF3C', motif: 'orb',
    blurb: 'Sweep falling orbs out of the air and pinch to blast a cluster.',
    players: 'Solo', body: 'Hands', tags: ['relaxed', 'reflex'],
    minutes: '60 sec', intensity: 1,
  },
]

const FILTERS = [
  { id: 'all', label: 'Everything' },
  { id: 'versus', label: 'Head to head' },
  { id: 'fight', label: 'Fighting' },
  { id: 'first person', label: 'First person' },
  { id: 'party', label: 'Crowd pleasers' },
  { id: 'relaxed', label: 'Easy going' },
]

export default function Home() {
  const [filter, setFilter] = useState('all')

  const shown = useMemo(
    () => (filter === 'all' ? GAMES : GAMES.filter((g) => g.tags.includes(filter))),
    [filter]
  )

  return (
    <div className="mx-auto max-w-6xl px-5 md:px-8 py-10 md:py-14">
      <header className="mb-8">
        <p className="text-muted mb-3 text-sm tracking-[0.16em] uppercase">Ten games · one camera</p>
        <h1 className="font-display text-4xl md:text-6xl font-700 leading-[1.03] mb-4 max-w-3xl">
          Your hands and your body are the controller
        </h1>
        <p className="text-muted max-w-2xl text-lg">
          Everything runs on this machine. No video is uploaded and nothing is stored on a server.
        </p>
      </header>

      {/* Filters: large, obvious, thumb-friendly */}
      <div className="flex flex-wrap gap-2 mb-7" role="group" aria-label="Filter games">
        {FILTERS.map((f) => {
          const on = filter === f.id
          const count = f.id === 'all' ? GAMES.length : GAMES.filter((g) => g.tags.includes(f.id)).length
          return (
            <button
              key={f.id}
              onClick={() => { sfx.click(); setFilter(f.id) }}
              onPointerEnter={() => sfx.hover()}
              aria-pressed={on}
              className={
                'rounded-full border px-4 py-2.5 text-sm transition-all duration-200 active:scale-95 ' +
                (on
                  ? 'border-mint text-ink bg-mint font-medium'
                  : 'border-line text-muted hover:text-fg hover:border-fg/30')
              }
            >
              {f.label}
              <span className={'ml-2 text-xs ' + (on ? 'text-ink/60' : 'text-muted/60')}>{count}</span>
            </button>
          )
        })}
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {shown.map((g, i) => (
          <GameCard key={g.to} game={g} index={i} />
        ))}
      </div>

      {shown.length === 0 && (
        <p className="text-muted py-16 text-center">Nothing in that category yet.</p>
      )}
    </div>
  )
}

function GameCard({ game, index }) {
  return (
    <Link
      to={game.to}
      onPointerEnter={() => sfx.hover()}
      onClick={() => sfx.click()}
      className="group relative flex flex-col overflow-hidden rounded-2xl border border-line bg-surface p-6
                 transition-all duration-300 hover:-translate-y-1 hover:border-white/20
                 focus:outline-none focus-visible:ring-2 focus-visible:ring-fg animate-riseIn"
      style={{ animationDelay: `${index * 45}ms`, animationFillMode: 'backwards' }}
    >
      <span
        className="pointer-events-none absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        style={{ background: `radial-gradient(420px 200px at 20% 0%, ${game.accent}26, transparent 70%)` }}
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute inset-x-0 top-0 h-[3px] scale-x-0 group-hover:scale-x-100
                   origin-left transition-transform duration-500"
        style={{ background: game.accent }}
        aria-hidden="true"
      />

      <span className="relative flex items-start justify-between mb-4">
        <Motif kind={game.motif} color={game.accent} />
        {game.isNew && (
          <span
            className="rounded-full px-2.5 py-1 text-[10px] font-medium tracking-wider uppercase"
            style={{ background: game.accent + '22', color: game.accent }}
          >
            New
          </span>
        )}
      </span>

      <span className="relative font-display text-xl md:text-2xl font-600 mb-2 leading-tight">
        {game.title}
      </span>
      <span className="relative text-muted text-sm leading-relaxed mb-5 flex-1">{game.blurb}</span>

      <span className="relative flex flex-wrap items-center gap-x-3 gap-y-2 text-xs text-muted">
        <Meta icon="players">{game.players}</Meta>
        <Meta icon="body">{game.body}</Meta>
        <Meta icon="clock">{game.minutes}</Meta>
        <span className="ml-auto flex items-center gap-1" title={`Intensity ${game.intensity} of 3`}>
          {[1, 2, 3].map((n) => (
            <span
              key={n}
              className="block h-1.5 w-1.5 rounded-full"
              style={{ background: n <= game.intensity ? game.accent : 'rgba(255,255,255,0.15)' }}
            />
          ))}
        </span>
      </span>
    </Link>
  )
}

function Meta({ icon, children }) {
  const paths = {
    players: <path d="M6 12a3 3 0 100-6 3 3 0 000 6zM2 16a4 4 0 018 0" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" fill="none" />,
    body: <path d="M9 4.5a1.5 1.5 0 100-3 1.5 1.5 0 000 3zM9 6v5M5 8h8M9 11l-3 5M9 11l3 5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" fill="none" />,
    clock: <><circle cx="9" cy="9" r="6.4" stroke="currentColor" strokeWidth="1.4" fill="none" /><path d="M9 5.6V9l2.4 1.6" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" fill="none" /></>,
  }
  return (
    <span className="inline-flex items-center gap-1.5">
      <svg width="14" height="14" viewBox="0 0 18 18" aria-hidden="true" className="opacity-60">{paths[icon]}</svg>
      {children}
    </span>
  )
}

function Motif({ kind, color }) {
  const p = { width: 44, height: 44, viewBox: '0 0 56 56', fill: 'none', className: 'shrink-0' }
  const ring = <circle cx="28" cy="28" r="25" stroke={color} strokeOpacity="0.22" strokeWidth="1.5" />
  const M = {
    dojo: (
      <>
        <rect x="16" y="21" width="24" height="16" rx="7" stroke={color} strokeWidth="2.4" />
        <path d="M22 26h12" stroke={color} strokeWidth="2.2" strokeLinecap="round" />
        <path d="M44 28h6M6 28h6" stroke={color} strokeWidth="2" strokeLinecap="round" strokeOpacity="0.5" />
      </>
    ),
    rift: (
      <>
        <ellipse cx="28" cy="28" rx="18" ry="10" stroke={color} strokeWidth="2" />
        <ellipse cx="28" cy="28" rx="10" ry="5.5" stroke={color} strokeWidth="2" strokeOpacity="0.7" />
        <circle cx="28" cy="28" r="2.4" fill={color} />
      </>
    ),
    arcane: (
      <>
        <path d="M14 34l10-14 8 10 10-14" stroke={color} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" />
        <circle cx="28" cy="28" r="19" stroke={color} strokeWidth="1.6" strokeDasharray="3 5" />
      </>
    ),
    kinetic: (
      <>
        <circle cx="28" cy="28" r="6.5" fill={color} />
        <circle cx="28" cy="28" r="13" stroke={color} strokeWidth="1.8" strokeDasharray="4 5" />
        <circle cx="28" cy="28" r="19" stroke={color} strokeWidth="1.4" strokeDasharray="2 6" strokeOpacity="0.6" />
      </>
    ),
    rocket: (
      <>
        <path d="M18 28h16l7-6-7-6H18z" stroke={color} strokeWidth="2.2" strokeLinejoin="round" />
        <path d="M13 33l8 4M13 39l13 2" stroke={color} strokeWidth="2" strokeLinecap="round" strokeOpacity="0.5" />
      </>
    ),
    dance: (
      <>
        <circle cx="26" cy="14" r="4" stroke={color} strokeWidth="2.2" />
        <path d="M26 18v12M26 22l-9-4M26 22l10-6M26 30l-5 12M26 30l7 11" stroke={color} strokeWidth="2.2" strokeLinecap="round" />
      </>
    ),
    revolver: (
      <>
        <circle cx="28" cy="28" r="10.5" stroke={color} strokeWidth="2.2" />
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <circle key={i} cx={28 + Math.cos((i / 6) * Math.PI * 2) * 5.6} cy={28 + Math.sin((i / 6) * Math.PI * 2) * 5.6} r="1.9" fill={color} />
        ))}
      </>
    ),
    paint: (
      <>
        <path d="M15 40c6-16 14-24 26-26" stroke={color} strokeWidth="3" strokeLinecap="round" />
        <circle cx="18" cy="38" r="4.5" fill={color} />
      </>
    ),
    pose: (
      <>
        <circle cx="28" cy="15" r="4" stroke={color} strokeWidth="2.2" />
        <path d="M28 19v14M16 24h24M28 33l-6 12M28 33l6 12" stroke={color} strokeWidth="2.2" strokeLinecap="round" />
      </>
    ),
    orb: (
      <>
        <circle cx="21" cy="23" r="6" fill={color} fillOpacity="0.9" />
        <circle cx="35" cy="33" r="9" fill={color} fillOpacity="0.35" />
      </>
    ),
  }
  return <svg {...p} aria-hidden="true">{ring}{M[kind] || M.orb}</svg>
}
