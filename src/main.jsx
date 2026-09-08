import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider, NavLink, Link, Outlet, useLocation } from 'react-router-dom'
import Home from './pages/Home.jsx'
import Quickdraw from './pages/Quickdraw.jsx'
import PoseMatch from './pages/PoseMatch.jsx'
import Orbs from './pages/Orbs.jsx'
import Paint from './pages/Paint.jsx'
import Rocket from './pages/Rocket.jsx'
import Dance from './pages/Dance.jsx'
import Kinetic from './pages/Kinetic.jsx'
import Dojo from './pages/Dojo.jsx'
import Rift from './pages/Rift.jsx'
import Arcane from './pages/Arcane.jsx'
import Admin from './pages/Admin.jsx'
import { installUnlockListener, setMuted, isMuted, stopMusic, sfx } from './lib/audio.js'
import './index.css'

const NAV = [
  { to: '/', label: 'Games', end: true },
  { to: '/dojo', label: 'Dojo' },
  { to: '/rift', label: 'Rift' },
  { to: '/arcane', label: 'Arcane' },
  { to: '/kinetic', label: 'Kinetic' },
  { to: '/rocket', label: 'Rocket' },
  { to: '/dance', label: 'Dance' },
  { to: '/admin', label: 'Dashboard' },
]

function SoundToggle() {
  const [off, setOff] = useState(isMuted())
  return (
    <button
      onClick={() => { const v = !off; setOff(v); setMuted(v); if (!v) sfx.click() }}
      className="shrink-0 rounded-lg p-2 text-muted hover:text-fg transition-colors"
      aria-label={off ? 'Turn sound on' : 'Turn sound off'}
      title={off ? 'Sound off' : 'Sound on'}
    >
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="M4 9v6h4l5 4V5L8 9H4z" fill="currentColor" />
        {off ? (
          <path d="M17 9l5 6M22 9l-5 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
        ) : (
          <>
            <path d="M16.5 8.5a5 5 0 010 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            <path d="M19.5 6a9 9 0 010 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" opacity="0.6" />
          </>
        )}
      </svg>
    </button>
  )
}

function FullscreenToggle() {
  const [on, setOn] = useState(false)
  useEffect(() => {
    const sync = () => setOn(!!document.fullscreenElement)
    document.addEventListener('fullscreenchange', sync)
    return () => document.removeEventListener('fullscreenchange', sync)
  }, [])
  return (
    <button
      onClick={() => {
        sfx.click()
        if (document.fullscreenElement) document.exitFullscreen()
        else document.documentElement.requestFullscreen?.().catch(() => {})
      }}
      className="shrink-0 rounded-lg p-2 text-muted hover:text-fg transition-colors"
      aria-label={on ? 'Leave fullscreen' : 'Go fullscreen'}
      title={on ? 'Leave fullscreen' : 'Fullscreen'}
    >
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        {on ? (
          <path d="M9 3v6H3M15 21v-6h6M9 21v-6H3M15 3v6h6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        ) : (
          <path d="M3 9V3h6M21 9V3h-6M3 15v6h6M21 15v6h-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        )}
      </svg>
    </button>
  )
}

function Shell() {
  const { pathname } = useLocation()
  // Leaving a game should never leave its music playing underneath the next one.
  useEffect(() => { stopMusic() }, [pathname])
  return (
    <div className="min-h-full flex flex-col">
      <header className="flex items-center justify-between gap-3 px-4 md:px-5 h-14 border-b border-line/60 backdrop-blur-md bg-ink/60 sticky top-0 z-20">
        <Link to="/" className="font-display font-700 tracking-tight text-lg shrink-0" onPointerEnter={() => sfx.hover()}>
          Hand<span className="text-mint">Play</span>
        </Link>
        <nav className="flex items-center gap-0.5 text-sm overflow-x-auto no-bar">
          {NAV.map((n) => (
            <NavLink
              key={n.to}
              to={n.to}
              end={n.end}
              onPointerEnter={() => sfx.hover()}
              onClick={() => sfx.click()}
              className={({ isActive }) =>
                'relative px-3 py-1.5 rounded-lg whitespace-nowrap transition-colors ' +
                (isActive ? 'text-fg' : 'text-muted hover:text-fg')
              }
            >
              {({ isActive }) => (
                <>
                  {n.label}
                  {isActive && (
                    <span className="absolute inset-x-2 -bottom-[9px] h-[2px] rounded-full bg-mint" aria-hidden="true" />
                  )}
                </>
              )}
            </NavLink>
          ))}
        </nav>
        <div className="flex items-center shrink-0">
          <FullscreenToggle />
          <SoundToggle />
        </div>
      </header>
      <main className="flex-1 min-h-0">
        <Outlet />
      </main>
    </div>
  )
}

const router = createBrowserRouter([
  {
    path: '/',
    element: <Shell />,
    children: [
      { index: true, element: <Home /> },
      { path: 'duel', element: <Quickdraw /> },
      { path: 'copy', element: <PoseMatch /> },
      { path: 'orbs', element: <Orbs /> },
      { path: 'paint', element: <Paint /> },
      { path: 'rocket', element: <Rocket /> },
      { path: 'dance', element: <Dance /> },
      { path: 'kinetic', element: <Kinetic /> },
      { path: 'dojo', element: <Dojo /> },
      { path: 'rift', element: <Rift /> },
      { path: 'arcane', element: <Arcane /> },
      { path: 'admin', element: <Admin /> },
      { path: '*', element: <Home /> },
    ],
  },
])

installUnlockListener()

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
)
