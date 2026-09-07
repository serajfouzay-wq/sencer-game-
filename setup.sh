#!/usr/bin/env bash
set -e
echo "Creating HandPlay..."
mkdir -p src/lib src/pages test public
cat > package.json <<'HANDPLAY_EOF'
{
  "name": "handplay",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview --host"
  },
  "dependencies": {
    "@mediapipe/tasks-vision": "0.10.14",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.2"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.13",
    "vite": "^5.4.8"
  }
}
HANDPLAY_EOF
cat > vite.config.js <<'HANDPLAY_EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
})
HANDPLAY_EOF
cat > postcss.config.js <<'HANDPLAY_EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
HANDPLAY_EOF
cat > tailwind.config.js <<'HANDPLAY_EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#0A0A12',
        surface: '#151521',
        surface2: '#1E1E2E',
        line: '#2A2A3C',
        mint: '#00E5B0',
        violet: '#7C5CFF',
        ember: '#FF7A45',
        fg: '#EAEAF2',
        muted: '#8A8AA0',
        p1: '#FFB000',
        p2: '#00D4FF',
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'system-ui', 'sans-serif'],
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        glow: '0 0 24px rgba(0,229,176,0.35)',
        glowv: '0 0 24px rgba(124,92,255,0.35)',
      },
    },
  },
  plugins: [],
}
HANDPLAY_EOF
cat > index.html <<'HANDPLAY_EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>HandPlay — control it with your hands</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
HANDPLAY_EOF
cat > vercel.json <<'HANDPLAY_EOF'
{
  "rewrites": [{ "source": "/(.*)", "destination": "/" }]
}
HANDPLAY_EOF
cat > USER_MANUAL.md <<'HANDPLAY_EOF'
# HandPlay — Setup & Operation Manual

Three camera games that run entirely in the browser. No video ever leaves the
machine, and there is no backend to run.

| Game | Players | Tracks |
|---|---|---|
| Kinetic | Up to 4 hands | Hands |
| Rocket Rush | 1v1, up to 4, or 2v2 teams | Hands |
| Dance Floor | Solo, 1v1, up to 4 | Full body |
| The Fastest in the Hood | 2 (or 1 vs the machine) | Hands |
| Air Canvas | Up to 4 hands | Hands |
| Copy That | 1 | Full body |
| Orb Catcher | 1 | Hands |

---

## Part 1 — Get it running in your Codespace

**1. Open your Codespace** on the repository you want this in.

**2. Upload `setup.sh`** — drag it into the file explorer on the left.

**3. Run it.** In the terminal:

```bash
bash setup.sh
```

This writes every project file and installs the dependencies. It takes about 30
seconds.

**4. Start the dev server:**

```bash
npm run dev
```

**5. Open the app.** Codespaces shows a popup saying a port is available — click
**Open in Browser**.

> **Important:** you must open it in a real browser tab. The small preview pane
> inside the editor cannot use a camera. If no popup appears, go to the **Ports**
> tab, find port 5173, and click the globe icon.

**6. Allow the camera** when the browser asks. Then pick a game.

---

## Part 2 — Push to GitHub

If you started from an empty Codespace, save your work:

```bash
git add -A
git commit -m "Add HandPlay camera games"
git push
```

If the repository is brand new and git complains there is no remote, create the
repo on github.com first, then:

```bash
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
git branch -M main
git push -u origin main
```

---

## Part 3 — Host it on Vercel

1. Go to **vercel.com** and sign in with GitHub.
2. Click **Add New → Project**.
3. Pick your repository and click **Import**.
4. Leave every setting alone. Vercel detects Vite by itself:
   - Framework Preset: **Vite**
   - Build Command: `npm run build`
   - Output Directory: `dist`
5. Click **Deploy**.

After about a minute you get a live URL like `your-project.vercel.app`. The
camera works there automatically because Vercel serves over HTTPS.

Every future `git push` redeploys the site on its own.

> A `vercel.json` file is included so that refreshing on `/duel` or `/admin`
> loads correctly instead of showing a 404.

---

## Part 4 — How to play

### Kinetic

The showpiece. Move things without touching them.

- **Open palm** — a force field pushes every nearby orb away. Spread your
  fingers wider for more power.
- **Close your fist** — the nearest orb snaps into your grip and follows your
  hand.
- **Open your hand again** — you let go, and the orb flies off carrying whatever
  speed your hand was moving at.

Land orbs in the ring on the right. The faster they arrive, the more they score.
Up to four hands at once, so two people can play together. 75 seconds.

### Rocket Rush

1. Pick a mode: **1v1**, **3 players**, **4 players**, or **2v2 teams**.
2. Everyone raises one hand. Stand left to right — the leftmost person is
   Player 1. When the ring fills, you launch.
3. Move your hand up and down to fly. Thread the gap in each gate.
4. One clip and you are out. Last rocket flying wins. In teams, the last team
   with anyone still airborne wins.

The gates speed up and the gaps narrow the further you get.

### Dance Floor

1. Pick a routine (**Warm Up**, **Floor Filler**, or **Show Off**) and how many
   dancers.
2. Everyone steps into frame, full body visible, standing side by side.
3. A figure holds a shape. Match it before the bar at the bottom runs out.
4. Every beat is graded **PERFECT / GREAT / GOOD / MISS**. Consecutive hits build
   a combo multiplier.
5. Highest score wins.

Your limbs turn green as they line up, so people learn it instantly.

### Air Canvas

- **Point your index finger** (middle finger tucked) to paint.
- **Open your hand** to lift the pen and move without drawing.
- **Hover over a swatch** for about half a second to pick it up — colours in the
  middle, brush sizes on the left, backgrounds on the right, and *clear all*
  above them.
- Several people can draw at once, each with their own colour.
- **Save PNG** in the top-left downloads the artwork.

Lean closer to the camera for a thicker stroke.

### The Fastest in the Hood

A sundown duel. Two people, one camera.

1. Stand **one person on each side** of the camera. Player 1 on the left of the
   picture, player 2 on the right.
2. Drop your shooting hand **below the dotted belt line** and hold it there.
   Both players must be holstered before the round arms itself.
3. The screen says **Steady…** and waits a random 1.5 to 4 seconds. Move now and
   you hand the round to your rival.
4. On **DRAW!**, snap your hand into a finger gun — index finger out, other
   fingers curled — and raise it above the line. Fastest hand wins.
5. First to three rounds is the fastest in the hood.

Your reaction time is shown in milliseconds after every round.

**Duel the machine** lets one person play alone. The machine draws somewhere
between 260 and 600ms, which is roughly a real human's range.

### Copy That

1. Stand back about 2 metres so your legs are in frame.
2. A glowing purple figure strikes a pose. Copy it.
3. Your own skeleton is drawn over the top — each limb turns **red → amber →
   green** as it lines up. Chase the green.
4. Get above 72% and hold it for half a second to bank the pose. The ring in the
   corner shows your match, and the outer arc shows the hold.
5. Six poses per round. Banking a pose quickly earns a time bonus.

If only your upper body is visible the game still works — it scores the limbs it
can see and tells you to step back.

### Orb Catcher

Sweep falling orbs with your hand. Pinch thumb and finger together to blast
everything nearby. Sixty seconds.

---

## Part 5 — The dashboard

At `/admin`. Built for someone non-technical to operate.

**Stats** — rounds played, high score, average, and the fastest draw ever
recorded. Filter by game using the buttons at the top.

**Camera & tracking**
- *Mirror the camera* — on by default, so moving right moves right on screen.
- *Show the tracked skeleton* — turn off for a cleaner look on a big display.
- *Hands to track in Orb Catcher* — one or two. The duel always uses two.
- *Detection sensitivity* — **lower it in a dim room** so hands are found more
  easily; **raise it in a busy room** so background people are ignored. This is
  the single most useful dial at a live event.

Everything saves automatically to that browser. **Clear history** wipes the
scores.

---

## Part 6 — Running it at an event

- **Light the players from the front.** Backlight (a window behind them) is the
  number one cause of poor tracking. A lamp beside the camera fixes most issues.
- **Set the camera at chest height** and far enough back that two people fit in
  frame for the duel, or a whole body for Copy That.
- **Do a sensitivity pass on site.** Open the dashboard, play a round, and nudge
  the slider until tracking feels locked in.
- **Press F11** for fullscreen on the display.
- **Load each game once before doors open.** The tracking models download from a
  CDN on first use and are cached afterwards.
- The venue needs internet **once** to fetch the models. After that the games run
  locally.

---

## Part 7 — Troubleshooting

**"Camera access was blocked."**
Click the padlock in the address bar, set Camera to Allow, reload.

**Nothing happens / no camera prompt.**
Check the address starts with `https://` (or `localhost`). Cameras are blocked
on plain `http://`.

**The OBSBOT isn't the camera being used.**
The browser picks a default. In Chrome: padlock → Site settings → Camera →
choose the OBSBOT, then reload.

**Tracking is jumpy.**
Add light in front of the players, then lower the sensitivity slider a little.

**Players swapped rockets mid-game.**
They shouldn't — each hand is given a stable id that survives crossing over and
brief dropouts. If it still happens the camera is likely losing hands entirely;
raise the light level and lower the sensitivity slider.

**A player can't join the round.**
In Rocket Rush and Dance Floor everyone must be visible *before* the ring fills.
If someone dropped out mid-round they can rejoin by putting their hand back up.

**The duel says "show your hand" for one player.**
That player is outside their half of the frame. Player 1 must be on the left of
the picture, player 2 on the right. Move the camera back.

**Copy That won't register my legs.**
Step further back. The message at the bottom tells you when your body is only
partly visible.

**It runs slowly on an old laptop.**
Close other tabs. The body model is the heaviest — the two hand games are much
lighter.

---

## Part 8 — Project layout

```
src/
  main.jsx              routing and the top navigation
  index.css             theme, buttons, animations
  lib/
    useVision.js        loads MediaPipe + the webcam, shared by all games
    gestures.js         finger-gun detection, holster and draw logic
    poses.js            the pose library, dance routines, matching maths
    tracking.js         keeps a stable id on each hand and person
    canvas.js           canvas sizing, the revolver, muzzle flash
    storage.js          settings and scores saved in the browser
  pages/
    Home.jsx            game picker
    Kinetic.jsx         Kinetic
    Rocket.jsx          Rocket Rush
    Dance.jsx           Dance Floor
    Quickdraw.jsx       The Fastest in the Hood
    Paint.jsx           Air Canvas
    PoseMatch.jsx       Copy That
    Orbs.jsx            Orb Catcher
    Admin.jsx           dashboard
test/
  logic.test.mjs        checks the gesture and pose maths
```

Run the logic tests any time with:

```bash
node test/logic.test.mjs
```

### Tuning the games

| What | Where | Line |
|---|---|---|
| Rounds needed to win the duel | `src/pages/Quickdraw.jsx` | `WINS_NEEDED` |
| Belt line height | `src/lib/gestures.js` | `BELT_Y` |
| How close a pose must be | `src/pages/PoseMatch.jsx` | `LOCK_SCORE` |
| Seconds per pose | `src/pages/PoseMatch.jsx` | `SECONDS_PER_POSE` |
| Poses per round | `src/pages/PoseMatch.jsx` | `ROUND_POSES` |
| Kinetic round length | `src/pages/Kinetic.jsx` | `ROUND_SECONDS` |
| Grab / push reach | `src/pages/Kinetic.jsx` | `GRAB_RADIUS`, `FIELD_RADIUS` |
| Dance beat speed | `src/lib/poses.js` | `beatMs` in `ROUTINE_DATA` |
| Dance grade cutoffs | `src/pages/Dance.jsx` | `GRADES` |

### Adding your own pose

Open `src/lib/poses.js` and add an entry to `POSES`. Positions are given as
fractions of the figure's box, and only the joints that move need listing —
everything else falls back to a standing figure.

```js
pose('Salute', 'Right hand up to your forehead', {
  14: { x: 0.34, y: 0.30 },   // right elbow
  16: { x: 0.46, y: 0.16 },   // right wrist
}),
```

Remember MediaPipe's naming is from the player's point of view: index 12/14/16
is their **right** arm, which appears on the **left** of the picture.

After adding a pose, run `node test/logic.test.mjs` — it checks that your new
pose can't be confused with an existing one.
HANDPLAY_EOF
mkdir -p src
cat > src/index.css <<'HANDPLAY_EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { color-scheme: dark; }

html, body, #root { height: 100%; }
body {
  margin: 0;
  background: radial-gradient(1200px 800px at 70% -10%, #1a1730 0%, #0A0A12 55%);
  color: #EAEAF2;
  font-family: Inter, system-ui, sans-serif;
  -webkit-font-smoothing: antialiased;
}

@layer components {
  .btn-primary {
    @apply inline-flex items-center justify-center rounded-xl bg-mint px-6 py-3
           font-medium text-ink shadow-glow transition-transform;
  }
  .btn-primary:hover { transform: translateY(-1px); }
  .btn-primary:active { transform: translateY(0); }
  .btn-primary:focus-visible { outline: 2px solid #EAEAF2; outline-offset: 2px; }

  .btn-ghost {
    @apply inline-flex items-center justify-center rounded-xl border border-line
           bg-white/5 px-6 py-3 font-medium text-fg transition-colors;
  }
  .btn-ghost:hover { background: rgba(255,255,255,0.10); }
  .btn-ghost:focus-visible { outline: 2px solid #EAEAF2; outline-offset: 2px; }
}

.calibrate {
  width: 56px;
  height: 56px;
  border-radius: 9999px;
  border: 3px solid rgba(124, 92, 255, 0.25);
  border-top-color: #00E5B0;
  animation: spin 0.9s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

@keyframes pop {
  from { transform: scale(0.7); opacity: 0; }
  to   { transform: scale(1); opacity: 1; }
}

@media (prefers-reduced-motion: reduce) {
  * { animation: none !important; transition: none !important; }
}
HANDPLAY_EOF
mkdir -p src
cat > src/main.jsx <<'HANDPLAY_EOF'
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
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/storage.js <<'HANDPLAY_EOF'
// Simple localStorage-backed store. No backend needed — perfect for Vercel.

const SETTINGS_KEY = 'handplay.settings'
const SESSIONS_KEY = 'handplay.sessions'

export const defaultSettings = {
  numHands: 1,        // 1 or 2
  mirror: true,       // mirror the camera like a selfie
  showSkeleton: true, // draw the hand skeleton
  sensitivity: 0.6,   // min detection confidence (0.3 - 0.9)
}

export function loadSettings() {
  try {
    const raw = localStorage.getItem(SETTINGS_KEY)
    return raw ? { ...defaultSettings, ...JSON.parse(raw) } : { ...defaultSettings }
  } catch {
    return { ...defaultSettings }
  }
}

export function saveSettings(settings) {
  try {
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings))
  } catch (e) {
    console.error('Could not save settings', e)
  }
}

export function loadSessions() {
  try {
    const raw = localStorage.getItem(SESSIONS_KEY)
    return raw ? JSON.parse(raw) : []
  } catch {
    return []
  }
}

export function addSession(session) {
  const sessions = loadSessions()
  sessions.unshift({ game: 'orbs', ...session, at: Date.now() })
  const trimmed = sessions.slice(0, 100)
  try {
    localStorage.setItem(SESSIONS_KEY, JSON.stringify(trimmed))
  } catch (e) {
    console.error('Could not save session', e)
  }
  return trimmed
}

export function clearSessions() {
  localStorage.removeItem(SESSIONS_KEY)
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/useVision.js <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { HandLandmarker, PoseLandmarker, FilesetResolver } from '@mediapipe/tasks-vision'

// Keep this in sync with the @mediapipe/tasks-vision version in package.json.
const VISION_VERSION = '0.10.14'
const WASM_URL = `https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@${VISION_VERSION}/wasm`

const MODELS = {
  hand: 'https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task',
  pose: 'https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task',
}

/**
 * Loads a MediaPipe landmarker and the webcam, and hands back a detect()
 * function that is safe to call from a requestAnimationFrame loop.
 *
 * status: 'loading-model' | 'starting-camera' | 'ready' | 'error'
 */
export function useVision({ task = 'hand', numHands = 2, numPoses = 1, sensitivity = 0.6 } = {}) {
  const videoRef = useRef(null)
  const landmarkerRef = useRef(null)
  const streamRef = useRef(null)
  const lastVideoTimeRef = useRef(-1)
  const lastStampRef = useRef(-1)
  const lastResultRef = useRef(null)

  const [status, setStatus] = useState('loading-model')
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false

    async function init() {
      try {
        setStatus('loading-model')
        const vision = await FilesetResolver.forVisionTasks(WASM_URL)
        if (cancelled) return

        let landmarker
        if (task === 'pose') {
          landmarker = await PoseLandmarker.createFromOptions(vision, {
            baseOptions: { modelAssetPath: MODELS.pose, delegate: 'GPU' },
            runningMode: 'VIDEO',
            numPoses,
            minPoseDetectionConfidence: sensitivity,
            minPosePresenceConfidence: sensitivity,
            minTrackingConfidence: sensitivity,
          })
        } else {
          landmarker = await HandLandmarker.createFromOptions(vision, {
            baseOptions: { modelAssetPath: MODELS.hand, delegate: 'GPU' },
            runningMode: 'VIDEO',
            numHands,
            minHandDetectionConfidence: sensitivity,
            minHandPresenceConfidence: sensitivity,
            minTrackingConfidence: sensitivity,
          })
        }
        if (cancelled) {
          landmarker.close()
          return
        }
        landmarkerRef.current = landmarker

        setStatus('starting-camera')
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { width: { ideal: 1280 }, height: { ideal: 720 }, facingMode: 'user' },
          audio: false,
        })
        if (cancelled) {
          stream.getTracks().forEach((t) => t.stop())
          return
        }
        streamRef.current = stream
        const video = videoRef.current
        if (video) {
          video.srcObject = stream
          await video.play()
        }
        setStatus('ready')
      } catch (e) {
        console.error(e)
        if (cancelled) return
        const name = e && e.name
        setError(
          name === 'NotAllowedError'
            ? 'Camera access was blocked. Allow the camera for this site, then reload the page.'
            : name === 'NotFoundError'
              ? 'No camera was found. Plug in your OBSBOT and reload the page.'
              : 'Could not load the model or start the camera. Check your internet connection and reload.'
        )
        setStatus('error')
      }
    }

    init()

    return () => {
      cancelled = true
      if (streamRef.current) streamRef.current.getTracks().forEach((t) => t.stop())
      streamRef.current = null
      if (landmarkerRef.current) landmarkerRef.current.close()
      landmarkerRef.current = null
      lastVideoTimeRef.current = -1
      lastStampRef.current = -1
      lastResultRef.current = null
    }
  }, [task, numHands, numPoses, sensitivity])

  /**
   * Runs detection for the current frame. Only re-runs the model when the video
   * has actually advanced, and never reuses a timestamp (MediaPipe throws on
   * non-increasing timestamps). Returns the most recent result either way.
   */
  function detect(timeMs) {
    const lm = landmarkerRef.current
    const video = videoRef.current
    if (!lm || !video || video.readyState < 2 || !video.videoWidth) return lastResultRef.current

    if (video.currentTime === lastVideoTimeRef.current) return lastResultRef.current
    lastVideoTimeRef.current = video.currentTime

    const stamp = timeMs <= lastStampRef.current ? lastStampRef.current + 1 : timeMs
    lastStampRef.current = stamp

    try {
      lastResultRef.current = lm.detectForVideo(video, stamp)
    } catch (e) {
      // A dropped frame should never kill the game loop.
      console.warn('detect skipped', e)
    }
    return lastResultRef.current
  }

  return { videoRef, status, error, detect }
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/gestures.js <<'HANDPLAY_EOF'
// Gesture maths for "Fastest in the Hood".
//
// MediaPipe hand landmarks: 0 = wrist, 4 = thumb tip, 8 = index tip,
// 12 = middle tip, 16 = ring tip, 20 = pinky tip.

export const HAND_CONNECTIONS = [
  [0, 1], [1, 2], [2, 3], [3, 4],
  [0, 5], [5, 6], [6, 7], [7, 8],
  [5, 9], [9, 10], [10, 11], [11, 12],
  [9, 13], [13, 14], [14, 15], [15, 16],
  [13, 17], [17, 18], [18, 19], [19, 20],
  [0, 17],
]

// Vertical thresholds in normalised video coordinates (y grows downward).
export const BELT_Y = 0.60   // at or below this line counts as "holstered"
export const RAISE_Y = 0.52  // clearly above the belt — used for false starts
export const FIRE_Y = 0.55   // must clear this to register a shot

const dist = (a, b) => Math.hypot(a.x - b.x, a.y - b.y)

// A finger counts as extended when its tip is meaningfully further from the
// wrist than its middle joint. The 1.12 factor stops jitter from flickering.
function extended(lm, tip, pip) {
  return dist(lm[tip], lm[0]) > dist(lm[pip], lm[0]) * 1.12
}

export function fingerStates(lm) {
  return {
    index: extended(lm, 8, 6),
    middle: extended(lm, 12, 10),
    ring: extended(lm, 16, 14),
    pinky: extended(lm, 20, 18),
    // The thumb pivots sideways, so compare it to the index knuckle instead.
    thumb: dist(lm[4], lm[5]) > dist(lm[2], lm[5]) * 1.15,
  }
}

/**
 * Distance from the wrist to the middle knuckle. Everything else is measured
 * against this so gestures behave the same whether a hand is close to the
 * camera or across the room.
 */
export function handSpan(lm) {
  return Math.max(1e-4, dist(lm[0], lm[9]))
}

/** Centre of the palm — steadier than the wrist for cursors and forces. */
export function palmCenter(lm) {
  const ids = [0, 5, 9, 13, 17]
  let x = 0, y = 0
  for (const i of ids) {
    x += lm[i].x
    y += lm[i].y
  }
  return { x: x / ids.length, y: y / ids.length }
}

/** How many of the four fingers are extended. */
export function extendedCount(lm) {
  const f = fingerStates(lm)
  return [f.index, f.middle, f.ring, f.pinky].filter(Boolean).length
}

/** Thumb and index tips brought together. 0 = wide open, 1 = fully closed. */
export function pinchAmount(lm) {
  const d = dist(lm[4], lm[8]) / handSpan(lm)
  return Math.max(0, Math.min(1, 1 - (d - 0.25) / 0.55))
}

export function isPinching(lm) {
  return pinchAmount(lm) > 0.7
}

/** Flat hand, fingers spread — used to push things away. */
export function isOpenPalm(lm) {
  return extendedCount(lm) >= 3
}

/** Closed hand — used to grab. */
export function isFist(lm) {
  return extendedCount(lm) === 0
}

/** Index out, middle tucked: the drawing pose. */
export function isPointing(lm) {
  const f = fingerStates(lm)
  return f.index && !f.middle
}

/** How wide the hand is opened, 0 (fist) to 1 (spread). Used for force fields. */
export function openness(lm) {
  const tips = [8, 12, 16, 20]
  const span = handSpan(lm)
  let sum = 0
  for (const t of tips) sum += dist(lm[t], lm[0]) / span
  return Math.max(0, Math.min(1, (sum / tips.length - 1.1) / 1.0))
}

/** Classic finger gun: index out, the other three curled in. */
export function isGunGesture(lm) {
  const f = fingerStates(lm)
  return f.index && !f.middle && !f.ring && !f.pinky
}

/** Thumb up alongside the gun = hammer cocked (used for the visual flourish). */
export function isHammerCocked(lm) {
  return isGunGesture(lm) && fingerStates(lm).thumb
}

/** Unit vector the finger gun is pointing along, from knuckle to fingertip. */
export function aimVector(lm) {
  const dx = lm[8].x - lm[5].x
  const dy = lm[8].y - lm[5].y
  const m = Math.hypot(dx, dy) || 1
  return { x: dx / m, y: dy / m }
}

/**
 * Reads one hand into the state the duel cares about.
 * `sx` is the hand's x position after mirroring, so 0 is screen-left.
 */
export function readHand(lm, mirror) {
  const wrist = lm[0]
  const sx = mirror ? 1 - wrist.x : wrist.x
  return {
    lm,
    sx,
    sy: wrist.y,
    holstered: wrist.y >= BELT_Y,
    raised: wrist.y < RAISE_Y,
    gun: isGunGesture(lm),
    cocked: isHammerCocked(lm),
    firing: isGunGesture(lm) && wrist.y < FIRE_Y,
    aim: aimVector(lm),
  }
}

/**
 * Splits the detected hands between the two duellists by screen half.
 * Player 1 stands on the left of the frame, player 2 on the right.
 * If someone shows both hands, the one nearest their own edge is used.
 */
export function assignPlayers(landmarksList, mirror) {
  const slots = [null, null]
  for (const lm of landmarksList) {
    const h = readHand(lm, mirror)
    const idx = h.sx < 0.5 ? 0 : 1
    const held = slots[idx]
    if (!held) {
      slots[idx] = h
    } else {
      // Keep whichever hand sits closer to that player's outer edge.
      const better = idx === 0 ? h.sx < held.sx : h.sx > held.sx
      if (better) slots[idx] = h
    }
  }
  return slots
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/poses.js <<'HANDPLAY_EOF'
// Pose library + scoring for "Copy That".
//
// Poses are authored in isotropic (square) normalised space using MediaPipe's
// own landmark indices, so the same data both draws the target and scores the
// player. Remember MediaPipe mirrors naming: index 12 is the person's RIGHT
// shoulder and appears on the LEFT of the raw camera image.

export const L = {
  nose: 0,
  lShoulder: 11, rShoulder: 12,
  lElbow: 13, rElbow: 14,
  lWrist: 15, rWrist: 16,
  lHip: 23, rHip: 24,
  lKnee: 25, rKnee: 26,
  lAnkle: 27, rAnkle: 28,
}

export const POSE_CONNECTIONS = [
  [12, 11], [12, 14], [14, 16], [11, 13], [13, 15],
  [12, 24], [11, 23], [24, 23],
  [24, 26], [26, 28], [23, 25], [25, 27],
]

// Limbs that get scored. Comparing the DIRECTION each bone points in — rather
// than the angle at a joint — is what separates "arms up in a V" from "arms
// straight out to the sides". A joint angle is only a magnitude, so it throws
// away exactly the information this game needs.
export const BONES = [
  { key: 'rUpperArm', a: 12, b: 14, label: 'right upper arm' },
  { key: 'rForearm', a: 14, b: 16, label: 'right forearm' },
  { key: 'lUpperArm', a: 11, b: 13, label: 'left upper arm' },
  { key: 'lForearm', a: 13, b: 15, label: 'left forearm' },
  { key: 'rThigh', a: 24, b: 26, label: 'right thigh' },
  { key: 'rShin', a: 26, b: 28, label: 'right shin' },
  { key: 'lThigh', a: 23, b: 25, label: 'left thigh' },
  { key: 'lShin', a: 25, b: 27, label: 'left shin' },
]

const stand = {
  0: { x: 0.50, y: 0.10 },
  12: { x: 0.41, y: 0.26 }, 11: { x: 0.59, y: 0.26 },
  14: { x: 0.36, y: 0.42 }, 13: { x: 0.64, y: 0.42 },
  16: { x: 0.34, y: 0.57 }, 15: { x: 0.66, y: 0.57 },
  24: { x: 0.44, y: 0.55 }, 23: { x: 0.56, y: 0.55 },
  26: { x: 0.43, y: 0.72 }, 25: { x: 0.57, y: 0.72 },
  28: { x: 0.42, y: 0.90 }, 27: { x: 0.58, y: 0.90 },
}

const pose = (name, hint, overrides) => ({ name, hint, points: { ...stand, ...overrides } })

export const POSES = [
  pose('T-Pose', 'Arms straight out to the sides', {
    14: { x: 0.28, y: 0.26 }, 16: { x: 0.15, y: 0.26 },
    13: { x: 0.72, y: 0.26 }, 15: { x: 0.85, y: 0.26 },
  }),
  pose('Star Jump', 'Arms up in a V, feet apart', {
    14: { x: 0.29, y: 0.18 }, 16: { x: 0.19, y: 0.08 },
    13: { x: 0.71, y: 0.18 }, 15: { x: 0.81, y: 0.08 },
    26: { x: 0.33, y: 0.74 }, 28: { x: 0.22, y: 0.90 },
    25: { x: 0.67, y: 0.74 }, 27: { x: 0.78, y: 0.90 },
  }),
  pose('Cactus Arms', 'Elbows out, forearms straight up', {
    14: { x: 0.28, y: 0.27 }, 16: { x: 0.28, y: 0.11 },
    13: { x: 0.72, y: 0.27 }, 15: { x: 0.72, y: 0.11 },
  }),
  pose('Hands on Hips', 'Elbows wide, hands resting on your hips', {
    14: { x: 0.29, y: 0.43 }, 16: { x: 0.42, y: 0.53 },
    13: { x: 0.71, y: 0.43 }, 15: { x: 0.58, y: 0.53 },
  }),
  pose('Disco Point', 'One arm up high, the other down and out', {
    14: { x: 0.34, y: 0.15 }, 16: { x: 0.28, y: 0.03 },
    13: { x: 0.67, y: 0.44 }, 15: { x: 0.74, y: 0.60 },
  }),
  pose('The Teapot', 'One arm arched overhead, one hand on your hip', {
    14: { x: 0.33, y: 0.16 }, 16: { x: 0.45, y: 0.06 },
    13: { x: 0.71, y: 0.43 }, 15: { x: 0.58, y: 0.53 },
  }),
  pose('Flex', 'Elbows down by your sides, forearms curled up', {
    14: { x: 0.30, y: 0.40 }, 16: { x: 0.35, y: 0.22 },
    13: { x: 0.70, y: 0.40 }, 15: { x: 0.65, y: 0.22 },
  }),
  pose('Sumo Squat', 'Drop low with your knees pushed wide, arms straight out', {
    0: { x: 0.50, y: 0.24 },
    12: { x: 0.41, y: 0.38 }, 11: { x: 0.59, y: 0.38 },
    14: { x: 0.29, y: 0.38 }, 16: { x: 0.17, y: 0.38 },
    13: { x: 0.71, y: 0.38 }, 15: { x: 0.83, y: 0.38 },
    24: { x: 0.42, y: 0.66 }, 23: { x: 0.58, y: 0.66 },
    26: { x: 0.26, y: 0.72 }, 25: { x: 0.74, y: 0.72 },
    28: { x: 0.36, y: 0.92 }, 27: { x: 0.64, y: 0.92 },
  }),
]

/** Look a pose up by name; routines reference poses this way for readability. */
export function poseIndex(name) {
  const i = POSES.findIndex((p) => p.name === name)
  if (i < 0) throw new Error('Unknown pose: ' + name)
  return i
}

// Choreography. Each step holds for `beatMs`, so a routine reads as a rhythm
// rather than a list. Repeats are deliberate — a move you already know coming
// back later is what makes a routine feel like a dance instead of a quiz.
const ROUTINE_DATA = [
  {
    name: 'Warm Up',
    level: 'Easy',
    beatMs: 2600,
    steps: ['T-Pose', 'Y-ish', 'T-Pose', 'Hands on Hips', 'Cactus Arms', 'T-Pose'],
  },
  {
    name: 'Floor Filler',
    level: 'Medium',
    beatMs: 2000,
    steps: [
      'Cactus Arms', 'Disco Point', 'Cactus Arms', 'Hands on Hips',
      'Star Jump', 'Flex', 'Disco Point', 'T-Pose',
    ],
  },
  {
    name: 'Show Off',
    level: 'Hard',
    beatMs: 1500,
    steps: [
      'Star Jump', 'Sumo Squat', 'Flex', 'The Teapot',
      'Disco Point', 'Cactus Arms', 'Sumo Squat', 'Star Jump',
      'Flex', 'T-Pose',
    ],
  },
]

// 'Y-ish' isn't a real pose — swap in the closest one that is.
export const ROUTINES = ROUTINE_DATA.map((r) => ({
  ...r,
  steps: r.steps.map((n) => poseIndex(n === 'Y-ish' ? 'Cactus Arms' : n)),
}))

/** Unit direction from a to b, or null if it is degenerate. */
function direction(a, b) {
  const dx = b.x - a.x
  const dy = b.y - a.y
  const m = Math.hypot(dx, dy)
  if (m < 1e-6) return null
  return { x: dx / m, y: dy / m }
}

/** Angle in degrees between two unit vectors. */
function between(u, v) {
  const cos = Math.min(1, Math.max(-1, u.x * v.x + u.y * v.y))
  return (Math.acos(cos) * 180) / Math.PI
}

/**
 * Compares the player's landmarks against a target pose, limb by limb.
 *
 * Player landmarks are normalised per-axis, so x is stretched by the frame's
 * aspect ratio to make the space isotropic before anything is measured —
 * otherwise a 16:9 camera would skew every limb direction.
 *
 * Limbs whose landmarks aren't confidently visible are skipped, so the game
 * still works when only your upper body is in frame.
 */
export function scorePose(playerLandmarks, target, aspect) {
  const bones = {}
  let total = 0
  let counted = 0

  for (const bone of BONES) {
    const pa = playerLandmarks[bone.a]
    const pb = playerLandmarks[bone.b]
    const visible =
      pa && pb && (pa.visibility ?? 1) >= 0.5 && (pb.visibility ?? 1) >= 0.5

    if (!visible) {
      bones[bone.key] = { score: 0, visible: false }
      continue
    }

    const playerDir = direction(
      { x: pa.x * aspect, y: pa.y },
      { x: pb.x * aspect, y: pb.y }
    )
    const targetDir = direction(target.points[bone.a], target.points[bone.b])
    if (!playerDir || !targetDir) {
      bones[bone.key] = { score: 0, visible: false }
      continue
    }

    const diff = between(playerDir, targetDir)
    // Within 15 degrees is a clean match; past 70 degrees scores nothing.
    const s = Math.max(0, Math.min(1, 1 - Math.max(0, diff - 15) / 55))
    bones[bone.key] = { score: s, visible: true, diff }
    total += s
    counted += 1
  }

  // A plain average lets a wrong limb hide behind correct ones — copy a pose
  // but leave one arm down and six matching limbs would still read as "close".
  // So the mean is scaled by how bad the weakest limbs are. Two limbs are used
  // rather than a single minimum, otherwise one noisy landmark could wipe out
  // an otherwise perfect pose.
  const mean = counted ? total / counted : 0
  const ranked = Object.values(bones)
    .filter((b) => b.visible)
    .map((b) => b.score)
    .sort((a, b) => a - b)
  const take = Math.min(ranked.length, counted >= 4 ? 2 : 1)
  const weakest = take ? ranked.slice(0, take).reduce((a, b) => a + b, 0) / take : 0

  return {
    score: mean * (0.4 + 0.6 * weakest),
    mean,
    weakest,
    bones,
    counted,
    // Two limbs is enough to play — someone sitting close to the camera with
    // only their arms in frame should still get a game.
    enoughVisible: counted >= 2,
  }
}

/** Per-limb colour feedback: every drawn bone maps straight to its own score. */
export function boneScore(bones, a, b) {
  const bone = BONES.find(
    (x) => (x.a === a && x.b === b) || (x.a === b && x.b === a)
  )
  if (!bone) return null
  const r = bones[bone.key]
  return r && r.visible ? r.score : null
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/canvas.js <<'HANDPLAY_EOF'
import { useEffect } from 'react'

/** Keeps a canvas matched to its parent box and crisp on high-DPI screens. */
export function useCanvasSize(canvasRef) {
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const parent = canvas.parentElement
    const fit = () => {
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const w = parent.clientWidth
      const h = parent.clientHeight
      if (!w || !h) return
      canvas.width = Math.floor(w * dpr)
      canvas.height = Math.floor(h * dpr)
      canvas.style.width = w + 'px'
      canvas.style.height = h + 'px'
      canvas.getContext('2d').setTransform(dpr, 0, 0, dpr, 0, 0)
    }
    fit()
    const ro = new ResizeObserver(fit)
    ro.observe(parent)
    return () => ro.disconnect()
  }, [canvasRef])
}

/** Logical (CSS pixel) size of a canvas that useCanvasSize is managing. */
export function logicalSize(canvas) {
  const dpr = Math.min(window.devicePixelRatio || 1, 2)
  return { W: canvas.width / dpr, H: canvas.height / dpr }
}

export function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath()
  ctx.moveTo(x + r, y)
  ctx.arcTo(x + w, y, x + w, y + h, r)
  ctx.arcTo(x + w, y + h, x, y + h, r)
  ctx.arcTo(x, y + h, x, y, r)
  ctx.arcTo(x, y, x + w, y, r)
  ctx.closePath()
}

/** Red through amber to green, for match-quality feedback. */
export function scoreColor(s) {
  const hue = Math.round(s * 130) // 0 = red, 130 = green
  return `hsl(${hue} 85% 55%)`
}

/**
 * A stylised .44 revolver drawn from the grip outward.
 * `lift` runs 0 (holstered, muzzle down) to 1 (levelled and ready).
 */
export function drawRevolver(ctx, x, y, scale, lift, facing, cocked) {
  const s = scale
  ctx.save()
  ctx.translate(x, y)
  ctx.scale(facing, 1)
  // Holstered points down; fully drawn points level.
  ctx.rotate((1 - lift) * 1.15)

  const steel = ctx.createLinearGradient(0, -8 * s, 0, 8 * s)
  steel.addColorStop(0, '#D8DCE6')
  steel.addColorStop(0.45, '#8E94A6')
  steel.addColorStop(0.55, '#5A5F70')
  steel.addColorStop(1, '#2E313D')

  const wood = ctx.createLinearGradient(0, 0, 0, 20 * s)
  wood.addColorStop(0, '#7A4A2B')
  wood.addColorStop(1, '#43261492')

  // Grip
  ctx.fillStyle = wood
  ctx.beginPath()
  ctx.moveTo(-1 * s, 2 * s)
  ctx.lineTo(6 * s, 2 * s)
  ctx.lineTo(4 * s, 20 * s)
  ctx.lineTo(-4 * s, 19 * s)
  ctx.closePath()
  ctx.fill()

  // Frame + barrel
  ctx.fillStyle = steel
  roundRect(ctx, -3 * s, -6 * s, 15 * s, 9 * s, 2 * s)
  ctx.fill()
  roundRect(ctx, 10 * s, -4.5 * s, 22 * s, 5 * s, 1.5 * s)
  ctx.fill()

  // Cylinder
  ctx.beginPath()
  ctx.arc(6 * s, -1 * s, 5 * s, 0, Math.PI * 2)
  ctx.fill()
  ctx.strokeStyle = 'rgba(20,22,30,0.85)'
  ctx.lineWidth = 1 * s
  ctx.stroke()
  ctx.fillStyle = 'rgba(20,22,30,0.7)'
  for (let i = 0; i < 6; i++) {
    const a = (i / 6) * Math.PI * 2
    ctx.beginPath()
    ctx.arc(6 * s + Math.cos(a) * 2.6 * s, -1 * s + Math.sin(a) * 2.6 * s, 0.9 * s, 0, Math.PI * 2)
    ctx.fill()
  }

  // Hammer — snaps back when cocked
  ctx.fillStyle = '#3C404E'
  ctx.beginPath()
  ctx.moveTo(-2 * s, -5 * s)
  ctx.lineTo(cocked ? -6 * s : -3.5 * s, cocked ? -10 * s : -9 * s)
  ctx.lineTo(cocked ? -3 * s : -0.5 * s, cocked ? -9 * s : -8.5 * s)
  ctx.closePath()
  ctx.fill()

  // Trigger guard
  ctx.strokeStyle = '#6A7080'
  ctx.lineWidth = 1.6 * s
  ctx.beginPath()
  ctx.arc(3.5 * s, 5 * s, 3.4 * s, Math.PI * 0.9, Math.PI * 2.15)
  ctx.stroke()

  ctx.restore()
}

/** Muzzle flash burst, fading with `life` (1 → 0). */
export function drawMuzzleFlash(ctx, x, y, dir, life, scale = 1) {
  if (life <= 0) return
  const r = (26 + (1 - life) * 46) * scale
  ctx.save()
  ctx.translate(x, y)
  ctx.rotate(Math.atan2(dir.y, dir.x))
  ctx.globalAlpha = life
  const g = ctx.createRadialGradient(0, 0, 1, 0, 0, r)
  g.addColorStop(0, '#FFFFFF')
  g.addColorStop(0.3, '#FFD36E')
  g.addColorStop(0.65, '#FF8A2B')
  g.addColorStop(1, 'rgba(255,120,0,0)')
  ctx.fillStyle = g
  ctx.beginPath()
  ctx.ellipse(r * 0.45, 0, r, r * 0.55, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/tracking.js <<'HANDPLAY_EOF'
// MediaPipe returns detections in an arbitrary order that can shuffle between
// frames. For anything multi-player that is fatal — player 1 and player 3 would
// swap rockets mid-flight. This assigns each detection a stable id by matching
// it to the nearest track from the previous frame, and keeps a track alive for
// a short grace period so a momentary dropout doesn't reset anybody.

export function createTracker({ maxDist = 0.22, maxAge = 400 } = {}) {
  let tracks = []
  let nextId = 1

  return {
    /**
     * points: [{ x, y, data }] in normalised coordinates.
     * Returns live tracks, each carrying a stable `id`.
     */
    update(points, now) {
      const unmatched = points.map((p, i) => ({ p, i }))
      const claimed = new Set()

      // Greedy nearest-neighbour: score every track/detection pair, then take
      // the best pairs first so a close match wins over a distant one.
      const pairs = []
      for (const t of tracks) {
        for (const u of unmatched) {
          const d = Math.hypot(t.x - u.p.x, t.y - u.p.y)
          if (d <= maxDist) pairs.push({ t, u, d })
        }
      }
      pairs.sort((a, b) => a.d - b.d)

      const usedTracks = new Set()
      for (const { t, u } of pairs) {
        if (usedTracks.has(t.id) || claimed.has(u.i)) continue
        usedTracks.add(t.id)
        claimed.add(u.i)
        // Velocity is what makes throwing feel right in Kinetic.
        const dt = Math.max(1, now - t.lastSeen)
        t.vx = ((u.p.x - t.x) / dt) * 1000
        t.vy = ((u.p.y - t.y) / dt) * 1000
        t.x = u.p.x
        t.y = u.p.y
        t.data = u.p.data
        t.lastSeen = now
        t.missing = false
      }

      for (const u of unmatched) {
        if (claimed.has(u.i)) continue
        tracks.push({
          id: nextId++,
          x: u.p.x,
          y: u.p.y,
          vx: 0,
          vy: 0,
          data: u.p.data,
          firstSeen: now,
          lastSeen: now,
          missing: false,
        })
      }

      for (const t of tracks) {
        if (!usedTracks.has(t.id) && t.lastSeen !== now) t.missing = true
      }
      tracks = tracks.filter((t) => now - t.lastSeen <= maxAge)
      return tracks
    },

    /** Tracks currently being seen, ordered left to right on screen. */
    live(now) {
      return tracks
        .filter((t) => !t.missing || now - t.lastSeen < 150)
        .sort((a, b) => a.x - b.x)
    },

    reset() {
      tracks = []
    },
  }
}

/**
 * Locks tracks to player slots at the start of a round, ordered left to right.
 * Once locked, players keep their slot even if they move past each other.
 */
export function createRoster(count) {
  let ids = []
  return {
    lock(tracks) {
      ids = tracks.slice(0, count).map((t) => t.id)
      return ids.length
    },
    /** Returns an array of length `count`; empty slots are null. */
    resolve(tracks) {
      const byId = new Map(tracks.map((t) => [t.id, t]))
      const slots = new Array(count).fill(null)
      for (let i = 0; i < ids.length; i++) slots[i] = byId.get(ids[i]) || null
      // Any free slot can be adopted by an unclaimed track, so a player who
      // dropped out entirely can rejoin by putting their hand back up.
      const taken = new Set(ids)
      const spare = tracks.filter((t) => !taken.has(t.id))
      for (let i = 0; i < count && spare.length; i++) {
        if (!slots[i]) {
          const t = spare.shift()
          ids[i] = t.id
          slots[i] = t
        }
      }
      return slots
    },
    reset() {
      ids = []
    },
  }
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Home.jsx <<'HANDPLAY_EOF'
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
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Kinetic.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { HAND_CONNECTIONS, palmCenter, openness, isFist } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'

const ROUND_SECONDS = 75
const ORB_COLORS = ['#00E5B0', '#7C5CFF', '#00D4FF', '#FF4D8D', '#FFB000']
const GRAB_RADIUS = 95
const FIELD_RADIUS = 200

export default function Kinetic() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', score: 0, banked: 0, timeLeft: ROUND_SECONDS, hands: 0 })

  const g = useRef({
    phase: 'menu',
    tracker: createTracker({ maxDist: 0.26, maxAge: 400 }),
    orbs: [],
    dust: [],
    shocks: [],
    bursts: [],
    grips: new Map(),   // track id -> orb
    score: 0,
    banked: 0,
    timeLeft: ROUND_SECONDS,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    g.orbs = []
    g.dust = []
    g.shocks = []
    g.bursts = []
    g.grips.clear()
    g.score = 0
    g.banked = 0
    g.timeLeft = ROUND_SECONDS
    g.logged = false
    g.phase = 'playing'
  }

  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    function frame(now) {
      raf = requestAnimationFrame(frame)
      const { W, H } = logicalSize(canvas)
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.04) : 0
      g.lastTime = now

      if (!g.dust.length) {
        for (let i = 0; i < 90; i++) {
          g.dust.push({ x: Math.random(), y: Math.random(), z: 0.2 + Math.random() * 0.8 })
        }
      }

      const goal = { x: W * 0.87, y: H * 0.5, r: Math.min(H * 0.15, 110) }

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      const hands = tracks
        .filter((t) => t.data)
        .map((t) => ({
          id: t.id,
          x: t.x * W,
          y: t.y * H,
          vx: t.vx * W,
          vy: t.vy * H,
          lm: t.data,
          open: openness(t.data),
          closed: isFist(t.data),
        }))

      if (g.phase === 'playing') {
        g.timeLeft -= dt
        if (g.timeLeft <= 0) {
          g.timeLeft = 0
          g.phase = 'over'
          if (!g.logged) {
            g.logged = true
            addSession({ game: 'kinetic', score: g.score, detail: `${g.banked} orbs banked` })
          }
        }
        spawnOrbs(W, H)
        applyHands(hands, dt, W, H)
        stepOrbs(dt, W, H, goal, now)
      }

      render(ctx, W, H, dt, now, hands, goal)
      syncUi(hands.length)
    }

    function spawnOrbs(W, H) {
      const want = 5 + Math.min(4, Math.floor(g.banked / 3))
      while (g.orbs.length < want) {
        g.orbs.push({
          x: W * (0.08 + Math.random() * 0.28),
          y: H * (0.15 + Math.random() * 0.7),
          vx: 0, vy: 0,
          r: 16 + Math.random() * 12,
          color: ORB_COLORS[(Math.random() * ORB_COLORS.length) | 0],
          held: null,
          trail: [],
          spin: Math.random() * Math.PI * 2,
        })
      }
    }

    function applyHands(hands, dt, W, H) {
      const liveIds = new Set(hands.map((h) => h.id))
      for (const [id, orb] of [...g.grips]) {
        if (!liveIds.has(id)) { orb.held = null; g.grips.delete(id) }
      }

      for (const h of hands) {
        const gripped = g.grips.get(h.id)

        if (h.closed) {
          if (!gripped) {
            // Grab the nearest free orb inside reach.
            let best = null, bestD = GRAB_RADIUS
            for (const o of g.orbs) {
              if (o.held) continue
              const d = Math.hypot(o.x - h.x, o.y - h.y)
              if (d < bestD) { bestD = d; best = o }
            }
            if (best) {
              best.held = h.id
              g.grips.set(h.id, best)
              g.shocks.push({ x: h.x, y: h.y, r: 10, max: 70, life: 1, color: '#FFFFFF' })
            }
          } else {
            // Carry it, and remember the hand's motion for the throw.
            gripped.x += (h.x - gripped.x) * Math.min(1, dt * 18)
            gripped.y += (h.y - gripped.y) * Math.min(1, dt * 18)
            gripped.vx = h.vx
            gripped.vy = h.vy
          }
        } else {
          if (gripped) {
            // Let go: the orb keeps the hand's velocity.
            gripped.held = null
            gripped.vx = h.vx * 1.15
            gripped.vy = h.vy * 1.15
            g.grips.delete(h.id)
            g.shocks.push({ x: h.x, y: h.y, r: 12, max: 110, life: 1, color: '#00E5B0' })
          }
          // An open palm pushes everything nearby away.
          const power = h.open
          if (power > 0.25) {
            for (const o of g.orbs) {
              if (o.held) continue
              const dx = o.x - h.x
              const dy = o.y - h.y
              const d = Math.hypot(dx, dy)
              if (d < FIELD_RADIUS && d > 1) {
                const f = (1 - d / FIELD_RADIUS) * power * 2600
                o.vx += (dx / d) * f * dt
                o.vy += (dy / d) * f * dt
              }
            }
          }
        }
      }
    }

    function stepOrbs(dt, W, H, goal, now) {
      for (const o of g.orbs) {
        o.spin += dt * 1.5
        if (!o.held) {
          o.x += o.vx * dt
          o.y += o.vy * dt
          o.vx *= 0.985
          o.vy *= 0.985
          // The goal exerts a gentle pull once an orb drifts close.
          const dx = goal.x - o.x
          const dy = goal.y - o.y
          const d = Math.hypot(dx, dy)
          if (d < goal.r * 2.4 && d > 1) {
            const f = (1 - d / (goal.r * 2.4)) * 340
            o.vx += (dx / d) * f * dt
            o.vy += (dy / d) * f * dt
          }
          if (o.x < o.r) { o.x = o.r; o.vx = Math.abs(o.vx) * 0.55 }
          if (o.x > W - o.r) { o.x = W - o.r; o.vx = -Math.abs(o.vx) * 0.55 }
          if (o.y < o.r) { o.y = o.r; o.vy = Math.abs(o.vy) * 0.55 }
          if (o.y > H - o.r) { o.y = H - o.r; o.vy = -Math.abs(o.vy) * 0.55 }
        }
        o.trail.unshift({ x: o.x, y: o.y })
        if (o.trail.length > 14) o.trail.pop()
      }

      // Bank orbs that land in the ring.
      const scored = []
      for (const o of g.orbs) {
        if (o.held) continue
        if (Math.hypot(o.x - goal.x, o.y - goal.y) < goal.r * 0.72) {
          const speed = Math.hypot(o.vx, o.vy)
          const pts = 100 + Math.min(200, Math.round(speed / 6))
          g.score += pts
          g.banked += 1
          g.bursts.push({ x: o.x, y: o.y, color: o.color, life: 1, pts })
          g.shocks.push({ x: goal.x, y: goal.y, r: goal.r * 0.5, max: goal.r * 1.8, life: 1, color: o.color })
          for (let i = 0; i < 26; i++) {
            const a = Math.random() * Math.PI * 2
            const sp = 80 + Math.random() * 260
            g.bursts.push({ x: o.x, y: o.y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp, color: o.color, life: 1, particle: true })
          }
          scored.push(o)
        }
      }
      g.orbs = g.orbs.filter((o) => !scored.includes(o))

      for (const s of g.shocks) { s.r += (s.max - s.r) * dt * 6; s.life -= dt * 1.6 }
      g.shocks = g.shocks.filter((s) => s.life > 0)
      for (const b of g.bursts) {
        if (b.particle) { b.x += b.vx * dt; b.y += b.vy * dt; b.vx *= 0.94; b.vy *= 0.94 }
        b.life -= dt * (b.particle ? 1.3 : 0.9)
      }
      g.bursts = g.bursts.filter((b) => b.life > 0)
    }

    /* ------------------------------ rendering ------------------------------ */

    function render(ctx, W, H, dt, now, hands, goal) {
      const bg = ctx.createRadialGradient(W * 0.3, H * 0.4, 40, W * 0.3, H * 0.4, Math.max(W, H))
      bg.addColorStop(0, '#121033')
      bg.addColorStop(0.55, '#0A0820')
      bg.addColorStop(1, '#04030C')
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, W, H)

      for (const d of g.dust) {
        d.x += 0.006 * d.z * dt
        if (d.x > 1) d.x -= 1
        ctx.globalAlpha = 0.1 + d.z * 0.35
        ctx.fillStyle = '#9FB4FF'
        ctx.fillRect(d.x * W, d.y * H, 1.5 * d.z, 1.5 * d.z)
      }
      ctx.globalAlpha = 1

      drawGoal(ctx, goal, now)

      for (const s of g.shocks) {
        ctx.save()
        ctx.globalAlpha = Math.max(0, s.life) * 0.6
        ctx.strokeStyle = s.color
        ctx.lineWidth = 3
        ctx.beginPath()
        ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2)
        ctx.stroke()
        ctx.restore()
      }

      for (const o of g.orbs) drawOrb(ctx, o, now)
      for (const h of hands) drawHand(ctx, h, W, H, now)

      ctx.save()
      for (const b of g.bursts) {
        ctx.globalAlpha = Math.max(0, b.life)
        if (b.particle) {
          ctx.fillStyle = b.color
          ctx.beginPath()
          ctx.arc(b.x, b.y, 3, 0, Math.PI * 2)
          ctx.fill()
        } else {
          ctx.fillStyle = '#FFFFFF'
          ctx.font = '700 26px "Space Grotesk", system-ui, sans-serif'
          ctx.textAlign = 'center'
          ctx.fillText('+' + b.pts, b.x, b.y - (1 - b.life) * 70)
        }
      }
      ctx.restore()

      if (g.phase === 'playing') drawHud(ctx, W, H)
    }

    function drawGoal(ctx, goal, now) {
      ctx.save()
      const pull = ctx.createRadialGradient(goal.x, goal.y, 4, goal.x, goal.y, goal.r * 2)
      pull.addColorStop(0, 'rgba(0,229,176,0.30)')
      pull.addColorStop(0.5, 'rgba(0,229,176,0.08)')
      pull.addColorStop(1, 'rgba(0,229,176,0)')
      ctx.fillStyle = pull
      ctx.beginPath()
      ctx.arc(goal.x, goal.y, goal.r * 2, 0, Math.PI * 2)
      ctx.fill()

      ctx.translate(goal.x, goal.y)
      ctx.rotate(now * 0.0006)
      ctx.strokeStyle = '#00E5B0'
      ctx.shadowColor = '#00E5B0'
      ctx.shadowBlur = 26
      for (let ring = 0; ring < 3; ring++) {
        ctx.globalAlpha = 0.85 - ring * 0.22
        ctx.lineWidth = 3 - ring * 0.6
        ctx.setLineDash([26 - ring * 6, 16])
        ctx.beginPath()
        ctx.arc(0, 0, goal.r * (1 - ring * 0.17), 0, Math.PI * 2)
        ctx.stroke()
      }
      ctx.setLineDash([])
      ctx.restore()
    }

    function drawOrb(ctx, o, now) {
      ctx.save()
      for (let i = o.trail.length - 1; i > 0; i--) {
        const t = o.trail[i]
        ctx.globalAlpha = (1 - i / o.trail.length) * 0.25
        ctx.fillStyle = o.color
        ctx.beginPath()
        ctx.arc(t.x, t.y, o.r * (1 - i / o.trail.length) * 0.7, 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.globalAlpha = 1
      const glow = ctx.createRadialGradient(o.x, o.y, 1, o.x, o.y, o.r * 2.6)
      glow.addColorStop(0, '#FFFFFF')
      glow.addColorStop(0.22, o.color)
      glow.addColorStop(1, 'rgba(0,0,0,0)')
      ctx.fillStyle = glow
      ctx.beginPath()
      ctx.arc(o.x, o.y, o.r * 2.6, 0, Math.PI * 2)
      ctx.fill()

      if (o.held) {
        ctx.strokeStyle = '#FFFFFF'
        ctx.globalAlpha = 0.7
        ctx.lineWidth = 2
        ctx.setLineDash([6, 6])
        ctx.beginPath()
        ctx.arc(o.x, o.y, o.r * 1.9, o.spin, o.spin + Math.PI * 1.5)
        ctx.stroke()
        ctx.setLineDash([])
      }
      ctx.restore()
    }

    function drawHand(ctx, h, W, H, now) {
      const lm = h.lm
      const pt = (k) => ({
        x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
        y: lm[k].y * H,
      })
      const col = h.closed ? '#FFB000' : '#7C5CFF'

      // Force field when the palm is open
      if (!h.closed && h.open > 0.25) {
        ctx.save()
        const rr = FIELD_RADIUS * (0.5 + h.open * 0.5)
        const f = ctx.createRadialGradient(h.x, h.y, rr * 0.2, h.x, h.y, rr)
        f.addColorStop(0, `rgba(124,92,255,${0.05 + h.open * 0.12})`)
        f.addColorStop(1, 'rgba(124,92,255,0)')
        ctx.fillStyle = f
        ctx.beginPath()
        ctx.arc(h.x, h.y, rr, 0, Math.PI * 2)
        ctx.fill()
        ctx.strokeStyle = `rgba(160,130,255,${0.15 + h.open * 0.3})`
        ctx.lineWidth = 1.5
        for (let i = 0; i < 3; i++) {
          const p = ((now * 0.0006 + i / 3) % 1)
          ctx.globalAlpha = (1 - p) * (0.3 + h.open * 0.5)
          ctx.beginPath()
          ctx.arc(h.x, h.y, rr * p, 0, Math.PI * 2)
          ctx.stroke()
        }
        ctx.restore()
      }

      ctx.save()
      ctx.strokeStyle = col
      ctx.lineWidth = 3
      ctx.shadowColor = col
      ctx.shadowBlur = 16
      ctx.globalAlpha = 0.9
      for (const [a, b] of HAND_CONNECTIONS) {
        const u = pt(a), v = pt(b)
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawHud(ctx, W, H) {
      ctx.save()
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 38px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(g.score), 24, 50)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`${g.banked} banked`, 24, 70)

      const t = Math.ceil(g.timeLeft)
      ctx.textAlign = 'right'
      ctx.font = '600 38px "Space Grotesk", system-ui, sans-serif'
      ctx.fillStyle = t <= 10 ? '#FF4D8D' : '#EAEAF2'
      ctx.fillText(t + 's', W - 24, 50)
      ctx.restore()
    }

    let lastKey = ''
    function syncUi(handCount) {
      const next = {
        phase: g.phase,
        score: g.score,
        banked: g.banked,
        timeLeft: Math.ceil(g.timeLeft),
        hands: handCount,
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

      {status === 'error' && (
        <Overlay><h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p></Overlay>
      )}
      {loading && (
        <Overlay><div className="calibrate mb-5" />
          <p className="text-muted">{status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}</p></Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-mint mb-2">Move things without touching them</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-5 text-center">Kinetic</h1>
          <div className="grid gap-3 mb-7 max-w-md w-full text-sm">
            <Row icon="✋" title="Open palm" body="A force field pushes every orb away from you. Spread your fingers wider for more power." />
            <Row icon="✊" title="Close your fist" body="Snatch the nearest orb out of the air. It follows your hand." />
            <Row icon="👐" title="Open again" body="Release. The orb flies off with whatever speed your hand was moving." />
          </div>
          <p className="text-white/70 mb-6 text-center max-w-md">
            Land orbs in the ring on the right. The faster they're travelling when they arrive, the
            more they're worth. Up to four hands at once, so bring a friend.
          </p>
          <button onClick={start} className="btn-primary">Enter the arena</button>
        </Overlay>
      )}

      {ui.phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Time</p>
          <div className="font-display text-6xl font-700 text-mint mb-2">{ui.score}</div>
          <p className="text-muted mb-7">{ui.banked} orbs banked</p>
          <button onClick={start} className="btn-primary">Go again</button>
        </Overlay>
      )}
    </div>
  )
}

function Row({ icon, title, body }) {
  return (
    <div className="flex gap-3 rounded-xl bg-white/5 px-4 py-3">
      <span className="text-xl leading-none pt-0.5" aria-hidden="true">{icon}</span>
      <span>
        <span className="block font-medium">{title}</span>
        <span className="block text-muted text-xs mt-0.5">{body}</span>
      </span>
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Rocket.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { palmCenter } from '../lib/gestures.js'
import { createTracker, createRoster } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, roundRect } from '../lib/canvas.js'

const COLORS = ['#FFB000', '#00D4FF', '#FF4D8D', '#B6FF3C']
const NAMES = ['Player 1', 'Player 2', 'Player 3', 'Player 4']
const TEAM_COLORS = ['#FFB000', '#00D4FF']

export default function Rocket() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({ phase: 'menu', claimed: 0, standing: [], winner: '' })
  const cfgRef = useRef({ count: 2, teams: false })

  const g = useRef({
    phase: 'menu',
    tracker: createTracker({ maxDist: 0.28, maxAge: 600 }),
    roster: null,
    ships: [],
    walls: [],
    sparks: [],
    stars: [],
    scroll: 0,
    speed: 260,
    dist: 0,
    spawnAt: 0,
    readyAt: 0,
    lastTime: 0,
    shake: 0,
    logged: false,
  }).current

  function begin(count, teams) {
    cfgRef.current = { count, teams }
    g.tracker.reset()
    g.roster = createRoster(count)
    g.phase = 'claim'
    g.readyAt = 0
    g.logged = false
    setUi({ phase: 'claim', claimed: 0, standing: [], winner: '' })
  }

  function launch() {
    const { count, teams } = cfgRef.current
    g.ships = Array.from({ length: count }, (_, i) => ({
      i,
      y: 0.5,
      vy: 0,
      alive: true,
      dist: 0,
      team: teams ? i % 2 : i,
      color: teams ? TEAM_COLORS[i % 2] : COLORS[i],
      trail: [],
    }))
    g.walls = []
    g.sparks = []
    g.scroll = 0
    g.speed = 260
    g.dist = 0
    g.spawnAt = 0
    g.phase = 'flying'
  }

  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')

    if (!g.stars.length) {
      for (let i = 0; i < 130; i++) {
        g.stars.push({ x: Math.random(), y: Math.random(), z: 0.3 + Math.random() * 0.7 })
      }
    }

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
      const tracks = g.tracker.live(now)

      if (g.phase === 'claim') runClaim(now, tracks)
      else if (g.phase === 'flying') runFlight(dt, now, tracks, H)

      draw(ctx, W, H, dt, now, tracks)
    }

    function runClaim(now, tracks) {
      const need = cfgRef.current.count
      const have = Math.min(tracks.length, need)
      if (have >= need) {
        if (!g.readyAt) g.readyAt = now
        else if (now - g.readyAt > 1500) {
          g.roster.lock(tracks)
          g.readyAt = 0
          launch()
        }
      } else {
        g.readyAt = 0
      }
      setUiIfChanged({ phase: 'claim', claimed: have, standing: [], winner: '' })
    }

    function runFlight(dt, now, tracks, H) {
      const slots = g.roster.resolve(tracks)
      g.speed += dt * 9
      g.dist += g.speed * dt
      g.scroll += g.speed * dt

      for (const s of g.ships) {
        if (!s.alive) continue
        s.dist = g.dist
        const t = slots[s.i]
        if (t) {
          // Hand height maps to lane height, eased so it glides rather than snaps.
          const target = Math.max(0.06, Math.min(0.94, (t.y - 0.15) / 0.7))
          s.y += (target - s.y) * Math.min(1, dt * 9)
        } else {
          s.y += (0.5 - s.y) * Math.min(1, dt * 1.5)
        }
        s.trail.unshift({ y: s.y })
        if (s.trail.length > 22) s.trail.pop()
      }

      // Spawn wall pairs with a gap that narrows as speed climbs.
      if (g.scroll > g.spawnAt) {
        g.spawnAt = g.scroll + 300 + Math.random() * 120
        const gap = Math.max(0.20, 0.42 - g.dist / 60000)
        const centre = 0.18 + Math.random() * 0.64
        g.walls.push({ x: 1.15, gapTop: centre - gap / 2, gapBottom: centre + gap / 2, hit: new Set() })
      }

      const norm = g.speed / 1200
      for (const w of g.walls) w.x -= norm * dt * 1.9

      for (const s of g.ships) {
        if (!s.alive) continue
        const sx = 0.18
        for (const w of g.walls) {
          if (Math.abs(w.x - sx) > 0.035) continue
          if (s.y < w.gapTop || s.y > w.gapBottom) {
            s.alive = false
            g.shake = 1
            burst(sx, s.y, s.color)
          }
        }
      }
      g.walls = g.walls.filter((w) => w.x > -0.15)

      for (const p of g.sparks) {
        p.x += p.vx * dt
        p.y += p.vy * dt
        p.life -= dt * 1.4
      }
      g.sparks = g.sparks.filter((p) => p.life > 0)

      const alive = g.ships.filter((s) => s.alive)
      const { teams } = cfgRef.current
      const aliveTeams = new Set(alive.map((s) => s.team))
      if ((teams && aliveTeams.size <= 1) || (!teams && alive.length <= 1)) {
        finish(alive, aliveTeams)
      }
    }

    function finish(alive, aliveTeams) {
      const { teams } = cfgRef.current
      g.phase = 'over'
      const km = (g.dist / 100).toFixed(0)
      let winner
      if (teams) {
        const t = [...aliveTeams][0]
        winner = t === undefined ? 'Nobody' : `Team ${t + 1}`
      } else {
        winner = alive.length ? NAMES[alive[0].i] : 'Nobody'
      }
      const standing = [...g.ships]
        .sort((a, b) => (b.alive ? 1 : 0) - (a.alive ? 1 : 0))
        .map((s) => ({ name: NAMES[s.i], color: s.color, alive: s.alive }))
      if (!g.logged) {
        g.logged = true
        addSession({ game: 'rocket', score: Number(km), detail: `${winner} · ${km}km` })
      }
      setUiIfChanged({ phase: 'over', claimed: 0, standing, winner })
    }

    function burst(x, y, color) {
      for (let i = 0; i < 30; i++) {
        const a = Math.random() * Math.PI * 2
        const sp = 0.1 + Math.random() * 0.5
        g.sparks.push({ x, y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp, life: 1, color })
      }
    }

    /* ------------------------------ rendering ------------------------------ */

    function draw(ctx, W, H, dt, now, tracks) {
      ctx.save()
      if (g.shake > 0) {
        g.shake = Math.max(0, g.shake - dt * 3)
        const m = g.shake * 12
        ctx.translate((Math.random() - 0.5) * m, (Math.random() - 0.5) * m)
      }

      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#05030F')
      sky.addColorStop(0.5, '#0E0A28')
      sky.addColorStop(1, '#1B0E33')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      // Parallax starfield
      for (const st of g.stars) {
        st.x -= (g.phase === 'flying' ? 0.00018 * g.speed : 0.02) * st.z * dt * 6
        if (st.x < 0) { st.x += 1; st.y = Math.random() }
        ctx.globalAlpha = 0.25 + st.z * 0.6
        ctx.fillStyle = '#CFE4FF'
        ctx.fillRect(st.x * W, st.y * H, 1.6 * st.z, 1.6 * st.z)
      }
      ctx.globalAlpha = 1

      if (g.phase === 'flying' || g.phase === 'over') {
        for (const w of g.walls) drawWall(ctx, W, H, w)
        for (const s of g.ships) drawShip(ctx, W, H, s, now)
        for (const p of g.sparks) {
          ctx.globalAlpha = Math.max(0, p.life)
          ctx.fillStyle = p.color
          ctx.beginPath()
          ctx.arc(p.x * W, p.y * H, 2.5, 0, Math.PI * 2)
          ctx.fill()
        }
        ctx.globalAlpha = 1
        drawHud(ctx, W)
      }

      if (g.phase === 'claim') drawClaim(ctx, W, H, tracks, now)
      ctx.restore()
    }

    function drawWall(ctx, W, H, w) {
      const x = w.x * W
      const bw = 26
      const grd = ctx.createLinearGradient(x, 0, x + bw, 0)
      grd.addColorStop(0, '#4B2A6B')
      grd.addColorStop(0.5, '#8B4BC7')
      grd.addColorStop(1, '#4B2A6B')
      ctx.fillStyle = grd
      ctx.shadowColor = '#B06BFF'
      ctx.shadowBlur = 22
      ctx.fillRect(x, 0, bw, w.gapTop * H)
      ctx.fillRect(x, w.gapBottom * H, bw, H - w.gapBottom * H)
      ctx.shadowBlur = 0
      ctx.fillStyle = 'rgba(220,170,255,0.85)'
      ctx.fillRect(x, w.gapTop * H - 4, bw, 4)
      ctx.fillRect(x, w.gapBottom * H, bw, 4)
    }

    function drawShip(ctx, W, H, s, now) {
      const x = 0.18 * W
      const y = s.y * H
      if (!s.alive) return

      // Exhaust trail
      ctx.save()
      for (let i = s.trail.length - 1; i >= 0; i--) {
        const t = s.trail[i]
        ctx.globalAlpha = (1 - i / s.trail.length) * 0.5
        ctx.fillStyle = s.color
        ctx.beginPath()
        ctx.arc(x - i * 5, t.y * H, Math.max(1, 7 - i * 0.3), 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.restore()

      ctx.save()
      ctx.translate(x, y)
      ctx.shadowColor = s.color
      ctx.shadowBlur = 20
      ctx.fillStyle = s.color
      ctx.beginPath()
      ctx.moveTo(20, 0)
      ctx.lineTo(-10, -10)
      ctx.lineTo(-5, 0)
      ctx.lineTo(-10, 10)
      ctx.closePath()
      ctx.fill()
      const flick = 8 + Math.sin(now * 0.05) * 4
      ctx.globalAlpha = 0.8
      ctx.fillStyle = '#FFD36E'
      ctx.beginPath()
      ctx.moveTo(-8, -4)
      ctx.lineTo(-8 - flick, 0)
      ctx.lineTo(-8, 4)
      ctx.closePath()
      ctx.fill()
      ctx.restore()
    }

    function drawHud(ctx, W) {
      ctx.save()
      ctx.font = '600 30px "Space Grotesk", system-ui, sans-serif'
      ctx.fillStyle = '#EAEAF2'
      ctx.fillText((g.dist / 100).toFixed(0) + 'km', 22, 44)
      let x = W - 22
      ctx.textAlign = 'right'
      ctx.font = '600 13px Inter, system-ui, sans-serif'
      for (let i = g.ships.length - 1; i >= 0; i--) {
        const s = g.ships[i]
        ctx.globalAlpha = s.alive ? 1 : 0.3
        ctx.fillStyle = s.color
        ctx.fillText(NAMES[s.i].replace('Player ', 'P'), x, 40)
        x -= 42
      }
      ctx.restore()
    }

    function drawClaim(ctx, W, H, tracks, now) {
      const need = cfgRef.current.count
      ctx.save()
      ctx.fillStyle = 'rgba(5,3,15,0.65)'
      ctx.fillRect(0, 0, W, H)
      ctx.textAlign = 'center'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText('Raise one hand each', W / 2, H * 0.34)
      ctx.font = '500 15px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.6)'
      ctx.fillText(
        `${Math.min(tracks.length, need)} of ${need} pilots ready — stand left to right`,
        W / 2, H * 0.34 + 30
      )

      const size = 54
      const total = need * (size + 16) - 16
      for (let i = 0; i < need; i++) {
        const x = W / 2 - total / 2 + i * (size + 16)
        const y = H * 0.46
        const on = i < tracks.length
        ctx.strokeStyle = on ? (cfgRef.current.teams ? TEAM_COLORS[i % 2] : COLORS[i]) : 'rgba(255,255,255,0.2)'
        ctx.lineWidth = on ? 3 : 1.5
        roundRect(ctx, x, y, size, size, 14)
        ctx.stroke()
        if (on) {
          ctx.fillStyle = cfgRef.current.teams ? TEAM_COLORS[i % 2] : COLORS[i]
          ctx.globalAlpha = 0.2
          ctx.fill()
          ctx.globalAlpha = 1
        }
      }

      if (g.readyAt) {
        const p = Math.min(1, (now - g.readyAt) / 1500)
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 4
        ctx.beginPath()
        ctx.arc(W / 2, H * 0.62, 28, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p)
        ctx.stroke()
      }
      ctx.restore()
    }

    let lastKey = ''
    function setUiIfChanged(next) {
      const key = JSON.stringify(next)
      if (key !== lastKey) {
        lastKey = key
        setUi(next)
      }
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

      {status === 'error' && (
        <Overlay><h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p></Overlay>
      )}
      {loading && (
        <Overlay><div className="calibrate mb-5" />
          <p className="text-muted">{status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}</p></Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-p2 mb-2">Fly with your palm. Last one flying wins.</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-6 text-center">Rocket Rush</h1>
          <p className="text-white/70 mb-7 max-w-md text-center">
            Raise your hand and move it up and down to fly. Thread the gaps in the gates — one
            clip and you're out. The walls get faster and the gaps get tighter.
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <button onClick={() => begin(2, false)} className="btn-primary">1 v 1</button>
            <button onClick={() => begin(3, false)} className="btn-ghost">3 players</button>
            <button onClick={() => begin(4, false)} className="btn-ghost">4 players</button>
            <button onClick={() => begin(4, true)} className="btn-ghost">2 v 2 teams</button>
          </div>
        </Overlay>
      )}

      {ui.phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Flight over</p>
          <div className="font-display text-4xl md:text-5xl font-700 mb-6 text-center">{ui.winner} wins</div>
          <ul className="w-full max-w-xs space-y-1.5 mb-7">
            {ui.standing.map((s, i) => (
              <li key={i} className="flex items-center justify-between rounded-lg bg-white/5 px-4 py-2 text-sm">
                <span style={{ color: s.color }}>{s.name}</span>
                <span className="text-muted">{s.alive ? 'survived' : 'wrecked'}</span>
              </li>
            ))}
          </ul>
          <div className="flex gap-3">
            <button onClick={() => begin(cfgRef.current.count, cfgRef.current.teams)} className="btn-primary">Fly again</button>
            <button onClick={() => { g.phase = 'menu'; setUi({ phase: 'menu', claimed: 0, standing: [], winner: '' }) }} className="btn-ghost">Change mode</button>
          </div>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Dance.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, POSE_CONNECTIONS, ROUTINES, scorePose, boneScore } from '../lib/poses.js'
import { createTracker, createRoster } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'

const COLORS = ['#00E5B0', '#FF4D8D', '#FFB000', '#00D4FF']
const NAMES = ['Player 1', 'Player 2', 'Player 3', 'Player 4']

const GRADES = [
  { min: 0.86, label: 'PERFECT', points: 100, color: '#00E5B0' },
  { min: 0.72, label: 'GREAT', points: 70, color: '#B6FF3C' },
  { min: 0.55, label: 'GOOD', points: 40, color: '#FFB000' },
  { min: 0, label: 'MISS', points: 0, color: '#FF4D8D' },
]
const gradeFor = (s) => GRADES.find((gr) => s >= gr.min)

export default function Dance() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'pose',
    numPoses: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({
    phase: 'menu', step: 0, total: 0, poseName: '', hint: '',
    players: [], claimed: 0, need: 0, countdown: 0,
  })

  const cfg = useRef({ count: 2, routine: 0 })
  const g = useRef({
    phase: 'menu',
    tracker: createTracker({ maxDist: 0.3, maxAge: 900 }),
    roster: null,
    players: [],
    step: -1,
    stepEndsAt: 0,
    readyAt: 0,
    countStart: 0,
    live: [],
    popups: [],
    beat: 0,
    lastTime: 0,
    logged: false,
  }).current

  function begin(count, routine) {
    cfg.current = { count, routine }
    g.tracker.reset()
    g.roster = createRoster(count)
    g.players = Array.from({ length: count }, (_, i) => ({
      i, score: 0, combo: 0, best: 0, grades: [],
    }))
    g.step = -1
    g.popups = []
    g.logged = false
    g.phase = 'claim'
    g.readyAt = 0
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

      const video = videoRef.current
      const aspect = video && video.videoHeight ? video.videoWidth / video.videoHeight : 16 / 9

      const res = status === 'ready' ? detect(now) : null
      const people = res && res.landmarks ? res.landmarks : []
      const points = people.map((lm) => {
        // Hips are the steadiest anchor for identifying a person.
        const hx = ((lm[23]?.x ?? 0.5) + (lm[24]?.x ?? 0.5)) / 2
        const hy = ((lm[23]?.y ?? 0.5) + (lm[24]?.y ?? 0.5)) / 2
        return { x: settings.mirror ? 1 - hx : hx, y: hy, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      const routine = ROUTINES[cfg.current.routine]
      const target = g.step >= 0 && g.step < routine.steps.length
        ? POSES[routine.steps[g.step]]
        : null

      // Score every rostered player against the current step.
      g.live = []
      if (g.roster) {
        const slots = g.roster.resolve(tracks)
        for (let i = 0; i < slots.length; i++) {
          const t = slots[i]
          if (!t || !t.data) { g.live.push(null); continue }
          const r = target ? scorePose(t.data, target, aspect) : null
          g.live.push({ lm: t.data, result: r, score: r ? r.score : 0 })
        }
      }

      if (g.phase === 'claim') runClaim(now, tracks)
      else if (g.phase === 'countdown') runCountdown(now)
      else if (g.phase === 'dancing') runDance(now, routine)

      g.beat = target ? (1 - (g.stepEndsAt - now) / routine.beatMs) : 0
      draw(ctx, W, H, dt, now, target, tracks)
      syncUi(routine, target, tracks)
    }

    function runClaim(now, tracks) {
      const need = cfg.current.count
      if (tracks.length >= need) {
        if (!g.readyAt) g.readyAt = now
        else if (now - g.readyAt > 1600) {
          g.roster.lock(tracks)
          g.phase = 'countdown'
          g.countStart = now
        }
      } else g.readyAt = 0
    }

    function runCountdown(now) {
      if (now - g.countStart > 3200) {
        g.phase = 'dancing'
        g.step = 0
        g.stepEndsAt = now + ROUTINES[cfg.current.routine].beatMs
      }
    }

    function runDance(now, routine) {
      if (now < g.stepEndsAt) return
      // Grade everyone on the shape they were holding as the beat landed.
      for (let i = 0; i < g.players.length; i++) {
        const p = g.players[i]
        const s = g.live[i] ? g.live[i].score : 0
        const gr = gradeFor(s)
        p.score += gr.points + (gr.points > 0 ? Math.min(p.combo, 10) * 5 : 0)
        p.combo = gr.points > 0 ? p.combo + 1 : 0
        p.best = Math.max(p.best, p.combo)
        p.grades.push(gr.label)
        g.popups.push({ i, label: gr.label, color: gr.color, life: 1 })
      }
      g.step += 1
      if (g.step >= routine.steps.length) {
        g.phase = 'over'
        if (!g.logged) {
          g.logged = true
          const best = [...g.players].sort((a, b) => b.score - a.score)[0]
          addSession({
            game: 'dance',
            score: best.score,
            detail: `${NAMES[best.i]} · ${routine.name}`,
          })
        }
      } else {
        g.stepEndsAt = now + routine.beatMs
      }
    }

    /* ------------------------------ rendering ------------------------------ */

    function draw(ctx, W, H, dt, now, target, tracks) {
      const bg = ctx.createLinearGradient(0, 0, W, H)
      bg.addColorStop(0, '#0B0620')
      bg.addColorStop(0.5, '#160B33')
      bg.addColorStop(1, '#0A0A18')
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, W, H)
      drawFloor(ctx, W, H, now)

      if (target) drawTarget(ctx, W, H, target, now)
      for (let i = 0; i < g.live.length; i++) {
        const l = g.live[i]
        if (l) drawPerson(ctx, W, H, l, COLORS[i])
      }
      if (g.phase === 'dancing') drawBeat(ctx, W, H)
      drawPopups(ctx, W, H, dt)
      if (g.phase === 'claim') drawClaim(ctx, W, H, tracks, now)
      if (g.phase === 'countdown') drawCountdown(ctx, W, H, now)
    }

    function drawFloor(ctx, W, H, now) {
      const hz = H * 0.66
      ctx.save()
      const pulse = 0.5 + Math.sin(now * 0.004) * 0.5
      for (let i = 0; i <= 18; i++) {
        const t = i / 18
        ctx.strokeStyle = `rgba(150,90,255,${0.08 + (i % 2 ? 0.06 : 0) * pulse})`
        ctx.lineWidth = 1
        ctx.beginPath()
        ctx.moveTo(t * W, H)
        ctx.lineTo(W * 0.5 + (t * W - W * 0.5) * 0.2, hz)
        ctx.stroke()
      }
      // Sweeping stage lights
      for (let i = 0; i < 3; i++) {
        const a = now * 0.0004 + (i * Math.PI * 2) / 3
        const x = W * 0.5 + Math.sin(a) * W * 0.42
        const grd = ctx.createLinearGradient(x, 0, W * 0.5, H)
        const c = ['0,229,176', '255,77,141', '0,212,255'][i]
        grd.addColorStop(0, `rgba(${c},0.16)`)
        grd.addColorStop(1, `rgba(${c},0)`)
        ctx.fillStyle = grd
        ctx.beginPath()
        ctx.moveTo(x, 0)
        ctx.lineTo(x - 90, H)
        ctx.lineTo(x + 90, H)
        ctx.closePath()
        ctx.fill()
      }
      ctx.restore()
    }

    function drawTarget(ctx, W, H, target, now) {
      const h = H * 0.5
      const box = { x: W * 0.5 - h / 2, y: H * 0.10, w: h, h }
      const pt = (i) => {
        const p = target.points[i]
        const x = settings.mirror ? 1 - p.x : p.x
        return { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      ctx.save()
      ctx.globalAlpha = 0.4 + (1 - g.beat) * 0.25
      ctx.strokeStyle = '#FFFFFF'
      ctx.lineWidth = 14
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.shadowColor = '#B06BFF'
      ctx.shadowBlur = 34
      for (const [a, b] of POSE_CONNECTIONS) {
        const u = pt(a), v = pt(b)
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      const head = pt(0)
      const gap = Math.hypot(pt(11).x - pt(12).x, pt(11).y - pt(12).y)
      ctx.beginPath()
      ctx.arc(head.x, head.y, Math.max(13, gap * 0.42), 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()
    }

    function drawPerson(ctx, W, H, l, color) {
      const lm = l.lm
      const pt = (i) => ({
        x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W,
        y: lm[i].y * H,
      })
      ctx.save()
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.lineWidth = 6
      for (const [a, b] of POSE_CONNECTIONS) {
        const va = lm[a], vb = lm[b]
        if (!va || !vb || (va.visibility ?? 1) < 0.4 || (vb.visibility ?? 1) < 0.4) continue
        const s = l.result ? boneScore(l.result.bones, a, b) : null
        const col = s == null ? color : scoreColor(s)
        const u = pt(a), v = pt(b)
        ctx.strokeStyle = col
        ctx.shadowColor = col
        ctx.shadowBlur = 12
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawBeat(ctx, W, H) {
      const p = Math.max(0, Math.min(1, g.beat))
      ctx.save()
      ctx.fillStyle = 'rgba(255,255,255,0.10)'
      ctx.fillRect(0, H - 6, W, 6)
      ctx.fillStyle = p > 0.8 ? '#FF4D8D' : '#00E5B0'
      ctx.fillRect(0, H - 6, W * p, 6)
      ctx.restore()
    }

    function drawPopups(ctx, W, H, dt) {
      for (const p of g.popups) p.life -= dt * 1.1
      g.popups = g.popups.filter((p) => p.life > 0)
      const n = Math.max(1, g.players.length)
      ctx.save()
      ctx.textAlign = 'center'
      for (const p of g.popups) {
        const x = (W / n) * (p.i + 0.5)
        ctx.globalAlpha = Math.min(1, p.life * 1.4)
        ctx.fillStyle = p.color
        ctx.font = '700 30px "Space Grotesk", system-ui, sans-serif'
        ctx.fillText(p.label, x, H * 0.5 - (1 - p.life) * 60)
      }
      ctx.restore()
    }

    function drawClaim(ctx, W, H, tracks, now) {
      const need = cfg.current.count
      ctx.save()
      ctx.fillStyle = 'rgba(8,5,20,0.7)'
      ctx.fillRect(0, 0, W, H)
      ctx.textAlign = 'center'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText('Step onto the floor', W / 2, H * 0.4)
      ctx.font = '500 15px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.6)'
      ctx.fillText(
        `${Math.min(tracks.length, need)} of ${need} dancers — stand side by side, full body in frame`,
        W / 2, H * 0.4 + 30
      )
      if (g.readyAt) {
        const p = Math.min(1, (now - g.readyAt) / 1600)
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 5
        ctx.beginPath()
        ctx.arc(W / 2, H * 0.55, 32, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawCountdown(ctx, W, H, now) {
      const left = 3200 - (now - g.countStart)
      const n = Math.ceil(left / 1000)
      const frac = (left % 1000) / 1000
      ctx.save()
      ctx.textAlign = 'center'
      ctx.globalAlpha = 0.35 + frac * 0.65
      ctx.fillStyle = '#FFFFFF'
      ctx.font = '700 140px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(Math.max(1, n)), W / 2, H * 0.56)
      ctx.restore()
    }

    let lastKey = ''
    function syncUi(routine, target, tracks) {
      const next = {
        phase: g.phase,
        step: Math.max(0, g.step),
        total: routine.steps.length,
        poseName: target ? target.name : '',
        hint: target ? target.hint : '',
        need: cfg.current.count,
        claimed: Math.min(tracks.length, cfg.current.count),
        countdown: 0,
        players: g.players.map((p) => ({
          name: NAMES[p.i], color: COLORS[p.i], score: p.score, combo: p.combo, best: p.best,
        })),
      }
      const key = JSON.stringify(next)
      if (key !== lastKey) { lastKey = key; setUi(next) }
    }

    raf = requestAnimationFrame(frame)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  const loading = status === 'loading-model' || status === 'starting-camera'
  const ranked = [...ui.players].sort((a, b) => b.score - a.score)

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase === 'dancing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-5">
            <div className="text-xs text-white/50">Move {ui.step + 1} of {ui.total}</div>
            <div className="font-display text-3xl font-700">{ui.poseName}</div>
            <div className="text-white/60 text-sm max-w-[15rem]">{ui.hint}</div>
          </div>
          <div className="pointer-events-none absolute right-6 top-5 flex flex-col gap-1.5 items-end">
            {ui.players.map((p, i) => (
              <div key={i} className="flex items-center gap-3 rounded-lg bg-ink/50 px-3 py-1.5 backdrop-blur">
                <span className="text-xs" style={{ color: p.color }}>{p.name}</span>
                <span className="font-display text-lg">{p.score}</span>
                {p.combo > 1 && <span className="text-xs text-mint">×{p.combo}</span>}
              </div>
            ))}
          </div>
        </>
      )}

      {status === 'error' && (
        <Overlay><h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p></Overlay>
      )}
      {loading && (
        <Overlay><div className="calibrate mb-5" />
          <p className="text-muted">{status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'}</p></Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-violet mb-2">Follow the dancer. Hit every beat.</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-5 text-center">Dance Floor</h1>
          <p className="text-white/70 mb-7 max-w-md text-center">
            A figure moves through a routine. Match each shape before the bar runs out — your limbs
            light up green as they line up. Chain hits for a combo multiplier.
          </p>
          <div className="w-full max-w-sm space-y-4">
            <Choice label="Routine" options={ROUTINES.map((r, i) => ({ v: i, l: `${r.name} · ${r.level}` }))}
              value={cfg.current.routine} onChange={(v) => { cfg.current = { ...cfg.current, routine: v }; setUi((u) => ({ ...u })) }} />
            <Choice label="Dancers" options={[1, 2, 3, 4].map((n) => ({ v: n, l: n === 1 ? 'Solo' : n === 2 ? '1 v 1' : `${n} players` }))}
              value={cfg.current.count} onChange={(v) => { cfg.current = { ...cfg.current, count: v }; setUi((u) => ({ ...u })) }} />
          </div>
          <button onClick={() => begin(cfg.current.count, cfg.current.routine)} className="btn-primary mt-7">
            Start the music
          </button>
          <p className="text-muted text-xs mt-4">Stand back so everyone's legs are in frame.</p>
        </Overlay>
      )}

      {ui.phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Routine complete</p>
          <div className="font-display text-4xl font-700 mb-6 text-center">
            {ranked.length > 1 ? `${ranked[0].name} wins` : 'Nice moves'}
          </div>
          <ul className="w-full max-w-sm space-y-1.5 mb-7">
            {ranked.map((p, i) => (
              <li key={i} className="flex items-center justify-between rounded-lg bg-white/5 px-4 py-2.5">
                <span className="flex items-center gap-3">
                  <span className="text-muted text-sm w-4">{i + 1}</span>
                  <span style={{ color: p.color }}>{p.name}</span>
                </span>
                <span className="flex items-center gap-4 text-sm">
                  <span className="text-muted">best ×{p.best}</span>
                  <span className="font-display text-xl text-fg">{p.score}</span>
                </span>
              </li>
            ))}
          </ul>
          <div className="flex gap-3">
            <button onClick={() => begin(cfg.current.count, cfg.current.routine)} className="btn-primary">Dance again</button>
            <button onClick={() => { g.phase = 'menu'; setUi((u) => ({ ...u, phase: 'menu' })) }} className="btn-ghost">Change routine</button>
          </div>
        </Overlay>
      )}
    </div>
  )
}

function Choice({ label, options, value, onChange }) {
  return (
    <div>
      <div className="text-xs text-muted mb-1.5">{label}</div>
      <div className="flex flex-wrap gap-2">
        {options.map((o) => (
          <button
            key={o.v}
            onClick={() => onChange(o.v)}
            className={
              'rounded-lg border px-3 py-1.5 text-sm transition-colors ' +
              (value === o.v ? 'border-mint text-mint bg-mint/10' : 'border-line text-muted hover:text-fg')
            }
          >
            {o.l}
          </button>
        ))}
      </div>
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Quickdraw.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { assignPlayers, HAND_CONNECTIONS, BELT_Y } from '../lib/gestures.js'
import { useCanvasSize, logicalSize, drawRevolver, drawMuzzleFlash } from '../lib/canvas.js'

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
            awardRound(1 - i, null, true)
            return
          }
        }
        if (!both) {
          setPhase('holster', { holsterSince: 0 })
          return
        }
        if (now >= g.steadyUntil) setPhase('draw', { drawAt: now })
        return
      }

      if (g.phase === 'draw') {
        for (let i = 0; i < 2; i++) {
          const p = players[i]
          if (p && p.firing) {
            g.flash[i] = 1
            g.shake = 1
            awardRound(i, Math.round(now - g.drawAt), false)
            return
          }
        }
        return
      }

      if (g.phase === 'round' && now >= g.roundEndsAt) {
        if (g.wins[0] >= WINS_NEEDED || g.wins[1] >= WINS_NEEDED) {
          setPhase('match')
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

      // Revolver, lifting as the player draws
      const target = p && p.gun ? 1 : 0
      g.lift[i] += (target - g.lift[i]) * Math.min(1, dt * 12)
      const facing = i === 0 ? 1 : -1
      drawRevolver(ctx, cx, H - 92, 1.5, g.lift[i], facing, !!(p && p.cocked))

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

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {/* Live call-outs sit above the canvas so text stays crisp */}
      {ui.phase !== 'menu' && !loading && status === 'ready' && (
        <div className="pointer-events-none absolute inset-x-0 top-[22%] flex flex-col items-center px-6 text-center">
          <div
            className={
              'font-display font-700 tracking-tight drop-shadow-[0_4px_24px_rgba(0,0,0,0.6)] ' +
              (ui.phase === 'draw'
                ? 'text-7xl md:text-8xl text-white animate-[pop_180ms_ease-out]'
                : 'text-3xl md:text-4xl text-white/90')
            }
          >
            {ui.message}
          </div>
          {ui.sub && <p className="mt-3 text-white/70 max-w-md">{ui.sub}</p>}
          {ui.phase === 'round' && ui.reaction != null && (
            <div className="mt-4 font-display text-5xl text-white">{ui.reaction}<span className="text-2xl text-white/60">ms</span></div>
          )}
        </div>
      )}

      {ui.phase === 'match' && (
        <div className="absolute inset-x-0 bottom-24 flex justify-center gap-3">
          <button onClick={() => start(vsCpuRef.current)} className="btn-primary pointer-events-auto">
            Rematch
          </button>
          <button
            onClick={toMenu}
            className="btn-ghost pointer-events-auto"
          >
            Change mode
          </button>
        </div>
      )}

      {status === 'error' && (
        <Overlay>
          <h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p>
        </Overlay>
      )}

      {loading && (
        <Overlay>
          <div className="calibrate mb-5" />
          <p className="text-muted">
            {status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}
          </p>
        </Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-p1 tracking-wide mb-2">Sundown. Two hands. One winner.</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-4 text-center">
            The Fastest in the Hood
          </h1>
          <ol className="text-white/75 text-sm space-y-2 mb-7 max-w-sm">
            <li><span className="text-p1 font-medium">1.</span> Stand one on each side of the camera.</li>
            <li><span className="text-p1 font-medium">2.</span> Drop your hand below the belt line and hold it.</li>
            <li><span className="text-p1 font-medium">3.</span> On <span className="text-white font-medium">DRAW!</span> snap your hand into a finger gun and raise it.</li>
            <li><span className="text-p1 font-medium">4.</span> Move early and you hand the round to your rival.</li>
          </ol>
          <div className="flex gap-3">
            <button onClick={() => start(false)} className="btn-primary">Two players</button>
            <button onClick={() => start(true)} className="btn-ghost">Duel the machine</button>
          </div>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Paint.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings } from '../lib/storage.js'
import { HAND_CONNECTIONS, isPointing, palmCenter, handSpan } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, roundRect } from '../lib/canvas.js'

const INKS = [
  '#00E5B0', '#7C5CFF', '#FF7A45', '#FFB000',
  '#00D4FF', '#FF4D8D', '#B6FF3C', '#FFFFFF',
]
const PAPERS = [
  { name: 'Ink', color: '#0A0A12' },
  { name: 'Slate', color: '#232838' },
  { name: 'Bone', color: '#EFE9DC' },
  { name: 'Blueprint', color: '#0E2A4A' },
]
const SIZES = [6, 14, 26]
const HOVER_MS = 600

export default function Paint() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 4,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const inkRef = useRef(null)          // offscreen canvas holding the artwork
  const [paper, setPaper] = useState(0)
  const [hands, setHands] = useState(0)

  const g = useRef({
    tracker: createTracker({ maxDist: 0.25, maxAge: 500 }),
    pens: new Map(),   // track id -> { color, size, last, hoverKey, hoverSince }
    buttons: [],
    paper: 0,
    clearFlash: 0,
    lastTime: 0,
  }).current

  function clearArt() {
    const ink = inkRef.current
    if (ink) ink.getContext('2d').clearRect(0, 0, ink.width, ink.height)
    g.clearFlash = 1
  }

  function download() {
    const src = inkRef.current
    if (!src) return
    const out = document.createElement('canvas')
    out.width = src.width
    out.height = src.height
    const c = out.getContext('2d')
    c.fillStyle = PAPERS[g.paper].color
    c.fillRect(0, 0, out.width, out.height)
    c.drawImage(src, 0, 0)
    const a = document.createElement('a')
    a.download = 'air-canvas.png'
    a.href = out.toDataURL('image/png')
    a.click()
  }

  useEffect(() => { g.paper = paper }, [paper, g])

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

      // The artwork lives on its own canvas so strokes persist between frames.
      if (!inkRef.current || inkRef.current.width !== Math.round(W) || inkRef.current.height !== Math.round(H)) {
        const prev = inkRef.current
        const next = document.createElement('canvas')
        next.width = Math.round(W)
        next.height = Math.round(H)
        if (prev) next.getContext('2d').drawImage(prev, 0, 0)
        inkRef.current = next
      }
      const ink = inkRef.current.getContext('2d')

      const res = status === 'ready' ? detect(now) : null
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now)

      layoutButtons(W, H)

      for (const t of tracks) {
        if (!t.data) continue
        let pen = g.pens.get(t.id)
        if (!pen) {
          pen = {
            color: INKS[(g.pens.size * 3) % INKS.length],
            size: SIZES[1],
            last: null,
            hoverKey: null,
            hoverSince: 0,
          }
          g.pens.set(t.id, pen)
        }
        const lm = t.data
        const tip = lm[8]
        const x = (settings.mirror ? 1 - tip.x : tip.x) * W
        const y = tip.y * H
        const drawing = isPointing(lm)

        const btn = hitButton(x, y)
        if (btn && !drawing) {
          if (pen.hoverKey !== btn.key) {
            pen.hoverKey = btn.key
            pen.hoverSince = now
          } else if (now - pen.hoverSince > HOVER_MS) {
            applyButton(btn, pen)
            pen.hoverSince = now + 100000 // one action per dwell
          }
          pen.last = null
        } else {
          pen.hoverKey = null
        }

        if (drawing && !btn) {
          // Stroke width tracks how close the hand is, so leaning in draws bolder.
          const scale = Math.max(0.6, Math.min(1.8, handSpan(lm) / 0.12))
          const w = pen.size * scale
          if (pen.last) {
            ink.strokeStyle = pen.color
            ink.lineWidth = w
            ink.lineCap = 'round'
            ink.lineJoin = 'round'
            ink.beginPath()
            ink.moveTo(pen.last.x, pen.last.y)
            ink.lineTo(x, y)
            ink.stroke()
          }
          pen.last = { x, y }
        } else if (!drawing) {
          pen.last = null
        }

        t.screen = { x, y, drawing, pen }
      }

      // Forget pens whose hand is long gone.
      const liveIds = new Set(tracks.map((t) => t.id))
      for (const id of [...g.pens.keys()]) if (!liveIds.has(id)) g.pens.delete(id)

      render(ctx, W, H, now, dt, tracks)
      if (tracks.length !== hands) setHands(tracks.length)
    }

    /* ------------------------------- UI strip ------------------------------ */

    function layoutButtons(W, H) {
      const b = []
      const sw = 34
      const gap = 8
      const totalInk = INKS.length * (sw + gap) - gap
      let x = W / 2 - totalInk / 2
      const y = H - 62
      for (const c of INKS) {
        b.push({ key: 'ink:' + c, kind: 'ink', color: c, x, y, w: sw, h: sw })
        x += sw + gap
      }
      let sx = 20
      for (const s of SIZES) {
        b.push({ key: 'size:' + s, kind: 'size', size: s, x: sx, y, w: sw, h: sw })
        sx += sw + gap
      }
      let px = W - 20 - (PAPERS.length * (sw + gap) - gap)
      for (let i = 0; i < PAPERS.length; i++) {
        b.push({ key: 'paper:' + i, kind: 'paper', index: i, x: px, y, w: sw, h: sw })
        px += sw + gap
      }
      b.push({ key: 'clear', kind: 'clear', x: W / 2 - 44, y: H - 108, w: 88, h: 32 })
      g.buttons = b
    }

    function hitButton(x, y) {
      for (const b of g.buttons) {
        if (x >= b.x - 6 && x <= b.x + b.w + 6 && y >= b.y - 6 && y <= b.y + b.h + 6) return b
      }
      return null
    }

    function applyButton(b, pen) {
      if (b.kind === 'ink') pen.color = b.color
      else if (b.kind === 'size') pen.size = b.size
      else if (b.kind === 'paper') setPaper(b.index)
      else if (b.kind === 'clear') clearArt()
    }

    /* ------------------------------ rendering ------------------------------ */

    function render(ctx, W, H, now, dt, tracks) {
      ctx.fillStyle = PAPERS[g.paper].color
      ctx.fillRect(0, 0, W, H)
      const light = PAPERS[g.paper].color === '#EFE9DC'

      ctx.drawImage(inkRef.current, 0, 0)

      if (g.clearFlash > 0) {
        g.clearFlash = Math.max(0, g.clearFlash - dt * 2)
        ctx.fillStyle = `rgba(255,255,255,${g.clearFlash * 0.25})`
        ctx.fillRect(0, 0, W, H)
      }

      // Faint skeletons so people can see the tracking working
      if (settings.showSkeleton) {
        for (const t of tracks) {
          if (!t.data) continue
          const lm = t.data
          const pt = (k) => ({
            x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
            y: lm[k].y * H,
          })
          ctx.save()
          ctx.globalAlpha = 0.22
          ctx.strokeStyle = light ? '#333' : '#fff'
          ctx.lineWidth = 2
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

      drawToolbar(ctx, W, H, light)

      // Cursors on top of everything
      for (const t of tracks) {
        if (!t.screen) continue
        const { x, y, drawing, pen } = t.screen
        ctx.save()
        ctx.strokeStyle = pen.color
        ctx.lineWidth = drawing ? 4 : 2
        ctx.shadowColor = pen.color
        ctx.shadowBlur = drawing ? 20 : 8
        ctx.beginPath()
        ctx.arc(x, y, drawing ? pen.size * 0.7 + 6 : 16, 0, Math.PI * 2)
        ctx.stroke()
        if (drawing) {
          ctx.fillStyle = pen.color
          ctx.beginPath()
          ctx.arc(x, y, 3, 0, Math.PI * 2)
          ctx.fill()
        }
        ctx.restore()

        // Dwell progress on a tool
        if (pen.hoverKey) {
          const b = g.buttons.find((v) => v.key === pen.hoverKey)
          const p = Math.min(1, (now - pen.hoverSince) / HOVER_MS)
          if (b && p < 1) {
            ctx.save()
            ctx.strokeStyle = pen.color
            ctx.lineWidth = 3
            ctx.beginPath()
            ctx.arc(b.x + b.w / 2, b.y + b.h / 2, b.w * 0.78, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p)
            ctx.stroke()
            ctx.restore()
          }
        }
      }
    }

    function drawToolbar(ctx, W, H, light) {
      const fg = light ? '#1A1A22' : '#EAEAF2'
      ctx.save()
      ctx.fillStyle = light ? 'rgba(255,255,255,0.55)' : 'rgba(10,10,18,0.55)'
      roundRect(ctx, 8, H - 122, W - 16, 114, 18)
      ctx.fill()

      for (const b of g.buttons) {
        if (b.kind === 'ink') {
          ctx.fillStyle = b.color
          ctx.beginPath()
          ctx.arc(b.x + b.w / 2, b.y + b.h / 2, b.w / 2 - 2, 0, Math.PI * 2)
          ctx.fill()
        } else if (b.kind === 'size') {
          ctx.fillStyle = fg
          ctx.beginPath()
          ctx.arc(b.x + b.w / 2, b.y + b.h / 2, b.size / 2.4, 0, Math.PI * 2)
          ctx.fill()
        } else if (b.kind === 'paper') {
          ctx.fillStyle = PAPERS[b.index].color
          roundRect(ctx, b.x, b.y, b.w, b.h, 8)
          ctx.fill()
          ctx.strokeStyle = g.paper === b.index ? '#00E5B0' : 'rgba(128,128,140,0.5)'
          ctx.lineWidth = g.paper === b.index ? 3 : 1
          ctx.stroke()
        } else if (b.kind === 'clear') {
          ctx.strokeStyle = '#FF7A45'
          ctx.lineWidth = 1.5
          roundRect(ctx, b.x, b.y, b.w, b.h, 10)
          ctx.stroke()
          ctx.fillStyle = '#FF7A45'
          ctx.font = '600 13px Inter, system-ui, sans-serif'
          ctx.textAlign = 'center'
          ctx.fillText('clear all', b.x + b.w / 2, b.y + 21)
          ctx.textAlign = 'left'
        }
      }

      ctx.fillStyle = light ? 'rgba(0,0,0,0.45)' : 'rgba(255,255,255,0.4)'
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillText('brush', 20, H - 70)
      ctx.textAlign = 'right'
      ctx.fillText('background', W - 20, H - 70)
      ctx.textAlign = 'left'
      ctx.restore()
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

      {status === 'ready' && (
        <div className="absolute left-5 top-5 flex items-center gap-3">
          <span className="rounded-full bg-ink/60 px-3 py-1.5 text-xs text-fg backdrop-blur">
            {hands === 0 ? 'no hands yet' : hands === 1 ? '1 hand drawing' : `${hands} hands drawing`}
          </span>
          <button onClick={download} className="rounded-full bg-ink/60 px-3 py-1.5 text-xs text-fg backdrop-blur hover:bg-ink/80">
            Save PNG
          </button>
        </div>
      )}

      {status === 'error' && (
        <Overlay>
          <h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p>
        </Overlay>
      )}
      {loading && (
        <Overlay>
          <div className="calibrate mb-5" />
          <p className="text-muted">
            {status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}
          </p>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/PoseMatch.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, POSE_CONNECTIONS, scorePose, boneScore } from '../lib/poses.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'

const ROUND_POSES = 6
const SECONDS_PER_POSE = 10
const LOCK_SCORE = 0.72   // how close you need to be
const LOCK_HOLD = 0.55    // seconds you must hold it

export default function PoseMatch() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'pose',
    numPoses: 1,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)

  const [ui, setUi] = useState({
    phase: 'menu',
    poseName: '',
    hint: '',
    match: 0,
    index: 0,
    score: 0,
    timeLeft: SECONDS_PER_POSE,
    locked: false,
    visible: true,
    results: [],
  })

  const g = useRef({
    phase: 'menu',
    order: [],
    index: 0,
    score: 0,
    results: [],
    timeLeft: SECONDS_PER_POSE,
    holdFor: 0,
    match: 0,
    smooth: 0,
    lockedAt: 0,
    celebrate: 0,
    bones: {},
    visible: true,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    const order = [...POSES.keys()].sort(() => Math.random() - 0.5).slice(0, ROUND_POSES)
    Object.assign(g, {
      phase: 'playing',
      order,
      index: 0,
      score: 0,
      results: [],
      timeLeft: SECONDS_PER_POSE,
      holdFor: 0,
      match: 0,
      smooth: 0,
      celebrate: 0,
      logged: false,
    })
    setUi((u) => ({ ...u, phase: 'playing', results: [] }))
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

      const video = videoRef.current
      const aspect = video && video.videoHeight ? video.videoWidth / video.videoHeight : 16 / 9

      const res = status === 'ready' ? detect(now) : null
      const person = res && res.landmarks && res.landmarks.length ? res.landmarks[0] : null

      const target = g.phase === 'playing' ? POSES[g.order[g.index]] : null

      if (person && target) {
        const r = scorePose(person, target, aspect)
        g.bones = r.bones
        g.visible = r.enoughVisible
        g.match = r.enoughVisible ? r.score : 0
      } else {
        g.bones = {}
        g.match = 0
        g.visible = !!person
      }
      // Smooth the meter so it reads steadily instead of twitching.
      g.smooth += (g.match - g.smooth) * Math.min(1, dt * 8)

      if (g.phase === 'playing') advance(dt)

      drawBackdrop(ctx, W, H, now)
      if (target) drawTarget(ctx, W, H, target, now)
      if (person) drawPlayer(ctx, W, H, person)
      if (g.phase === 'playing') drawHud(ctx, W, H, dt)
      syncUi(target)
    }

    function advance(dt) {
      g.timeLeft -= dt
      if (g.match >= LOCK_SCORE) {
        g.holdFor += dt
        if (g.holdFor >= LOCK_HOLD) return finishPose(true)
      } else {
        g.holdFor = Math.max(0, g.holdFor - dt * 1.5)
      }
      if (g.timeLeft <= 0) finishPose(false)
    }

    function finishPose(locked) {
      const timeBonus = locked ? Math.round(Math.max(0, g.timeLeft) * 12) : 0
      const quality = Math.round(g.match * 100)
      const gained = locked ? 100 + timeBonus : Math.round(quality * 0.5)
      g.score += gained
      g.results.push({
        name: POSES[g.order[g.index]].name,
        quality,
        locked,
        points: gained,
      })
      g.celebrate = locked ? 1 : 0
      g.index += 1
      g.holdFor = 0
      g.timeLeft = SECONDS_PER_POSE
      if (g.index >= g.order.length) {
        g.phase = 'over'
        if (!g.logged) {
          g.logged = true
          const hits = g.results.filter((r) => r.locked).length
          addSession({
            game: 'posematch',
            score: g.score,
            detail: `${hits}/${g.results.length} poses nailed`,
          })
        }
      }
    }

    /* ------------------------------ rendering ------------------------------ */

    function drawBackdrop(ctx, W, H, now) {
      const bg = ctx.createLinearGradient(0, 0, W, H)
      bg.addColorStop(0, '#0B0A1C')
      bg.addColorStop(0.55, '#141033')
      bg.addColorStop(1, '#0A0A12')
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, W, H)

      // Slow sweeping spotlight
      const sweep = (Math.sin(now * 0.00035) * 0.5 + 0.5) * W
      const beam = ctx.createRadialGradient(sweep, H * 0.1, 20, sweep, H * 0.1, H * 0.95)
      beam.addColorStop(0, 'rgba(124,92,255,0.20)')
      beam.addColorStop(1, 'rgba(124,92,255,0)')
      ctx.fillStyle = beam
      ctx.fillRect(0, 0, W, H)

      // Floor grid for depth
      ctx.save()
      ctx.strokeStyle = 'rgba(124,92,255,0.16)'
      ctx.lineWidth = 1
      const hz = H * 0.68
      for (let i = 0; i <= 16; i++) {
        const t = i / 16
        const x = t * W
        ctx.beginPath()
        ctx.moveTo(x, H)
        ctx.lineTo(W * 0.5 + (x - W * 0.5) * 0.18, hz)
        ctx.stroke()
      }
      for (let i = 1; i <= 9; i++) {
        const t = i / 9
        const y = hz + (H - hz) * t * t
        ctx.globalAlpha = 0.5
        ctx.beginPath()
        ctx.moveTo(0, y)
        ctx.lineTo(W, y)
        ctx.stroke()
      }
      ctx.restore()
    }

    // Maps authored pose space into a centred box that keeps proportions.
    function targetBox(W, H) {
      const h = H * 0.62
      const w = h
      return { x: W * 0.5 - w / 2, y: H * 0.14, w, h }
    }

    function drawTarget(ctx, W, H, target, now) {
      const box = targetBox(W, H)
      const pt = (i) => {
        const p = target.points[i]
        const x = settings.mirror ? 1 - p.x : p.x
        return { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      const pulse = 0.55 + Math.sin(now * 0.003) * 0.12

      ctx.save()
      ctx.globalAlpha = pulse
      ctx.strokeStyle = '#7C5CFF'
      ctx.lineWidth = 16
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.shadowColor = '#7C5CFF'
      ctx.shadowBlur = 30
      for (const [a, b] of POSE_CONNECTIONS) {
        const u = pt(a), v = pt(b)
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      const head = pt(0)
      const shoulderGap = Math.hypot(pt(11).x - pt(12).x, pt(11).y - pt(12).y)
      ctx.beginPath()
      ctx.arc(head.x, head.y, Math.max(14, shoulderGap * 0.42), 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()
    }

    function drawPlayer(ctx, W, H, lm) {
      const pt = (i) => ({
        x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W,
        y: lm[i].y * H,
      })
      ctx.save()
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.lineWidth = 7
      for (const [a, b] of POSE_CONNECTIONS) {
        const va = lm[a], vb = lm[b]
        if (!va || !vb || (va.visibility ?? 1) < 0.4 || (vb.visibility ?? 1) < 0.4) continue
        const s = boneScore(g.bones, a, b)
        const col = s == null ? '#8A8AA0' : scoreColor(s)
        const u = pt(a), v = pt(b)
        ctx.strokeStyle = col
        ctx.shadowColor = col
        ctx.shadowBlur = 12
        ctx.beginPath()
        ctx.moveTo(u.x, u.y)
        ctx.lineTo(v.x, v.y)
        ctx.stroke()
      }
      ctx.shadowBlur = 0
      ctx.fillStyle = '#FFFFFF'
      for (const i of [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]) {
        if (!lm[i] || (lm[i].visibility ?? 1) < 0.4) continue
        const q = pt(i)
        ctx.beginPath()
        ctx.arc(q.x, q.y, 4, 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.restore()
    }

    function drawHud(ctx, W, H, dt) {
      const pct = Math.round(g.smooth * 100)
      const col = scoreColor(g.smooth)

      // Match ring
      const r = 46
      const cx = W - 78
      const cy = 82
      ctx.save()
      ctx.lineWidth = 10
      ctx.strokeStyle = 'rgba(255,255,255,0.10)'
      ctx.beginPath()
      ctx.arc(cx, cy, r, 0, Math.PI * 2)
      ctx.stroke()
      ctx.strokeStyle = col
      ctx.shadowColor = col
      ctx.shadowBlur = 18
      ctx.lineCap = 'round'
      ctx.beginPath()
      ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * g.smooth)
      ctx.stroke()
      ctx.shadowBlur = 0
      ctx.fillStyle = '#fff'
      ctx.textAlign = 'center'
      ctx.font = '600 26px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(pct + '%', cx, cy + 6)
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillStyle = 'rgba(255,255,255,0.55)'
      ctx.fillText('match', cx, cy + 24)
      ctx.restore()

      // Hold-to-lock arc under the ring
      if (g.holdFor > 0) {
        ctx.save()
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 4
        ctx.lineCap = 'round'
        ctx.beginPath()
        ctx.arc(cx, cy, r + 12, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(1, g.holdFor / LOCK_HOLD))
        ctx.stroke()
        ctx.restore()
      }

      // Time bar
      const barW = W * 0.5
      const bx = W * 0.25
      const frac = Math.max(0, g.timeLeft / SECONDS_PER_POSE)
      ctx.save()
      ctx.fillStyle = 'rgba(255,255,255,0.10)'
      ctx.fillRect(bx, H - 26, barW, 6)
      ctx.fillStyle = frac < 0.25 ? '#FF7A45' : '#7C5CFF'
      ctx.fillRect(bx, H - 26, barW * frac, 6)
      ctx.restore()

      // Lock-in burst
      if (g.celebrate > 0) {
        g.celebrate = Math.max(0, g.celebrate - dt * 1.6)
        ctx.save()
        ctx.globalAlpha = g.celebrate
        ctx.strokeStyle = '#00E5B0'
        ctx.lineWidth = 6
        ctx.beginPath()
        ctx.arc(W / 2, H / 2, (1 - g.celebrate) * H * 0.8, 0, Math.PI * 2)
        ctx.stroke()
        ctx.restore()
      }
    }

    let lastKey = ''
    function syncUi(target) {
      const next = {
        phase: g.phase,
        poseName: target ? target.name : '',
        hint: target ? target.hint : '',
        match: Math.round(g.smooth * 100),
        index: g.index,
        score: g.score,
        timeLeft: Math.ceil(Math.max(0, g.timeLeft)),
        locked: g.holdFor > 0,
        visible: g.visible,
        results: g.results,
      }
      const key = [next.phase, next.poseName, next.index, next.score, next.timeLeft, next.visible].join('~')
      if (key !== lastKey) {
        lastKey = key
        setUi(next)
      }
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

      {ui.phase === 'playing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-6">
            <div className="text-xs text-white/50">
              Pose {Math.min(ui.index + 1, ROUND_POSES)} of {ROUND_POSES}
            </div>
            <div className="font-display text-3xl font-700">{ui.poseName}</div>
            <div className="text-white/65 text-sm mt-1 max-w-[16rem]">{ui.hint}</div>
            <div className="mt-4 font-display text-2xl text-mint">{ui.score}</div>
          </div>
          {!ui.visible && (
            <div className="pointer-events-none absolute inset-x-0 bottom-16 text-center">
              <span className="rounded-full bg-ember/20 px-4 py-2 text-ember text-sm">
                Step back so your whole body is in frame
              </span>
            </div>
          )}
        </>
      )}

      {status === 'error' && (
        <Overlay>
          <h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p>
        </Overlay>
      )}

      {loading && (
        <Overlay>
          <div className="calibrate mb-5" />
          <p className="text-muted">
            {status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'}
          </p>
        </Overlay>
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Overlay>
          <p className="text-violet tracking-wide mb-2">Match the shape. Hold it. Bank it.</p>
          <h1 className="font-display text-4xl md:text-6xl font-700 mb-4 text-center">Copy That</h1>
          <p className="text-white/70 mb-7 max-w-md text-center">
            A glowing figure strikes a pose. Copy it with your own body — your limbs turn green as
            they line up. Hold the shape for half a second to bank the points before the timer runs
            out. {ROUND_POSES} poses per round.
          </p>
          <button onClick={start} className="btn-primary">Start round</button>
          <p className="text-muted text-xs mt-5">Stand back about 2 metres so your legs are in frame.</p>
        </Overlay>
      )}

      {ui.phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Round complete</p>
          <div className="font-display text-6xl font-700 text-mint mb-5">{ui.score}</div>
          <ul className="w-full max-w-sm space-y-1.5 mb-7">
            {ui.results.map((r, i) => (
              <li key={i} className="flex items-center justify-between rounded-lg bg-white/5 px-4 py-2 text-sm">
                <span className={r.locked ? 'text-fg' : 'text-muted'}>{r.name}</span>
                <span className="flex items-center gap-3">
                  <span style={{ color: scoreColor(r.quality / 100) }}>{r.quality}%</span>
                  <span className="text-muted w-10 text-right">+{r.points}</span>
                </span>
              </li>
            ))}
          </ul>
          <button onClick={start} className="btn-primary">Play again</button>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/70 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Orbs.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'

// MediaPipe hand skeleton connections (pairs of landmark indices).
const CONNECTIONS = [
  [0, 1], [1, 2], [2, 3], [3, 4],
  [0, 5], [5, 6], [6, 7], [7, 8],
  [5, 9], [9, 10], [10, 11], [11, 12],
  [9, 13], [13, 14], [14, 15], [15, 16],
  [13, 17], [17, 18], [18, 19], [19, 20],
  [0, 17],
]

const ROUND_SECONDS = 60
const PINCH_THRESHOLD = 0.06

export default function Orbs() {
  const settingsRef = useRef(loadSettings())
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: settingsRef.current.numHands,
    sensitivity: settingsRef.current.sensitivity,
  })

  const canvasRef = useRef(null)
  const [phase, setPhase] = useState('menu') // menu | playing | over
  const [result, setResult] = useState({ score: 0, maxCombo: 0 })

  // Mutable game state kept in a ref so the animation loop never re-renders React.
  const game = useRef({
    orbs: [],
    score: 0,
    combo: 0,
    maxCombo: 0,
    timeLeft: ROUND_SECONDS,
    lastSpawn: 0,
    lastTime: 0,
    wasPinching: false,
    running: false,
  })

  // Resize canvas to its container (crisp on high-DPI screens).
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const parent = canvas.parentElement
    const ro = new ResizeObserver(() => {
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const w = parent.clientWidth
      const h = parent.clientHeight
      canvas.width = Math.floor(w * dpr)
      canvas.height = Math.floor(h * dpr)
      canvas.style.width = w + 'px'
      canvas.style.height = h + 'px'
      const ctx = canvas.getContext('2d')
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
    })
    ro.observe(parent)
    return () => ro.disconnect()
  }, [])

  // Main render + game loop.
  useEffect(() => {
    let raf
    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')

    function loop(now) {
      raf = requestAnimationFrame(loop)
      const g = game.current
      const s = settingsRef.current
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      const W = canvas.width / dpr
      const H = canvas.height / dpr
      const dt = g.lastTime ? Math.min((now - g.lastTime) / 1000, 0.05) : 0
      g.lastTime = now

      drawBackground(ctx, W, H, now)

      // Detect hands and gather cursor + pinch.
      const res = status === 'ready' ? detect(now) : null
      let cursor = null
      let pinching = false

      if (res && res.landmarks && res.landmarks.length) {
        for (const hand of res.landmarks) {
          drawHand(ctx, hand, W, H, s.mirror, s.showSkeleton)
        }
        const hand = res.landmarks[0]
        const tip = hand[8]
        const thumb = hand[4]
        const cx = (s.mirror ? 1 - tip.x : tip.x) * W
        const cy = tip.y * H
        cursor = { x: cx, y: cy }
        const dx = tip.x - thumb.x
        const dy = tip.y - thumb.y
        pinching = Math.hypot(dx, dy) < PINCH_THRESHOLD
        drawCursor(ctx, cx, cy, pinching, now)
      }

      if (g.running) {
        // Timer
        g.timeLeft -= dt
        if (g.timeLeft <= 0) {
          g.timeLeft = 0
          endRound()
        }

        // Spawn orbs, faster as the round goes on.
        const elapsed = ROUND_SECONDS - g.timeLeft
        const spawnEvery = Math.max(0.35, 1.1 - elapsed * 0.012)
        if (now - g.lastSpawn > spawnEvery * 1000) {
          g.lastSpawn = now
          spawnOrb(g, W, elapsed)
        }

        // Move + collide orbs
        for (const orb of g.orbs) {
          orb.y += orb.vy * dt
          orb.x += orb.vx * dt
          if (orb.x < orb.r || orb.x > W - orb.r) orb.vx *= -1
          if (cursor) {
            const d = Math.hypot(orb.x - cursor.x, orb.y - cursor.y)
            if (d < orb.r + 26) {
              orb.alive = false
              g.combo += 1
              g.maxCombo = Math.max(g.maxCombo, g.combo)
              g.score += 10 + Math.min(g.combo, 20) * 2
            }
          }
          if (orb.y > H + orb.r) {
            orb.alive = false
            g.combo = 0
          }
        }

        // Pinch blast: clear orbs near the cursor on the pinch's rising edge.
        if (cursor && pinching && !g.wasPinching) {
          for (const orb of g.orbs) {
            if (Math.hypot(orb.x - cursor.x, orb.y - cursor.y) < 150) {
              orb.alive = false
              g.score += 25
              g.combo += 1
              g.maxCombo = Math.max(g.maxCombo, g.combo)
            }
          }
          spawnBlast(g, cursor.x, cursor.y)
        }
        g.wasPinching = pinching

        g.orbs = g.orbs.filter((o) => o.alive)
        drawOrbs(ctx, g.orbs, now)
        drawParticles(ctx, g, dt)
        drawHud(ctx, W, g)
      } else {
        drawParticles(ctx, g, dt)
      }
    }

    raf = requestAnimationFrame(loop)
    return () => cancelAnimationFrame(raf)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status])

  function startRound() {
    const g = game.current
    g.orbs = []
    g.particles = []
    g.score = 0
    g.combo = 0
    g.maxCombo = 0
    g.timeLeft = ROUND_SECONDS
    g.lastSpawn = 0
    g.wasPinching = false
    g.running = true
    setPhase('playing')
  }

  function endRound() {
    const g = game.current
    g.running = false
    const r = { score: g.score, maxCombo: g.maxCombo }
    setResult(r)
    addSession({ game: 'orbs', score: r.score, maxCombo: r.maxCombo, duration: ROUND_SECONDS, detail: `best combo x${r.maxCombo}` })
    setPhase('over')
  }

  const loading = status === 'loading-model' || status === 'starting-camera'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {/* Overlays */}
      {status === 'error' && (
        <Overlay>
          <h2 className="font-display text-2xl mb-2">Camera not available</h2>
          <p className="text-muted max-w-sm text-center">{error}</p>
        </Overlay>
      )}

      {loading && (
        <Overlay>
          <div className="calibrate mb-5" />
          <p className="text-muted">
            {status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'}
          </p>
        </Overlay>
      )}

      {status === 'ready' && phase === 'menu' && (
        <Overlay>
          <h1 className="font-display text-4xl md:text-5xl font-700 mb-3 text-center">
            Catch the orbs <span className="text-mint">with your hand</span>
          </h1>
          <p className="text-muted mb-6 max-w-md text-center">
            Move your hand to sweep up orbs. Pinch your thumb and finger together to blast a cluster.
            You have {ROUND_SECONDS} seconds.
          </p>
          <button onClick={startRound} className="btn-primary">Start round</button>
        </Overlay>
      )}

      {phase === 'over' && (
        <Overlay>
          <p className="text-muted mb-1">Round over</p>
          <div className="font-display text-6xl font-700 text-mint mb-1">{result.score}</div>
          <p className="text-muted mb-6">Best combo ×{result.maxCombo}</p>
          <button onClick={startRound} className="btn-primary">Play again</button>
        </Overlay>
      )}
    </div>
  )
}

function Overlay({ children }) {
  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-ink/55 backdrop-blur-sm px-6">
      {children}
    </div>
  )
}

/* ---------- drawing helpers ---------- */

function drawBackground(ctx, W, H, now) {
  ctx.clearRect(0, 0, W, H)
  ctx.fillStyle = '#0A0A12'
  ctx.fillRect(0, 0, W, H)
  ctx.save()
  ctx.globalAlpha = 0.08
  ctx.strokeStyle = '#7C5CFF'
  ctx.lineWidth = 1
  const step = 48
  const drift = (now * 0.01) % step
  for (let x = -step + drift; x < W; x += step) {
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke()
  }
  for (let y = -step + drift; y < H; y += step) {
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke()
  }
  ctx.restore()
}

function drawHand(ctx, hand, W, H, mirror, showSkeleton) {
  const pt = (i) => ({ x: (mirror ? 1 - hand[i].x : hand[i].x) * W, y: hand[i].y * H })
  if (showSkeleton) {
    ctx.save()
    ctx.strokeStyle = 'rgba(124,92,255,0.7)'
    ctx.lineWidth = 3
    ctx.shadowColor = '#7C5CFF'
    ctx.shadowBlur = 12
    for (const [a, b] of CONNECTIONS) {
      const p = pt(a), q = pt(b)
      ctx.beginPath(); ctx.moveTo(p.x, p.y); ctx.lineTo(q.x, q.y); ctx.stroke()
    }
    ctx.fillStyle = '#EAEAF2'
    for (let i = 0; i < 21; i++) {
      const p = pt(i)
      ctx.beginPath(); ctx.arc(p.x, p.y, 3, 0, Math.PI * 2); ctx.fill()
    }
    ctx.restore()
  }
}

function drawCursor(ctx, x, y, pinching, now) {
  const pulse = 1 + Math.sin(now * 0.008) * 0.15
  ctx.save()
  ctx.shadowColor = '#00E5B0'
  ctx.shadowBlur = 24
  ctx.strokeStyle = '#00E5B0'
  ctx.lineWidth = pinching ? 5 : 3
  ctx.beginPath(); ctx.arc(x, y, (pinching ? 16 : 22) * pulse, 0, Math.PI * 2); ctx.stroke()
  ctx.fillStyle = '#00E5B0'
  ctx.beginPath(); ctx.arc(x, y, 4, 0, Math.PI * 2); ctx.fill()
  ctx.restore()
}

function drawOrbs(ctx, orbs, now) {
  for (const orb of orbs) {
    ctx.save()
    ctx.shadowColor = orb.color
    ctx.shadowBlur = 18
    const grd = ctx.createRadialGradient(orb.x, orb.y, 1, orb.x, orb.y, orb.r)
    grd.addColorStop(0, '#ffffff')
    grd.addColorStop(0.4, orb.color)
    grd.addColorStop(1, 'rgba(0,0,0,0)')
    ctx.fillStyle = grd
    ctx.beginPath(); ctx.arc(orb.x, orb.y, orb.r, 0, Math.PI * 2); ctx.fill()
    ctx.restore()
  }
}

function drawHud(ctx, W, g) {
  ctx.save()
  ctx.fillStyle = '#EAEAF2'
  ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
  ctx.textBaseline = 'top'
  ctx.fillText(String(g.score), 24, 20)
  ctx.font = '500 14px Inter, system-ui, sans-serif'
  ctx.fillStyle = '#8A8AA0'
  ctx.fillText('SCORE', 24, 58)

  const t = Math.ceil(g.timeLeft)
  ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
  ctx.fillStyle = t <= 10 ? '#FF7A45' : '#EAEAF2'
  ctx.textAlign = 'right'
  ctx.fillText(t + 's', W - 24, 20)
  ctx.textAlign = 'left'

  if (g.combo > 1) {
    ctx.fillStyle = '#00E5B0'
    ctx.font = '600 20px "Space Grotesk", system-ui, sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText('combo ×' + g.combo, W / 2, 22)
    ctx.textAlign = 'left'
  }
  ctx.restore()
}

/* ---------- game object helpers ---------- */

const ORB_COLORS = ['#00E5B0', '#7C5CFF', '#FF7A45', '#4DA3FF']

function spawnOrb(g, W, elapsed) {
  const r = 16 + Math.random() * 16
  g.orbs.push({
    x: r + Math.random() * (W - r * 2),
    y: -r,
    r,
    vy: 90 + Math.random() * 70 + elapsed * 3,
    vx: (Math.random() - 0.5) * 60,
    color: ORB_COLORS[(Math.random() * ORB_COLORS.length) | 0],
    alive: true,
  })
}

function spawnBlast(g, x, y) {
  if (!g.particles) g.particles = []
  for (let i = 0; i < 22; i++) {
    const a = Math.random() * Math.PI * 2
    const sp = 120 + Math.random() * 220
    g.particles.push({ x, y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp, life: 1, color: '#00E5B0' })
  }
}

function drawParticles(ctx, g, dt) {
  if (!g.particles) return
  for (const p of g.particles) {
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.life -= dt * 1.8
  }
  g.particles = g.particles.filter((p) => p.life > 0)
  ctx.save()
  for (const p of g.particles) {
    ctx.globalAlpha = Math.max(p.life, 0)
    ctx.fillStyle = p.color
    ctx.beginPath(); ctx.arc(p.x, p.y, 3, 0, Math.PI * 2); ctx.fill()
  }
  ctx.restore()
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Admin.jsx <<'HANDPLAY_EOF'
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
HANDPLAY_EOF
mkdir -p test
cat > test/logic.test.mjs <<'HANDPLAY_EOF'
import { isGunGesture, fingerStates, readHand, assignPlayers, BELT_Y } from '../src/lib/gestures.js'
import { POSES, scorePose, BONES } from '../src/lib/poses.js'

let failed = 0
const check = (name, cond, extra = '') => {
  if (cond) console.log(`  PASS  ${name}`)
  else { console.log(`  FAIL  ${name} ${extra}`); failed++ }
}

/* ---------- synthetic hand builder ---------- */
// Builds a hand at (wx, wy) where each finger is either extended or curled.
function makeHand({ wx = 0.5, wy = 0.8, index, middle, ring, pinky, thumb }) {
  const lm = new Array(21)
  lm[0] = { x: wx, y: wy }
  // Thumb chain, splayed sideways from the index knuckle.
  const tReach = thumb ? 0.10 : 0.03
  lm[1] = { x: wx - 0.03, y: wy - 0.02 }
  lm[2] = { x: wx - 0.05, y: wy - 0.05 }
  lm[3] = { x: wx - 0.05 - tReach * 0.5, y: wy - 0.06 }
  lm[4] = { x: wx - 0.05 - tReach, y: wy - 0.07 }

  const fingers = [
    { mcp: 5, ext: index, dx: -0.03 },
    { mcp: 9, ext: middle, dx: 0.0 },
    { mcp: 13, ext: ring, dx: 0.03 },
    { mcp: 17, ext: pinky, dx: 0.06 },
  ]
  for (const f of fingers) {
    const bx = wx + f.dx
    const mcpY = wy - 0.10
    lm[f.mcp] = { x: bx, y: mcpY }
    if (f.ext) {
      // Straight finger: each joint further from the wrist.
      lm[f.mcp + 1] = { x: bx, y: mcpY - 0.06 }
      lm[f.mcp + 2] = { x: bx, y: mcpY - 0.11 }
      lm[f.mcp + 3] = { x: bx, y: mcpY - 0.16 }
    } else {
      // Curled finger: the tip folds back toward the palm.
      lm[f.mcp + 1] = { x: bx, y: mcpY - 0.05 }
      lm[f.mcp + 2] = { x: bx, y: mcpY - 0.03 }
      lm[f.mcp + 3] = { x: bx, y: mcpY + 0.01 }
    }
  }
  return lm
}

console.log('\nHand gestures')
const gun = makeHand({ index: true, middle: false, ring: false, pinky: false, thumb: true })
const openHand = makeHand({ index: true, middle: true, ring: true, pinky: true, thumb: true })
const fist = makeHand({ index: false, middle: false, ring: false, pinky: false, thumb: false })
const peace = makeHand({ index: true, middle: true, ring: false, pinky: false, thumb: false })

check('finger gun is recognised', isGunGesture(gun))
check('open hand is not a gun', !isGunGesture(openHand))
check('fist is not a gun', !isGunGesture(fist))
check('peace sign is not a gun', !isGunGesture(peace))
check('thumb up detected on gun', fingerStates(gun).thumb)
check('thumb tucked detected on fist', !fingerStates(fist).thumb)

console.log('\nHolster / draw states')
const low = makeHand({ wy: 0.75, index: true, middle: false, ring: false, pinky: false, thumb: true })
const high = makeHand({ wy: 0.30, index: true, middle: false, ring: false, pinky: false, thumb: true })
check('hand below belt reads holstered', readHand(low, true).holstered)
check('hand below belt is not firing', !readHand(low, true).firing)
check('raised gun reads as firing', readHand(high, true).firing)
check('raised hand flagged as raised', readHand(high, true).raised)
check('BELT_Y sits below mid-frame', BELT_Y > 0.5)

console.log('\nPlayer assignment (mirrored)')
// Mirrored: screen-left comes from a large raw x.
const leftScreen = makeHand({ wx: 0.85, wy: 0.75, index: true, middle: false, ring: false, pinky: false, thumb: true })
const rightScreen = makeHand({ wx: 0.15, wy: 0.75, index: true, middle: false, ring: false, pinky: false, thumb: true })
const slots = assignPlayers([leftScreen, rightScreen], true)
check('two hands fill both player slots', !!slots[0] && !!slots[1])
check('player 1 is on screen-left', slots[0] && slots[0].sx < 0.5, slots[0] && `sx=${slots[0].sx.toFixed(2)}`)
check('player 2 is on screen-right', slots[1] && slots[1].sx > 0.5, slots[1] && `sx=${slots[1].sx.toFixed(2)}`)
const oneSide = assignPlayers([leftScreen], true)
check('single hand leaves the other slot empty', !!oneSide[0] && oneSide[1] === null)

console.log('\nPose scoring — a pose must match itself')
const ASPECT = 16 / 9
// Convert authored (isotropic) pose points into player-style normalised landmarks.
function asPlayer(target, jitter = 0) {
  const lm = []
  for (let i = 0; i < 33; i++) lm[i] = { x: 0.5, y: 0.5, visibility: 0 }
  for (const [k, p] of Object.entries(target.points)) {
    lm[+k] = {
      x: (p.x + (Math.random() - 0.5) * jitter) / ASPECT,
      y: p.y + (Math.random() - 0.5) * jitter,
      visibility: 1,
    }
  }
  return lm
}

for (const target of POSES) {
  const r = scorePose(asPlayer(target), target, ASPECT)
  check(`${target.name} scores itself at 100%`, r.score > 0.995, `got ${(r.score * 100).toFixed(1)}%`)
}

console.log('\nPose scoring — different poses must NOT match')
let worstCross = 0
for (const a of POSES) {
  for (const b of POSES) {
    if (a === b) continue
    const r = scorePose(asPlayer(a), b, ASPECT)
    worstCross = Math.max(worstCross, r.score)
  }
}
check('no mismatched pair reaches the 0.72 lock threshold', worstCross < 0.72, `worst was ${(worstCross * 100).toFixed(1)}%`)

console.log('\nPose scoring — small wobble still counts as a match')
let minJitter = 1
for (const target of POSES) {
  for (let i = 0; i < 30; i++) {
    const r = scorePose(asPlayer(target, 0.03), target, ASPECT)
    minJitter = Math.min(minJitter, r.score)
  }
}
check('a sloppy-but-correct pose stays above the threshold', minJitter > 0.72, `worst was ${(minJitter * 100).toFixed(1)}%`)

console.log('\nPose scoring — upper body only')
const tpose = POSES.find((p) => p.name === "T-Pose")
const upper = asPlayer(tpose)
for (const i of [23, 24, 25, 26, 27, 28]) upper[i].visibility = 0.1
const upperResult = scorePose(upper, tpose, ASPECT)
check('legs out of frame still scores the arms', upperResult.score > 0.99)
check('legs out of frame is still playable', upperResult.enoughVisible)
const nobody = scorePose(asPlayer(tpose).map(() => ({ x: 0.5, y: 0.5, visibility: 0 })), tpose, ASPECT)
check('nobody visible is flagged unplayable', !nobody.enoughVisible)

console.log('\nAspect ratio handling')
const square = scorePose(
  (() => {
    const lm = []
    for (let i = 0; i < 33; i++) lm[i] = { x: 0.5, y: 0.5, visibility: 0 }
    for (const [k, p] of Object.entries(tpose.points)) lm[+k] = { x: p.x, y: p.y, visibility: 1 }
    return lm
  })(),
  tpose,
  1
)
check('a 1:1 camera also scores a perfect T-Pose', square.score > 0.995, `got ${(square.score * 100).toFixed(1)}%`)
check('every limb has a definition', BONES.length === 8)

/* ===================== added with the multiplayer games ===================== */
const { createTracker, createRoster } = await import('../src/lib/tracking.js')
const { isFist, isOpenPalm, isPointing, isPinching, openness, palmCenter, extendedCount } =
  await import('../src/lib/gestures.js')
const { ROUTINES, POSES: ALL_POSES } = await import('../src/lib/poses.js')

console.log('\nGrip gestures')
const flat = makeHand({ index: true, middle: true, ring: true, pinky: true, thumb: true })
const closed = makeHand({ index: false, middle: false, ring: false, pinky: false, thumb: false })
const point = makeHand({ index: true, middle: false, ring: false, pinky: false, thumb: false })
check('open palm detected', isOpenPalm(flat))
check('open palm is not a fist', !isFist(flat))
check('fist detected', isFist(closed))
check('fist is not an open palm', !isOpenPalm(closed))
check('pointing detected', isPointing(point))
check('open palm is not pointing', !isPointing(flat))
check('openness ranks open above closed', openness(flat) > openness(closed),
  `open=${openness(flat).toFixed(2)} closed=${openness(closed).toFixed(2)}`)
check('extended count is 4 when open', extendedCount(flat) === 4, `got ${extendedCount(flat)}`)
check('extended count is 0 when closed', extendedCount(closed) === 0, `got ${extendedCount(closed)}`)
const pc = palmCenter(flat)
check('palm centre lies inside the hand', pc.x > 0.4 && pc.x < 0.6 && pc.y > 0.6 && pc.y < 0.9)

console.log('\nIdentity tracking')
const tr = createTracker({ maxDist: 0.25, maxAge: 400 })
let t0 = 1000
tr.update([{ x: 0.2, y: 0.5 }, { x: 0.8, y: 0.5 }], t0)
const first = tr.live(t0)
check('two hands produce two tracks', first.length === 2)
const leftId = first[0].id
const rightId = first[1].id
check('ids are distinct', leftId !== rightId)

// Same hands, but MediaPipe returns them in the opposite order and slightly moved.
t0 += 33
tr.update([{ x: 0.78, y: 0.52 }, { x: 0.22, y: 0.48 }], t0)
const second = tr.live(t0)
check('ids survive a reordered detection list',
  second[0].id === leftId && second[1].id === rightId,
  `got ${second.map((t) => t.id).join(',')} expected ${leftId},${rightId}`)

// Hands cross over each other.
for (let i = 0; i < 12; i++) {
  t0 += 33
  tr.update([{ x: 0.22 + i * 0.05, y: 0.5 }, { x: 0.78 - i * 0.05, y: 0.5 }], t0)
}
const crossed = tr.live(t0)
check('ids survive hands crossing over', new Set(crossed.map((t) => t.id)).size === 2)

// A hand vanishes for a couple of frames then returns.
t0 += 33
tr.update([{ x: 0.8, y: 0.5 }], t0)
t0 += 100
const back = tr.update([{ x: 0.8, y: 0.5 }, { x: 0.2, y: 0.5 }], t0)
check('a brief dropout does not spawn a duplicate track', back.length === 2, `got ${back.length}`)

// A hand that leaves for good is dropped.
t0 += 900
tr.update([{ x: 0.8, y: 0.5 }], t0)
check('a hand gone past maxAge is forgotten', tr.update([{ x: 0.8, y: 0.5 }], t0 + 50).length === 1)

console.log('\nVelocity (used for throwing in Kinetic)')
const vt = createTracker({})
vt.update([{ x: 0.2, y: 0.5 }], 0)
const moved = vt.update([{ x: 0.3, y: 0.5 }], 100)
check('rightward motion yields positive vx', moved[0].vx > 0, `vx=${moved[0].vx.toFixed(2)}`)
check('velocity is scaled to units per second', Math.abs(moved[0].vx - 1) < 0.01, `vx=${moved[0].vx.toFixed(2)}`)

console.log('\nPlayer roster')
const rt = createTracker({})
rt.update([{ x: 0.15, y: 0.5 }, { x: 0.5, y: 0.5 }, { x: 0.85, y: 0.5 }], 0)
const rTracks = rt.live(0)
const roster = createRoster(3)
check('roster locks all three players', roster.lock(rTracks) === 3)
const lockedIds = rTracks.map((t) => t.id)
// Players shuffle positions; slots must not follow them.
const shuffled = [rTracks[2], rTracks[0], rTracks[1]]
const resolved = roster.resolve(shuffled)
check('slots stay with the same person after they move around',
  resolved.map((t) => t && t.id).join(',') === lockedIds.join(','),
  `got ${resolved.map((t) => t && t.id).join(',')}`)
const partial = roster.resolve([rTracks[0]])
check('a missing player leaves an empty slot, not a shifted one',
  partial[0] && partial[0].id === lockedIds[0] && !partial[2])

console.log('\nDance routines')
check('routines exist', ROUTINES.length >= 3)
for (const r of ROUTINES) {
  const ok = r.steps.every((i) => Number.isInteger(i) && i >= 0 && i < ALL_POSES.length)
  check(`"${r.name}" references only real poses`, ok)
  check(`"${r.name}" has a sane beat length`, r.beatMs >= 1000 && r.beatMs <= 4000)
}

console.log(failed === 0 ? '\nAll checks passed.\n' : `\n${failed} check(s) failed.\n`)
process.exit(failed === 0 ? 0 : 1)
HANDPLAY_EOF
echo "Installing dependencies..."
npm install --no-audit --no-fund
echo ""
echo "Running logic tests..."
node test/logic.test.mjs
echo ""
echo "Ready. Start it with:  npm run dev"
echo "Open the forwarded URL in a REAL browser tab and allow the camera."
