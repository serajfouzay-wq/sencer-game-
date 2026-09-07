import React from 'react'
import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider, NavLink, Link, Outlet } from 'react-router-dom'
import Home from './pages/Home.jsx'
import Quickdraw from './pages/Quickdraw.jsx'
import PoseMatch from './pages/PoseMatch.jsx'
import Orbs from './pages/Orbs.jsx'
import Paint from './pages/Paint.jsx'
import Rocket from './pages/Rocket.jsx'
import Dance from './pages/Dance.jsx'
import Kinetic from './pages/Kinetic.jsx'
import Admin from './pages/Admin.jsx'
import './index.css'

const NAV = [
  { to: '/', label: 'Games', end: true },
  { to: '/kinetic', label: 'Kinetic' },
  { to: '/rocket', label: 'Rocket' },
  { to: '/dance', label: 'Dance' },
  { to: '/paint', label: 'Paint' },
  { to: '/duel', label: 'Duel' },
  { to: '/admin', label: 'Dashboard' },
]

function Shell() {
  return (
    <div className="min-h-full flex flex-col">
      <header className="flex items-center justify-between gap-4 px-5 h-14 border-b border-line/60 backdrop-blur bg-ink/50 sticky top-0 z-20">
        <Link to="/" className="font-display font-700 tracking-tight text-lg shrink-0">
          Hand<span className="text-mint">Play</span>
        </Link>
        <nav className="flex items-center gap-0.5 text-sm overflow-x-auto">
          {NAV.map((n) => (
            <NavLink
              key={n.to}
              to={n.to}
              end={n.end}
              className={({ isActive }) =>
                'px-3 py-1.5 rounded-lg whitespace-nowrap transition-colors ' +
                (isActive ? 'bg-surface2 text-fg' : 'text-muted hover:text-fg')
              }
            >
              {n.label}
            </NavLink>
          ))}
        </nav>
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
      { path: 'admin', element: <Admin /> },
      { path: '*', element: <Home /> },
    ],
  },
])

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
)
