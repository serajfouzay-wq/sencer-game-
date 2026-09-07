import { Link } from 'react-router-dom'

const GAMES = [
  {
    to: '/kinetic',
    title: 'Kinetic',
    line: 'Open your palm and a force field shoves the orbs away. Close your fist and one snaps into your grip. Open again and it flies.',
    tag: 'Up to 4 hands · telekinesis',
    accent: '#00E5B0',
    motif: 'kinetic',
  },
  {
    to: '/rocket',
    title: 'Rocket Rush',
    line: 'Fly with your palm and thread the gates. One clip and you are out. Last rocket flying takes it.',
    tag: '1v1 · up to 4 · 2v2 teams',
    accent: '#00D4FF',
    motif: 'rocket',
  },
  {
    to: '/dance',
    title: 'Dance Floor',
    line: 'A figure moves through a routine and you follow. Every beat is graded, and hits chain into a combo.',
    tag: '1v1 · up to 4 dancers',
    accent: '#FF4D8D',
    motif: 'dance',
  },
  {
    to: '/duel',
    title: 'The Fastest in the Hood',
    line: 'Hands at the belt until the call. Snap into a finger gun and raise it. Reaction times to the millisecond.',
    tag: '2 players · or duel the machine',
    accent: '#FFB000',
    motif: 'revolver',
  },
  {
    to: '/paint',
    title: 'Air Canvas',
    line: 'Point to paint in mid air. Pick colours and a background by hovering. Several people can draw on one canvas.',
    tag: 'Up to 4 hands · save a PNG',
    accent: '#FF7A45',
    motif: 'paint',
  },
  {
    to: '/copy',
    title: 'Copy That',
    line: 'A glowing figure holds a shape and you become it. Limbs turn green as they line up.',
    tag: 'Solo · full body',
    accent: '#7C5CFF',
    motif: 'pose',
  },
  {
    to: '/orbs',
    title: 'Orb Catcher',
    line: 'Sweep falling orbs out of the air and pinch to blast a cluster. Sixty seconds.',
    tag: 'Solo · hands',
    accent: '#B6FF3C',
    motif: 'orb',
  },
]

export default function Home() {
  const [hero, ...rest] = GAMES
  return (
    <div className="mx-auto max-w-5xl px-6 py-12">
      <p className="text-muted mb-3">Seven games. One camera. Nothing to hold.</p>
      <h1 className="font-display text-4xl md:text-5xl font-700 leading-[1.05] mb-4 max-w-2xl">
        Your hands and your body are the controller
      </h1>
      <p className="text-muted max-w-xl mb-10">
        Everything runs on this machine. No video is uploaded and nothing is stored on a server.
      </p>

      <Link
        to={hero.to}
        className="group relative block overflow-hidden rounded-2xl border border-line p-8 md:p-10 mb-3 focus:outline-none focus-visible:ring-2 focus-visible:ring-fg"
      >
        <span
          className="absolute inset-0 opacity-60 group-hover:opacity-100 transition-opacity duration-500"
          style={{ background: `radial-gradient(600px 260px at 15% 0%, ${hero.accent}26, transparent 70%)` }}
          aria-hidden="true"
        />
        <span className="relative flex items-start gap-6">
          <Motif kind={hero.motif} color={hero.accent} big />
          <span className="flex-1">
            <span className="block text-xs mb-2" style={{ color: hero.accent }}>{hero.tag}</span>
            <span className="block font-display text-3xl md:text-4xl font-700 mb-2">{hero.title}</span>
            <span className="block text-muted max-w-xl">{hero.line}</span>
          </span>
        </span>
      </Link>

      <div className="divide-y divide-line border-y border-line">
        {rest.map((g) => (
          <Link
            key={g.to}
            to={g.to}
            className="group relative flex items-center gap-5 py-6 px-4 -mx-4 overflow-hidden rounded-lg focus:outline-none focus-visible:ring-2 focus-visible:ring-fg"
          >
            <span
              className="absolute inset-y-0 left-0 w-0 group-hover:w-full group-focus-visible:w-full transition-[width] duration-500 ease-out"
              style={{ background: `linear-gradient(90deg, ${g.accent}1F, transparent 70%)` }}
              aria-hidden="true"
            />
            <Motif kind={g.motif} color={g.accent} />
            <span className="relative flex-1">
              <span className="block font-display text-xl md:text-2xl font-600 mb-1">{g.title}</span>
              <span className="block text-muted text-sm max-w-xl">{g.line}</span>
              <span className="mt-1.5 inline-block text-xs" style={{ color: g.accent }}>{g.tag}</span>
            </span>
            <span
              className="relative shrink-0 group-hover:translate-x-1 transition-transform"
              style={{ color: g.accent }}
              aria-hidden="true"
            >
              ▸
            </span>
          </Link>
        ))}
      </div>
    </div>
  )
}

function Motif({ kind, color, big }) {
  const s = big ? 84 : 52
  const p = { width: s, height: s, viewBox: '0 0 56 56', fill: 'none', className: 'relative shrink-0' }
  const ring = <circle cx="28" cy="28" r="26" stroke={color} strokeOpacity="0.25" />

  if (kind === 'kinetic') {
    return (
      <svg {...p} aria-hidden="true">{ring}
        <circle cx="28" cy="28" r="7" fill={color} />
        <circle cx="28" cy="28" r="14" stroke={color} strokeOpacity="0.7" strokeDasharray="4 5" />
        <circle cx="28" cy="28" r="20" stroke={color} strokeOpacity="0.35" strokeDasharray="2 6" />
      </svg>
    )
  }
  if (kind === 'rocket') {
    return (
      <svg {...p} aria-hidden="true">{ring}
        <path d="M18 28h16l6-6-6-6H18z" stroke={color} strokeWidth="2" strokeLinejoin="round" />
        <path d="M14 34l8 4M14 40l12 2" stroke={color} strokeWidth="2" strokeLinecap="round" strokeOpacity="0.5" />
      </svg>
    )
  }
  if (kind === 'dance') {
    return (
      <svg {...p} aria-hidden="true">{ring}
        <circle cx="26" cy="14" r="4" stroke={color} strokeWidth="2" />
        <path d="M26 18v12M26 22l-9-4M26 22l10-6M26 30l-5 12M26 30l7 11" stroke={color} strokeWidth="2" strokeLinecap="round" />
      </svg>
    )
  }
  if (kind === 'paint') {
    return (
      <svg {...p} aria-hidden="true">{ring}
        <path d="M15 40c6-16 14-24 26-26" stroke={color} strokeWidth="3" strokeLinecap="round" />
        <circle cx="18" cy="38" r="4" fill={color} />
      </svg>
    )
  }
  if (kind === 'revolver') {
    return (
      <svg {...p} aria-hidden="true">{ring}
        <circle cx="28" cy="28" r="11" stroke={color} strokeWidth="2" />
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <circle
            key={i}
            cx={28 + Math.cos((i / 6) * Math.PI * 2) * 6}
            cy={28 + Math.sin((i / 6) * Math.PI * 2) * 6}
            r="2"
            fill={color}
          />
        ))}
      </svg>
    )
  }
  if (kind === 'pose') {
    return (
      <svg {...p} aria-hidden="true">{ring}
        <circle cx="28" cy="15" r="4" stroke={color} strokeWidth="2" />
        <path d="M28 19v14M16 24h24M28 33l-6 12M28 33l6 12" stroke={color} strokeWidth="2" strokeLinecap="round" />
      </svg>
    )
  }
  return (
    <svg {...p} aria-hidden="true">{ring}
      <circle cx="21" cy="23" r="6" fill={color} fillOpacity="0.9" />
      <circle cx="35" cy="33" r="9" fill={color} fillOpacity="0.35" />
    </svg>
  )
}
