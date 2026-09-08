import { useEffect, useRef, useState } from 'react'
import { sfx } from '../lib/audio.js'

/** Full-screen game menu with a staggered entrance. */
export function Screen({ children, accent = '#00E5B0', dim = 0.72 }) {
  return (
    <div
      className="absolute inset-0 z-10 flex flex-col items-center justify-center px-6 overflow-hidden animate-fadeIn"
      style={{ background: `rgba(8,7,18,${dim})`, backdropFilter: 'blur(6px)' }}
    >
      <span
        className="pointer-events-none absolute inset-0 opacity-70"
        style={{ background: `radial-gradient(700px 420px at 50% 12%, ${accent}22, transparent 70%)` }}
        aria-hidden="true"
      />
      <div className="relative flex flex-col items-center w-full">{children}</div>
    </div>
  )
}

/** Staggered child wrapper — each item slides up slightly after the last. */
export function Stagger({ children, className = '', gap = 70 }) {
  const items = Array.isArray(children) ? children : [children]
  return (
    <div className={className}>
      {items.filter(Boolean).map((c, i) => (
        <div key={i} className="animate-riseIn" style={{ animationDelay: `${i * gap}ms`, animationFillMode: 'backwards' }}>
          {c}
        </div>
      ))}
    </div>
  )
}

export function Title({ kicker, children, accent = '#00E5B0' }) {
  return (
    <>
      {kicker && (
        <p className="text-sm tracking-[0.18em] uppercase mb-3" style={{ color: accent }}>
          {kicker}
        </p>
      )}
      <h1 className="font-display text-4xl md:text-6xl font-700 mb-4 text-center leading-[1.05]">
        {children}
      </h1>
    </>
  )
}

export function Button({ children, onClick, variant = 'primary', accent, className = '', ...rest }) {
  const base =
    'relative inline-flex items-center justify-center rounded-xl px-7 py-3.5 font-medium ' +
    'transition-transform duration-150 active:scale-[0.97] focus:outline-none ' +
    'focus-visible:ring-2 focus-visible:ring-fg overflow-hidden group'
  const style =
    variant === 'primary'
      ? { background: accent || '#00E5B0', color: '#0A0A12', boxShadow: `0 0 28px ${(accent || '#00E5B0')}66` }
      : {}
  return (
    <button
      onClick={(e) => { sfx.click(); onClick && onClick(e) }}
      onPointerEnter={() => sfx.hover()}
      className={
        base +
        ' ' +
        (variant === 'primary'
          ? 'hover:-translate-y-0.5'
          : 'border border-line bg-white/5 text-fg hover:bg-white/10 hover:-translate-y-0.5') +
        ' ' + className
      }
      style={style}
      {...rest}
    >
      <span className="relative z-10">{children}</span>
      <span className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/25 to-transparent" aria-hidden="true" />
    </button>
  )
}

/** Segmented choice used on every game's setup screen. */
export function Choice({ label, options, value, onChange, accent = '#00E5B0' }) {
  return (
    <div className="w-full">
      {label && <div className="text-xs uppercase tracking-wider text-muted mb-2">{label}</div>}
      <div className="flex flex-wrap gap-2">
        {options.map((o) => {
          const on = value === o.v
          return (
            <button
              key={o.v}
              onClick={() => { sfx.click(); onChange(o.v) }}
              onPointerEnter={() => sfx.hover()}
              className={
                'rounded-lg border px-3.5 py-2 text-sm transition-all duration-200 active:scale-95 ' +
                (on ? 'font-medium' : 'border-line text-muted hover:text-fg hover:border-fg/30')
              }
              style={on ? { borderColor: accent, color: accent, background: accent + '18' } : undefined}
            >
              {o.l}
            </button>
          )
        })}
      </div>
    </div>
  )
}

/** How-to-play row with an animated gesture glyph. */
export function HowTo({ glyph, title, body, delay = 0 }) {
  return (
    <div
      className="flex gap-4 rounded-xl bg-white/5 border border-white/5 px-4 py-3 animate-riseIn"
      style={{ animationDelay: `${delay}ms`, animationFillMode: 'backwards' }}
    >
      <GestureGlyph kind={glyph} />
      <span className="min-w-0">
        <span className="block font-medium text-sm">{title}</span>
        <span className="block text-muted text-xs mt-0.5 leading-relaxed">{body}</span>
      </span>
    </div>
  )
}

/** Small looping SVG that shows the gesture rather than describing it. */
export function GestureGlyph({ kind, size = 34, color = '#EAEAF2' }) {
  const p = { width: size, height: size, viewBox: '0 0 40 40', fill: 'none', className: 'shrink-0' }
  if (kind === 'openPalm') {
    return (
      <svg {...p} aria-hidden="true">
        <g className="animate-breathe" style={{ transformOrigin: '20px 26px' }}>
          <path d="M13 26v-9M17 26V13M21 26V12M25 26v-9" stroke={color} strokeWidth="2.6" strokeLinecap="round" />
          <path d="M11 24a9 9 0 0018 0v-2H11z" fill={color} fillOpacity="0.25" stroke={color} strokeWidth="2" />
        </g>
      </svg>
    )
  }
  if (kind === 'fist') {
    return (
      <svg {...p} aria-hidden="true">
        <g className="animate-pulseSoft">
          <rect x="11" y="15" width="18" height="14" rx="6" fill={color} fillOpacity="0.25" stroke={color} strokeWidth="2" />
          <path d="M15 18h10" stroke={color} strokeWidth="2" strokeLinecap="round" />
        </g>
      </svg>
    )
  }
  if (kind === 'point') {
    return (
      <svg {...p} aria-hidden="true">
        <g className="animate-nudge">
          <path d="M20 24V9" stroke={color} strokeWidth="2.8" strokeLinecap="round" />
          <rect x="13" y="22" width="14" height="9" rx="4.5" fill={color} fillOpacity="0.25" stroke={color} strokeWidth="2" />
        </g>
      </svg>
    )
  }
  if (kind === 'gun') {
    return (
      <svg {...p} aria-hidden="true">
        <g className="animate-nudge">
          <path d="M18 22H8" stroke={color} strokeWidth="2.8" strokeLinecap="round" />
          <path d="M20 20V10" stroke={color} strokeWidth="2.6" strokeLinecap="round" />
          <rect x="17" y="20" width="12" height="10" rx="5" fill={color} fillOpacity="0.25" stroke={color} strokeWidth="2" />
        </g>
      </svg>
    )
  }
  if (kind === 'wave') {
    return (
      <svg {...p} aria-hidden="true">
        <g className="animate-sway" style={{ transformOrigin: '20px 30px' }}>
          <path d="M13 26v-9M17 26V13M21 26V12M25 26v-9" stroke={color} strokeWidth="2.6" strokeLinecap="round" />
          <path d="M11 24a9 9 0 0018 0v-2H11z" fill={color} fillOpacity="0.25" stroke={color} strokeWidth="2" />
        </g>
      </svg>
    )
  }
  return (
    <svg {...p} aria-hidden="true">
      <circle cx="20" cy="20" r="9" stroke={color} strokeWidth="2" className="animate-pulseSoft" />
    </svg>
  )
}

/** Score that rolls up instead of snapping, so numbers feel earned. */
export function Odometer({ value, className = '', style }) {
  const [shown, setShown] = useState(value)
  const raf = useRef()
  useEffect(() => {
    const from = shown
    const delta = value - from
    if (delta === 0) return
    const start = performance.now()
    const dur = Math.min(700, 200 + Math.abs(delta) * 0.6)
    const tick = (t) => {
      const p = Math.min(1, (t - start) / dur)
      const eased = 1 - Math.pow(1 - p, 3)
      setShown(Math.round(from + delta * eased))
      if (p < 1) raf.current = requestAnimationFrame(tick)
    }
    raf.current = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(raf.current)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value])
  return <span className={className} style={style}>{shown}</span>
}

/** Ranked results board with a podium feel. */
export function Results({ rows, accent = '#00E5B0' }) {
  return (
    <ul className="w-full max-w-sm space-y-2">
      {rows.map((r, i) => (
        <li
          key={i}
          className="flex items-center justify-between rounded-xl px-4 py-3 animate-riseIn border"
          style={{
            animationDelay: `${i * 90}ms`,
            animationFillMode: 'backwards',
            background: i === 0 ? (r.color || accent) + '1A' : 'rgba(255,255,255,0.04)',
            borderColor: i === 0 ? (r.color || accent) + '55' : 'transparent',
          }}
        >
          <span className="flex items-center gap-3 min-w-0">
            <span className="text-xs text-muted w-4 shrink-0">{i + 1}</span>
            <span className="truncate" style={{ color: r.color || '#EAEAF2' }}>{r.name}</span>
          </span>
          <span className="flex items-center gap-4 text-sm shrink-0">
            {r.note && <span className="text-muted">{r.note}</span>}
            {r.value != null && (
              <Odometer value={r.value} className="font-display text-xl text-fg" />
            )}
          </span>
        </li>
      ))}
    </ul>
  )
}

/** Animated loading state shown while the model downloads. */
export function Loading({ label, accent = '#00E5B0' }) {
  return (
    <Screen accent={accent}>
      <div className="relative mb-7" style={{ width: 96, height: 96 }}>
        <span className="absolute inset-0 rounded-full border-2 animate-ping-slow" style={{ borderColor: accent + '55' }} />
        <span className="absolute inset-3 rounded-full border-2 animate-ping-slow" style={{ borderColor: accent + '33', animationDelay: '400ms' }} />
        <span className="absolute inset-0 rounded-full border-[3px] border-transparent animate-spin" style={{ borderTopColor: accent }} />
      </div>
      <p className="text-muted animate-pulseSoft">{label}</p>
    </Screen>
  )
}

export function ErrorScreen({ message }) {
  return (
    <Screen accent="#FF7A45">
      <h2 className="font-display text-3xl mb-3">Camera not available</h2>
      <p className="text-muted max-w-sm text-center">{message}</p>
    </Screen>
  )
}
