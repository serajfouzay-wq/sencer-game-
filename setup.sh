#!/usr/bin/env bash
set -e
echo "Creating HandPlay..."
mkdir -p src/lib src/pages src/components test public
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
| Shadow Dojo | Solo | Hands |
| The Rift | Solo | Full body |
| Arcane | Solo | Hands |
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

### Shadow Dojo

You are the camera. Fighters walk out of the dark toward you.

- **Punch toward the lens.** A fist thrown at the camera lands on whatever is in
  front of it. There is no depth sensor — the game reads how fast your hand
  grows on screen, which is why a committed jab registers and a hand waved
  sideways does not.
- **Both palms up to guard.** Blocks most of the damage, but you cannot punch
  while guarding.
- **Step sideways to dodge.** Move out of a fighter's line and the strike misses
  entirely. The whole room shifts with you.

A red ring means someone is about to swing. Brutes take more than one clean hit.
Waves keep coming until your health runs out.

### The Rift

Your whole body flies the ship down a tunnel.

- **Lean left or right to steer.** Line up with the hole in each wall.
- **Crouch to duck** under the amber bars — they span the full width, so leaning
  will not save you.
- **Move your head to look around.** The view is tied to your head position, so
  leaning in genuinely lets you peer further down the tunnel.

Three shields, and it only gets faster. Green shards are worth chasing.

### Arcane

Draw shapes in the air and they become spells.

- **Point your index finger** to draw. Your fingertip leaves a trail.
- **Lower or open your hand** to release the stroke and cast it.
- **A straight line is a Bolt** — hits the nearest wraith hard, in any direction.
- **A circle is a Ward** — absorbs the next strike aimed at you.
- **A zigzag is a Chain** — arcs through up to three wraiths at once.

The name of whatever you cast flashes on screen, so a misread is never a
mystery. If it says *fizzled*, the stroke was too small or too ambiguous — draw
bigger.

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

## Part 4b — Sound

Every sound in HandPlay is **generated in code** — there are no audio files to
download, nothing to license, and nothing to break on a venue's wifi. Each game
has its own music: a slow minor theme for the duel, driving arpeggios in space
for Rocket Rush and Kinetic, a 124bpm floor track for Dance, and something calm
under Air Canvas and Orb Catcher.

The **speaker icon in the top right** mutes everything.

> Browsers block audio until someone interacts with the page. The first click
> anywhere switches it on, so the sound arrives from the first menu button. If a
> screen is silent, click once and it will come in.

For an event: run the display's volume around 60-70%. The duel's gunshot is the
loudest thing in the app and it is the sound that pulls a crowd over.

## Part 4c — Tracking quality

Raw camera tracking shimmers by a pixel or two every frame even when a hand is
perfectly still, and that shimmer is what makes this kind of thing look cheap.
Every landmark now goes through an adaptive filter that smooths hard when you
are still and barely at all when you move fast, so the noise disappears without
adding the lag a simple average would.

Measured on the real numbers: **noise on a still hand is cut by about 11x, while
a full-width swipe still tracks within 5% of your true position.** The filter
also runs on every display frame rather than every camera frame, so motion is
interpolated up to 60fps even though most webcams deliver 30.

Two more things happen before a detection reaches a game:

- **Impossible detections are thrown away** — a hand collapsed to a few pixels,
  or landmarks off in the distance, are noise, and acting on them creates
  phantom inputs.
- **Each person keeps their own identity** between frames, so two players never
  swap smoothing histories and snap.

## Part 5 — The dashboard

At `/admin`. Built for someone non-technical to operate.

**Stats** — rounds played, high score, average, and the fastest draw ever
recorded. Filter by game using the buttons at the top.

The dashboard has three tabs:

- **Overview** — scores, filterable by game.
- **Camera setup** — everything below.
- **Live check** — a camera preview with tracking drawn on it and a plain
  verdict: whether it looks good, whether hands are too far away, or whether the
  frame rate is too low. **Run this on site before doors open.** It answers "will
  this work here" in about five seconds.

**Camera setup**
- *Mirror the camera* — on by default, so moving right moves right on screen.
- *Show the tracked skeleton* — turn off for a cleaner look on a big display.
- *Show the camera behind the game* — on by default. Players see themselves
  behind the artwork, which is how they know they are in shot. Turn it off only
  if the room behind them is distracting.
- *Glow effects* — the bloom pass. Turn it off to gain frame rate on an older
  machine.
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
- **Use the fullscreen button** in the top right of the app (or press F11).
- **Corner brackets turn pink** when nobody is detected — that is the fastest
  way for a player to realise they have stepped out of shot.
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

**A punch is not registering in Shadow Dojo.**
Throw it *at the camera*, not across your body — the game reads forward motion.
Commit to it; a slow reach will not trigger. You also cannot punch while
guarding, so drop one hand first.

**My spell keeps fizzling in Arcane.**
Draw bigger — a small stroke is rejected on purpose so stray finger movement
does not cast. Keep lines straight and close circles properly.

**Leaning does nothing in The Rift.**
Your whole body needs to be in frame. Watch the corner brackets: pink means you
are not being seen at all.

**Tracking is jumpy.**
Add light in front of the players first — backlight is almost always the cause.
Then lower the sensitivity slider a little. If you want it steadier still, raise
`minCutoff` or lower `beta` in `src/lib/filter.js`; be aware that trading too far
in that direction makes fast movements feel laggy, which players notice more
than jitter.

**The frame rate drops with four players.**
Turn off *Glow effects* in the dashboard, then *Show the camera behind the game*.
Those two are the most expensive things on screen.

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

**There is no sound.**
Click anywhere once — browsers block audio until the page is interacted with.
Then check the speaker icon in the top right, and the machine's own volume.

**The characters look like plain skeletons.**
Turn *Show the tracked skeleton* off in the dashboard if you want the character
without the tracking overlay on top of it.

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
    scene3d.js          perspective camera, corridors, depth sorting
    combat.js           punch/guard/dodge reads and NPC behaviour
    shapes.js           air-drawn shape recognition
    characters.js       character rig, the gunslinger, the ships
    audio.js            the synth: every sound effect and music track
    filter.js           jitter smoothing and detection sanity checks
    render.js           bloom, camera backdrop, vignette, frame guide
    storage.js          settings and scores saved in the browser
  components/
    ui.jsx              menus, buttons, results boards, gesture glyphs
  pages/
    Home.jsx            game picker
    Dojo.jsx            Shadow Dojo
    Rift.jsx            The Rift
    Arcane.jsx          Arcane
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
| Music tempo and key | `src/lib/audio.js` | `MOODS` |
| Overall volume | `src/lib/audio.js` | `master.gain.value` |
| Music vs effects balance | `src/lib/audio.js` | `musicGain`, `sfxGain` |
| Character colours and build | `src/lib/characters.js` | `drawCharacter` |
| How far the view swings with your head | `src/lib/scene3d.js` | `parallax` |
| Punch sensitivity | `src/lib/combat.js` | `growthThreshold` |
| Enemy health, speed and reach | `src/lib/combat.js` | `NPC_KINDS` |
| Spell recognition tolerance | `src/lib/shapes.js` | `recognizeShape` |
| Smoothing vs responsiveness | `src/lib/filter.js` | `minCutoff`, `beta` |
| Bloom strength | `src/lib/render.js` | `composite()` blur and alpha |
| Camera backdrop brightness | each game page | `drawCameraBackdrop` alpha |

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
  overflow-x: hidden;
}

@layer components {
  .btn-primary {
    @apply inline-flex items-center justify-center rounded-xl bg-mint px-6 py-3
           font-medium text-ink shadow-glow transition-transform;
  }
  .btn-primary:hover { transform: translateY(-1px); }
  .btn-primary:active { transform: scale(0.97); }
  .btn-primary:focus-visible { outline: 2px solid #EAEAF2; outline-offset: 2px; }

  .btn-ghost {
    @apply inline-flex items-center justify-center rounded-xl border border-line
           bg-white/5 px-6 py-3 font-medium text-fg transition-all;
  }
  .btn-ghost:hover { background: rgba(255,255,255,0.10); transform: translateY(-1px); }
  .btn-ghost:active { transform: scale(0.97); }
  .btn-ghost:focus-visible { outline: 2px solid #EAEAF2; outline-offset: 2px; }
}

/* ------------------------------- animations ------------------------------- */

@keyframes spin { to { transform: rotate(360deg); } }
.animate-spin { animation: spin 0.9s linear infinite; }

@keyframes pop {
  0%   { transform: scale(0.72); opacity: 0; }
  60%  { transform: scale(1.06); opacity: 1; }
  100% { transform: scale(1); opacity: 1; }
}
.animate-pop { animation: pop 320ms cubic-bezier(0.2, 0.9, 0.3, 1.2); }

@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
.animate-fadeIn { animation: fadeIn 260ms ease-out; }

@keyframes riseIn {
  from { opacity: 0; transform: translateY(14px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-riseIn { animation: riseIn 460ms cubic-bezier(0.2, 0.8, 0.2, 1); }

@keyframes pulseSoft {
  0%, 100% { opacity: 1; }
  50%      { opacity: 0.55; }
}
.animate-pulseSoft { animation: pulseSoft 2s ease-in-out infinite; }

@keyframes breathe {
  0%, 100% { transform: scale(1); }
  50%      { transform: scale(1.12); }
}
.animate-breathe { animation: breathe 1.9s ease-in-out infinite; }

@keyframes nudge {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(-4px); }
}
.animate-nudge { animation: nudge 1.4s ease-in-out infinite; }

@keyframes sway {
  0%, 100% { transform: rotate(-12deg); }
  50%      { transform: rotate(12deg); }
}
.animate-sway { animation: sway 1.5s ease-in-out infinite; }

@keyframes pingSlow {
  0%   { transform: scale(0.85); opacity: 0.8; }
  100% { transform: scale(1.5); opacity: 0; }
}
.animate-ping-slow { animation: pingSlow 1.8s cubic-bezier(0, 0, 0.2, 1) infinite; }

@keyframes shimmer {
  from { background-position: -200% 0; }
  to   { background-position: 200% 0; }
}
.shimmer {
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.14), transparent);
  background-size: 200% 100%;
  animation: shimmer 2.4s linear infinite;
}

@keyframes floaty {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(-8px); }
}
.animate-floaty { animation: floaty 4s ease-in-out infinite; }

.calibrate {
  width: 56px;
  height: 56px;
  border-radius: 9999px;
  border: 3px solid rgba(124, 92, 255, 0.25);
  border-top-color: #00E5B0;
  animation: spin 0.9s linear infinite;
}

/* Chrome hides the scrollbar on the nav strip without breaking scrolling. */
.no-bar::-webkit-scrollbar { display: none; }
.no-bar { scrollbar-width: none; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.001ms !important;
  }
}
HANDPLAY_EOF
mkdir -p src
cat > src/main.jsx <<'HANDPLAY_EOF'
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
  cameraFeed: true,   // show the player behind the game, Kinect style
  bloom: true,        // additive glow pass
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
import { createLandmarkSmoother, plausibleHand, plausiblePose } from './filter.js'

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
  const slotsRef = useRef([])
  const rawRef = useRef(null)

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
      slotsRef.current = []
      rawRef.current = null
    }
  }, [task, numHands, numPoses, sensitivity])

  /** Where a detection "is", for matching it to the same subject next frame. */
  function anchorOf(lm) {
    if (task === 'pose') {
      const a = lm[23]
      const b = lm[24]
      if (a && b) return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }
      return { x: lm[0]?.x ?? 0.5, y: lm[0]?.y ?? 0.5 }
    }
    return { x: lm[0].x, y: lm[0].y }
  }

  /**
   * Matches this frame's detections to the subjects we were already following,
   * so each one keeps its own smoothing history and its position in the output
   * array. Without this, MediaPipe's arbitrary ordering would swap two players'
   * smoothing filters and make both of them snap.
   */
  function reconcile(landmarks, tSec) {
    const slots = slotsRef.current
    // Keep the original index so the parallel arrays (handedness, world
    // landmarks) can be reordered to match the output.
    const valid = []
    landmarks.forEach((lm, i) => {
      if (task === 'pose' ? plausiblePose(lm) : plausibleHand(lm)) valid.push({ lm, i })
    })

    const pairs = []
    valid.forEach(({ lm }, di) => {
      const a = anchorOf(lm)
      slots.forEach((slot, si) => {
        const d = Math.hypot(slot.x - a.x, slot.y - a.y)
        if (d <= 0.3) pairs.push({ di, si, d })
      })
    })
    pairs.sort((a, b) => a.d - b.d)

    const usedSlot = new Set()
    const usedDet = new Set()
    for (const { di, si } of pairs) {
      if (usedSlot.has(si) || usedDet.has(di)) continue
      usedSlot.add(si)
      usedDet.add(di)
      const lm = valid[di]
      const a = anchorOf(lm)
      const slot = slots[si]
      slot.x = a.x
      slot.y = a.y
      slot.seen = tSec
      slot.landmarks = slot.smoother.apply(lm, tSec)
    }

    valid.forEach((lm, di) => {
      if (usedDet.has(di)) return
      const a = anchorOf(lm)
      const smoother = createLandmarkSmoother()
      slots.push({ x: a.x, y: a.y, seen: tSec, smoother, landmarks: smoother.apply(lm, tSec) })
    })

    // A subject that vanished for good stops occupying a slot.
    slotsRef.current = slots.filter((s) => tSec - s.seen < 0.4)
    return slotsRef.current.map((s) => s.landmarks)
  }

  /**
   * Runs detection for the current frame, then smooths it.
   *
   * The model only produces a new result when the camera delivers a new frame
   * (usually 30fps), but this runs every animation frame (usually 60). Feeding
   * the filter on every frame means motion is interpolated up to the display
   * rate as well as denoised, so tracking looks twice as smooth as the camera
   * actually is.
   */
  function detect(timeMs) {
    const lm = landmarkerRef.current
    const video = videoRef.current
    if (!lm || !video || video.readyState < 2 || !video.videoWidth) return lastResultRef.current

    const tSec = timeMs / 1000

    if (video.currentTime !== lastVideoTimeRef.current) {
      lastVideoTimeRef.current = video.currentTime
      const stamp = timeMs <= lastStampRef.current ? lastStampRef.current + 1 : timeMs
      lastStampRef.current = stamp
      try {
        rawRef.current = lm.detectForVideo(video, stamp)
      } catch (e) {
        // A dropped frame should never kill the game loop.
        console.warn('detect skipped', e)
      }
    }

    const raw = rawRef.current
    if (!raw || !raw.landmarks) return lastResultRef.current

    const slots = reconcile(raw.landmarks, tSec)
    // Reorder the parallel arrays too, or handedness would describe a different
    // hand than the one it sits alongside.
    const pick = (arr) =>
      Array.isArray(arr) ? slots.map((s) => arr[s.src]).filter((v) => v !== undefined) : arr

    lastResultRef.current = {
      ...raw,
      landmarks: slots.map((s) => s.landmarks),
      handedness: pick(raw.handedness),
      worldLandmarks: pick(raw.worldLandmarks),
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
mkdir -p src/lib
cat > src/lib/audio.js <<'HANDPLAY_EOF'
// Every sound here is synthesised at runtime. No audio files means nothing to
// download, nothing to license, and no broken links on a venue's flaky wifi.

let ctx = null
let master = null
let musicGain = null
let sfxGain = null
let muted = false
let unlocked = false

function ensure() {
  if (ctx) return ctx
  const AC = window.AudioContext || window.webkitAudioContext
  if (!AC) return null
  ctx = new AC()
  master = ctx.createGain()
  master.gain.value = 0.9
  master.connect(ctx.destination)
  musicGain = ctx.createGain()
  musicGain.gain.value = 0.30
  musicGain.connect(master)
  sfxGain = ctx.createGain()
  sfxGain.gain.value = 0.75
  sfxGain.connect(master)
  return ctx
}

/** Browsers only allow audio after a real user gesture. */
export function unlock() {
  const c = ensure()
  if (!c) return
  if (c.state === 'suspended') c.resume()
  unlocked = true
}

export function setMuted(v) {
  muted = v
  if (master) master.gain.setTargetAtTime(v ? 0 : 0.9, ctx.currentTime, 0.02)
}
export function isMuted() {
  return muted
}

const now = () => (ctx ? ctx.currentTime : 0)

/** A single shaped oscillator note. */
function tone({ freq = 440, to, type = 'sine', dur = 0.18, attack = 0.006, gain = 0.3, delay = 0, dest }) {
  const c = ensure()
  if (!c || !unlocked) return
  const t = now() + delay
  const osc = c.createOscillator()
  const g = c.createGain()
  osc.type = type
  osc.frequency.setValueAtTime(freq, t)
  if (to) osc.frequency.exponentialRampToValueAtTime(Math.max(20, to), t + dur)
  g.gain.setValueAtTime(0.0001, t)
  g.gain.exponentialRampToValueAtTime(gain, t + attack)
  g.gain.exponentialRampToValueAtTime(0.0001, t + dur)
  osc.connect(g)
  g.connect(dest || sfxGain)
  osc.start(t)
  osc.stop(t + dur + 0.05)
}

/** Filtered noise — the basis of every whoosh, hit and explosion. */
function noise({ dur = 0.2, freq = 1200, to, q = 1, gain = 0.3, delay = 0, type = 'bandpass' }) {
  const c = ensure()
  if (!c || !unlocked) return
  const t = now() + delay
  const len = Math.max(1, Math.floor(c.sampleRate * dur))
  const buf = c.createBuffer(1, len, c.sampleRate)
  const data = buf.getChannelData(0)
  for (let i = 0; i < len; i++) data[i] = Math.random() * 2 - 1
  const src = c.createBufferSource()
  src.buffer = buf
  const f = c.createBiquadFilter()
  f.type = type
  f.Q.value = q
  f.frequency.setValueAtTime(freq, t)
  if (to) f.frequency.exponentialRampToValueAtTime(Math.max(40, to), t + dur)
  const g = c.createGain()
  g.gain.setValueAtTime(gain, t)
  g.gain.exponentialRampToValueAtTime(0.0001, t + dur)
  src.connect(f)
  f.connect(g)
  g.connect(sfxGain)
  src.start(t)
  src.stop(t + dur + 0.02)
}

/* ------------------------------ sound effects ----------------------------- */

export const sfx = {
  hover: () => tone({ freq: 520, type: 'sine', dur: 0.06, gain: 0.07 }),
  click: () => {
    tone({ freq: 660, to: 990, type: 'square', dur: 0.07, gain: 0.12 })
    noise({ dur: 0.05, freq: 3000, gain: 0.05 })
  },
  back: () => tone({ freq: 420, to: 260, type: 'square', dur: 0.1, gain: 0.1 }),

  whoosh: () => noise({ dur: 0.28, freq: 300, to: 2400, q: 0.8, gain: 0.14 }),
  tick: () => tone({ freq: 1200, type: 'square', dur: 0.03, gain: 0.06 }),

  // Countdown: three low beeps then a bright chord.
  beep: (n = 0) => tone({ freq: 440 + n * 60, type: 'triangle', dur: 0.14, gain: 0.2 }),
  go: () => {
    [523, 659, 784, 1047].forEach((f, i) =>
      tone({ freq: f, type: 'triangle', dur: 0.5, gain: 0.16, delay: i * 0.045 })
    )
  },

  // Kinetic
  grab: () => {
    tone({ freq: 160, to: 420, type: 'sine', dur: 0.16, gain: 0.22 })
    noise({ dur: 0.1, freq: 900, to: 2600, gain: 0.08 })
  },
  release: () => {
    noise({ dur: 0.24, freq: 2200, to: 400, q: 1.2, gain: 0.16 })
    tone({ freq: 520, to: 180, type: 'sine', dur: 0.2, gain: 0.12 })
  },
  bank: (streak = 0) => {
    const base = 523 * Math.pow(1.0595, Math.min(streak, 12) * 2)
    ;[0, 4, 7, 12].forEach((s, i) =>
      tone({ freq: base * Math.pow(2, s / 12), type: 'triangle', dur: 0.42, gain: 0.14, delay: i * 0.04 })
    )
    noise({ dur: 0.3, freq: 4000, to: 900, gain: 0.06 })
  },

  // Duel
  shot: () => {
    noise({ dur: 0.34, freq: 1800, to: 120, q: 0.6, gain: 0.5 })
    tone({ freq: 110, to: 40, type: 'square', dur: 0.3, gain: 0.35 })
  },
  ricochet: () => tone({ freq: 2400, to: 700, type: 'sawtooth', dur: 0.22, gain: 0.1 }),
  holster: () => tone({ freq: 200, type: 'sine', dur: 0.09, gain: 0.1 }),

  // Rocket
  thrust: () => noise({ dur: 0.12, freq: 220, q: 0.5, gain: 0.05 }),
  crash: () => {
    noise({ dur: 0.8, freq: 900, to: 60, q: 0.4, gain: 0.45 })
    tone({ freq: 90, to: 30, type: 'sawtooth', dur: 0.7, gain: 0.3 })
  },
  gate: () => tone({ freq: 880, type: 'sine', dur: 0.06, gain: 0.05 }),

  // Dance / poses
  perfect: () => {
    [784, 988, 1175].forEach((f, i) =>
      tone({ freq: f, type: 'triangle', dur: 0.5, gain: 0.15, delay: i * 0.05 })
    )
  },
  great: () => [659, 831].forEach((f, i) => tone({ freq: f, type: 'triangle', dur: 0.36, gain: 0.13, delay: i * 0.05 })),
  good: () => tone({ freq: 523, type: 'triangle', dur: 0.26, gain: 0.11 }),
  miss: () => tone({ freq: 180, to: 120, type: 'sawtooth', dur: 0.24, gain: 0.12 }),
  combo: (n) => tone({ freq: 600 + Math.min(n, 15) * 45, type: 'square', dur: 0.1, gain: 0.09 }),

  // Paint
  penDown: () => tone({ freq: 320, type: 'sine', dur: 0.05, gain: 0.06 }),
  pick: () => tone({ freq: 880, to: 1320, type: 'sine', dur: 0.12, gain: 0.1 }),
  clear: () => noise({ dur: 0.4, freq: 3000, to: 300, gain: 0.14 }),

  win: () => {
    [523, 659, 784, 1047, 1319].forEach((f, i) =>
      tone({ freq: f, type: 'triangle', dur: 0.7, gain: 0.16, delay: i * 0.09 })
    )
  },
  lose: () => [392, 330, 262].forEach((f, i) => tone({ freq: f, type: 'sawtooth', dur: 0.5, gain: 0.13, delay: i * 0.13 })),
}

/* --------------------------------- music ---------------------------------- */
// A small lookahead sequencer. Patterns are semitone offsets from the root;
// null is a rest.

const MOODS = {
  western: {
    bpm: 84, root: 146.83, wave: 'triangle',
    bass: [0, null, 7, null, 5, null, 7, null],
    lead: [12, 15, 19, 15, 12, null, 10, null],
    drums: [1, 0, 0, 0, 1, 0, 0, 0],
  },
  space: {
    bpm: 96, root: 130.81, wave: 'sawtooth',
    bass: [0, 0, null, 0, 3, null, 5, null],
    lead: [12, 19, 24, 19, 15, 22, 19, 15],
    drums: [1, 0, 1, 0, 1, 0, 1, 0],
  },
  dance: {
    bpm: 124, root: 110, wave: 'square',
    bass: [0, 0, 7, 0, 5, 5, 3, 7],
    lead: [12, 15, 12, 19, 17, 15, 12, 10],
    drums: [1, 0, 2, 0, 1, 0, 2, 0],
  },
  chill: {
    bpm: 70, root: 174.61, wave: 'sine',
    bass: [0, null, null, 5, null, null, 7, null],
    lead: [12, null, 16, null, 19, null, 16, null],
    drums: [0, 0, 0, 0, 0, 0, 0, 0],
  },
}

let timer = null
let step = 0
let nextTime = 0
let currentMood = null

function scheduleStep(m, t) {
  const semi = (n) => m.root * Math.pow(2, n / 12)
  const b = m.bass[step % m.bass.length]
  if (b != null) {
    tone({ freq: semi(b) / 2, to: semi(b) / 2, type: 'triangle', dur: 0.34, gain: 0.24, delay: t, dest: musicGain })
  }
  const l = m.lead[step % m.lead.length]
  if (l != null) {
    tone({ freq: semi(l), type: m.wave, dur: 0.26, gain: 0.09, delay: t, dest: musicGain })
  }
  const d = m.drums[step % m.drums.length]
  if (d === 1) {
    tone({ freq: 120, to: 45, type: 'sine', dur: 0.16, gain: 0.3, delay: t, dest: musicGain })
  } else if (d === 2) {
    noise({ dur: 0.09, freq: 5200, q: 1.5, gain: 0.05, delay: t })
  }
}

export function playMusic(mood) {
  const c = ensure()
  if (!c || !unlocked || !MOODS[mood]) return
  if (currentMood === mood && timer) return
  stopMusic()
  currentMood = mood
  const m = MOODS[mood]
  const stepDur = 60 / m.bpm / 2
  step = 0
  nextTime = now() + 0.1
  timer = setInterval(() => {
    if (!ctx) return
    while (nextTime < ctx.currentTime + 0.25) {
      scheduleStep(m, Math.max(0, nextTime - ctx.currentTime))
      nextTime += stepDur
      step += 1
    }
  }, 40)
}

export function stopMusic() {
  if (timer) clearInterval(timer)
  timer = null
  currentMood = null
}

/** Wire this up once so the first click anywhere enables audio. */
export function installUnlockListener() {
  const go = () => unlock()
  window.addEventListener('pointerdown', go, { once: true })
  window.addEventListener('keydown', go, { once: true })
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/characters.js <<'HANDPLAY_EOF'
// Draws a proper character from pose landmarks instead of a stick figure.
// Limbs are tapered capsules, the torso is a filled shell, and the head carries
// a visor — the same rig serves the player, the hologram target and the crowd.

function len(a, b) {
  return Math.hypot(b.x - a.x, b.y - a.y)
}

/** A tapered capsule from a to b, wide at a and narrow at b. */
export function limb(ctx, a, b, wa, wb, fill) {
  const dx = b.x - a.x
  const dy = b.y - a.y
  const d = Math.hypot(dx, dy) || 1
  const nx = -dy / d
  const ny = dx / d
  ctx.beginPath()
  ctx.moveTo(a.x + nx * wa, a.y + ny * wa)
  ctx.lineTo(b.x + nx * wb, b.y + ny * wb)
  ctx.arc(b.x, b.y, wb, Math.atan2(ny, nx), Math.atan2(-ny, -nx), false)
  ctx.lineTo(a.x - nx * wa, a.y - ny * wa)
  ctx.arc(a.x, a.y, wa, Math.atan2(-ny, -nx), Math.atan2(ny, nx), false)
  ctx.closePath()
  ctx.fillStyle = fill
  ctx.fill()
}

/**
 * pts: { [landmarkIndex]: {x, y} } in screen pixels. Needs 0, 11, 12, 13, 14,
 * 15, 16, 23, 24, 25, 26, 27, 28.
 * limbColor(a, b) may return a per-bone colour for match feedback.
 */
export function drawCharacter(ctx, pts, opts = {}) {
  const {
    color = '#00E5B0',
    accent = '#FFFFFF',
    alpha = 1,
    hologram = false,
    limbColor = null,
    glow = 18,
    face = true,
  } = opts

  const P = (i) => pts[i]
  const has = (...ids) => ids.every((i) => pts[i])
  if (!has(11, 12, 23, 24)) return

  const shoulderW = len(P(11), P(12)) || 40
  const unit = Math.max(6, shoulderW * 0.5)

  ctx.save()
  ctx.globalAlpha = alpha
  ctx.lineJoin = 'round'
  ctx.lineCap = 'round'
  if (glow) {
    ctx.shadowColor = color
    ctx.shadowBlur = glow
  }

  const shade = hologram ? withAlpha(color, 0.30) : color
  const bone = (a, b, wa, wb) => {
    const c = limbColor ? limbColor(a, b) : null
    limb(ctx, P(a), P(b), wa, wb, c || shade)
  }

  const hipMid = { x: (P(23).x + P(24).x) / 2, y: (P(23).y + P(24).y) / 2 }
  const shMid = { x: (P(11).x + P(12).x) / 2, y: (P(11).y + P(12).y) / 2 }

  // Legs first so the torso overlaps them at the hip.
  if (has(24, 26, 28)) { bone(24, 26, unit * 0.40, unit * 0.30); bone(26, 28, unit * 0.30, unit * 0.20) }
  if (has(23, 25, 27)) { bone(23, 25, unit * 0.40, unit * 0.30); bone(25, 27, unit * 0.30, unit * 0.20) }
  if (has(28)) foot(ctx, P(26) || P(28), P(28), unit * 0.26, shade)
  if (has(27)) foot(ctx, P(25) || P(27), P(27), unit * 0.26, shade)

  // Torso shell
  ctx.beginPath()
  const spread = unit * 0.16
  ctx.moveTo(P(12).x, P(12).y - spread)
  ctx.lineTo(P(11).x, P(11).y - spread)
  ctx.quadraticCurveTo(P(11).x + (P(23).x - P(11).x) * 0.5 + spread, (P(11).y + P(23).y) / 2, P(23).x, P(23).y)
  ctx.lineTo(P(24).x, P(24).y)
  ctx.quadraticCurveTo(P(12).x + (P(24).x - P(12).x) * 0.5 - spread, (P(12).y + P(24).y) / 2, P(12).x, P(12).y - spread)
  ctx.closePath()
  const torso = ctx.createLinearGradient(shMid.x, shMid.y, hipMid.x, hipMid.y)
  torso.addColorStop(0, hologram ? withAlpha(color, 0.34) : lighten(color, 0.18))
  torso.addColorStop(1, hologram ? withAlpha(color, 0.16) : darken(color, 0.28))
  ctx.fillStyle = torso
  ctx.fill()

  // Chest emblem
  ctx.globalAlpha = alpha * (hologram ? 0.5 : 0.85)
  ctx.fillStyle = accent
  ctx.beginPath()
  ctx.arc(shMid.x + (hipMid.x - shMid.x) * 0.32, shMid.y + (hipMid.y - shMid.y) * 0.32, unit * 0.16, 0, Math.PI * 2)
  ctx.fill()
  ctx.globalAlpha = alpha

  // Arms over the torso
  if (has(12, 14, 16)) { bone(12, 14, unit * 0.32, unit * 0.24); bone(14, 16, unit * 0.24, unit * 0.16) }
  if (has(11, 13, 15)) { bone(11, 13, unit * 0.32, unit * 0.24); bone(13, 15, unit * 0.24, unit * 0.16) }
  if (has(16)) hand(ctx, P(16), unit * 0.20, shade)
  if (has(15)) hand(ctx, P(15), unit * 0.20, shade)

  // Neck + head
  const headR = Math.max(10, shoulderW * 0.40)
  const head = P(0) || { x: shMid.x, y: shMid.y - headR * 1.5 }
  limb(ctx, shMid, { x: head.x, y: head.y + headR * 0.7 }, unit * 0.22, unit * 0.18, shade)

  const hg = ctx.createRadialGradient(head.x - headR * 0.3, head.y - headR * 0.35, headR * 0.15, head.x, head.y, headR)
  hg.addColorStop(0, hologram ? withAlpha(color, 0.55) : lighten(color, 0.3))
  hg.addColorStop(1, hologram ? withAlpha(color, 0.22) : darken(color, 0.2))
  ctx.fillStyle = hg
  ctx.beginPath()
  ctx.arc(head.x, head.y, headR, 0, Math.PI * 2)
  ctx.fill()

  if (face) {
    // A visor reads as a character at any size and never lands in uncanny valley.
    ctx.shadowBlur = 0
    ctx.globalAlpha = alpha * (hologram ? 0.55 : 0.95)
    ctx.fillStyle = hologram ? withAlpha(accent, 0.5) : '#0A0A12'
    ctx.beginPath()
    ctx.ellipse(head.x, head.y - headR * 0.06, headR * 0.66, headR * 0.34, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = accent
    ctx.globalAlpha = alpha
    ctx.beginPath()
    ctx.ellipse(head.x - headR * 0.3, head.y - headR * 0.08, headR * 0.14, headR * 0.14, 0, 0, Math.PI * 2)
    ctx.ellipse(head.x + headR * 0.3, head.y - headR * 0.08, headR * 0.14, headR * 0.14, 0, 0, Math.PI * 2)
    ctx.fill()
  }

  if (hologram) {
    // Scanlines sell the "projection" without hiding the shape.
    ctx.save()
    ctx.globalAlpha = alpha * 0.16
    ctx.strokeStyle = accent
    ctx.lineWidth = 1
    const top = head.y - headR * 1.4
    const bottom = Math.max(P(27) ? P(27).y : hipMid.y, P(28) ? P(28).y : hipMid.y) + 20
    for (let y = top; y < bottom; y += 7) {
      ctx.beginPath()
      ctx.moveTo(head.x - shoulderW * 1.8, y)
      ctx.lineTo(head.x + shoulderW * 1.8, y)
      ctx.stroke()
    }
    ctx.restore()
  }

  ctx.restore()
}

function hand(ctx, p, r, fill) {
  ctx.beginPath()
  ctx.arc(p.x, p.y, r, 0, Math.PI * 2)
  ctx.fillStyle = fill
  ctx.fill()
}

function foot(ctx, knee, ankle, r, fill) {
  const dx = ankle.x - knee.x
  const dy = ankle.y - knee.y
  const d = Math.hypot(dx, dy) || 1
  ctx.save()
  ctx.translate(ankle.x, ankle.y)
  ctx.rotate(Math.atan2(dy, dx) - Math.PI / 2)
  ctx.fillStyle = fill
  ctx.beginPath()
  ctx.ellipse(0, r * 0.3, r * 1.25, r * 0.62, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

/* ------------------------------ colour utils ------------------------------ */

function parse(hex) {
  const h = hex.replace('#', '')
  const n = parseInt(h.length === 3 ? h.split('').map((c) => c + c).join('') : h, 16)
  return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 }
}
export function withAlpha(hex, a) {
  const { r, g, b } = parse(hex)
  return `rgba(${r},${g},${b},${a})`
}
export function lighten(hex, amt) {
  const { r, g, b } = parse(hex)
  const f = (v) => Math.round(v + (255 - v) * amt)
  return `rgb(${f(r)},${f(g)},${f(b)})`
}
export function darken(hex, amt) {
  const { r, g, b } = parse(hex)
  const f = (v) => Math.round(v * (1 - amt))
  return `rgb(${f(r)},${f(g)},${f(b)})`
}

/* ------------------------------- the cowboy ------------------------------- */

/**
 * A gunslinger for the duel. `raise` is 0 (holstered) to 1 (levelled).
 * Idle sway keeps him alive between rounds.
 */
export function drawGunslinger(ctx, x, groundY, scale, opts = {}) {
  const { color = '#FFB000', raise = 0, facing = 1, cocked = false, defeated = false, t = 0 } = opts
  const s = scale
  const sway = defeated ? 0 : Math.sin(t * 0.0016) * 2.2
  const slump = defeated ? 1 : 0

  ctx.save()
  ctx.translate(x, groundY + slump * 14 * s)
  ctx.scale(facing, 1)

  // Long shadow toward the sun
  ctx.save()
  ctx.globalAlpha = 0.35
  ctx.fillStyle = '#120A10'
  ctx.beginPath()
  ctx.ellipse(0, 2 * s, 26 * s, 6 * s, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()

  ctx.globalAlpha = defeated ? 0.55 : 1
  const coat = darken(color, 0.55)
  const trim = color

  // Legs
  limb(ctx, { x: -5 * s, y: -34 * s }, { x: -8 * s, y: 0 }, 5 * s, 3.6 * s, coat)
  limb(ctx, { x: 5 * s, y: -34 * s }, { x: 9 * s, y: 0 }, 5 * s, 3.6 * s, coat)
  ctx.fillStyle = darken(color, 0.7)
  ctx.beginPath()
  ctx.ellipse(-9 * s, 0, 7 * s, 2.6 * s, 0, 0, Math.PI * 2)
  ctx.ellipse(10 * s, 0, 7 * s, 2.6 * s, 0, 0, Math.PI * 2)
  ctx.fill()

  // Poncho / torso
  const g = ctx.createLinearGradient(0, -60 * s, 0, -28 * s)
  g.addColorStop(0, lighten(color, 0.1))
  g.addColorStop(1, darken(color, 0.45))
  ctx.fillStyle = g
  ctx.beginPath()
  ctx.moveTo(-11 * s, -60 * s + sway * 0.3)
  ctx.lineTo(11 * s, -60 * s + sway * 0.3)
  ctx.lineTo(15 * s, -28 * s)
  ctx.lineTo(-15 * s, -28 * s)
  ctx.closePath()
  ctx.fill()
  ctx.fillStyle = withAlpha(trim, 0.65)
  ctx.fillRect(-15 * s, -32 * s, 30 * s, 2.4 * s)

  // Gun arm swings up as the player draws
  const shoulder = { x: 10 * s, y: -55 * s + sway * 0.3 }
  const ang = -0.15 - raise * 1.25
  const elbow = { x: shoulder.x + Math.cos(ang) * 13 * s, y: shoulder.y + 13 * s - raise * 5 * s }
  const wrist = { x: elbow.x + 15 * s, y: elbow.y - raise * 16 * s + (1 - raise) * 8 * s }
  limb(ctx, shoulder, elbow, 4.6 * s, 3.8 * s, darken(color, 0.35))
  limb(ctx, elbow, wrist, 3.8 * s, 3 * s, darken(color, 0.35))

  // Off arm
  const sh2 = { x: -10 * s, y: -55 * s + sway * 0.3 }
  limb(ctx, sh2, { x: -14 * s, y: -40 * s }, 4.6 * s, 3.6 * s, darken(color, 0.4))
  limb(ctx, { x: -14 * s, y: -40 * s }, { x: -13 * s, y: -30 * s }, 3.6 * s, 2.8 * s, darken(color, 0.4))

  // Head + hat
  const hy = -68 * s + sway * 0.4
  ctx.fillStyle = lighten(color, 0.35)
  ctx.beginPath()
  ctx.arc(0, hy, 7.5 * s, 0, Math.PI * 2)
  ctx.fill()
  ctx.fillStyle = '#1A1118'
  ctx.beginPath()
  ctx.ellipse(1.5 * s, hy - 0.5 * s, 5.2 * s, 2.2 * s, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.fillStyle = darken(color, 0.6)
  ctx.beginPath()
  ctx.ellipse(0, hy - 5.5 * s, 17 * s, 3.2 * s, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.moveTo(-8 * s, hy - 6 * s)
  ctx.quadraticCurveTo(0, hy - 20 * s, 8 * s, hy - 6 * s)
  ctx.closePath()
  ctx.fill()
  ctx.fillStyle = withAlpha(trim, 0.7)
  ctx.fillRect(-8 * s, hy - 8 * s, 16 * s, 1.8 * s)

  ctx.restore()
  return { x: x + facing * (wristX(raise, s)), y: groundY + wristY(raise, s), cocked }
}

const wristX = (raise, s) => (10 + Math.cos(-0.15 - raise * 1.25) * 13 + 15) * s
const wristY = (raise, s) => -55 * s + 13 * s - raise * 5 * s - raise * 16 * s + (1 - raise) * 8 * s

/* -------------------------------- the ship -------------------------------- */

export function drawShip(ctx, x, y, s, color, t, dead = false) {
  ctx.save()
  ctx.translate(x, y)
  if (dead) ctx.globalAlpha = 0.25

  // Thruster plume
  if (!dead) {
    const flick = 1 + Math.sin(t * 0.05) * 0.3
    const fl = ctx.createLinearGradient(-10 * s, 0, -34 * s * flick, 0)
    fl.addColorStop(0, '#FFF6D0')
    fl.addColorStop(0.35, color)
    fl.addColorStop(1, withAlpha(color, 0))
    ctx.fillStyle = fl
    ctx.beginPath()
    ctx.moveTo(-9 * s, -5 * s)
    ctx.lineTo(-34 * s * flick, 0)
    ctx.lineTo(-9 * s, 5 * s)
    ctx.closePath()
    ctx.fill()
  }

  ctx.shadowColor = color
  ctx.shadowBlur = 18

  // Fins
  ctx.fillStyle = darken(color, 0.45)
  ctx.beginPath()
  ctx.moveTo(-6 * s, -4 * s); ctx.lineTo(-16 * s, -13 * s); ctx.lineTo(-4 * s, -3 * s)
  ctx.closePath(); ctx.fill()
  ctx.beginPath()
  ctx.moveTo(-6 * s, 4 * s); ctx.lineTo(-16 * s, 13 * s); ctx.lineTo(-4 * s, 3 * s)
  ctx.closePath(); ctx.fill()

  // Hull
  const hull = ctx.createLinearGradient(0, -8 * s, 0, 8 * s)
  hull.addColorStop(0, lighten(color, 0.45))
  hull.addColorStop(0.5, color)
  hull.addColorStop(1, darken(color, 0.4))
  ctx.fillStyle = hull
  ctx.beginPath()
  ctx.moveTo(22 * s, 0)
  ctx.quadraticCurveTo(6 * s, -8 * s, -10 * s, -6 * s)
  ctx.lineTo(-10 * s, 6 * s)
  ctx.quadraticCurveTo(6 * s, 8 * s, 22 * s, 0)
  ctx.closePath()
  ctx.fill()

  // Cockpit
  ctx.shadowBlur = 0
  ctx.fillStyle = 'rgba(180,240,255,0.9)'
  ctx.beginPath()
  ctx.ellipse(7 * s, -1 * s, 5 * s, 3 * s, -0.15, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/filter.js <<'HANDPLAY_EOF'
// Raw MediaPipe landmarks jitter by a pixel or two every frame even when a hand
// is perfectly still, and that shimmer is what makes tracking look cheap. A
// plain moving average would fix it but add lag, which feels worse in a game.
//
// The One Euro filter adapts instead: it smooths hard when you are still and
// barely at all when you move fast, so noise disappears while fast motion stays
// responsive.

const TAU = 2 * Math.PI

function alphaFor(cutoff, dt) {
  const tau = 1 / (TAU * cutoff)
  return 1 / (1 + tau / dt)
}

// Tuned by measurement, not guesswork: these values cut the noise on a still
// hand by ~11x while keeping a full-width swipe within ~5% of the true
// position. Raising beta buys responsiveness, lowering it buys steadiness.
export function createOneEuro({ minCutoff = 1.2, beta = 5.0, dCutoff = 1.0 } = {}) {
  let xPrev = null
  let dxPrev = 0
  let tPrev = null

  return {
    /** value in any unit, t in seconds. */
    filter(value, t) {
      if (!Number.isFinite(value)) return xPrev ?? 0
      if (xPrev === null || tPrev === null) {
        xPrev = value
        tPrev = t
        return value
      }
      let dt = t - tPrev
      // Guard against zero, negative or absurd gaps (tab was backgrounded).
      if (!(dt > 0) || dt > 0.25) dt = 1 / 60
      tPrev = t

      const dx = (value - xPrev) / dt
      const aD = alphaFor(dCutoff, dt)
      dxPrev = aD * dx + (1 - aD) * dxPrev

      const cutoff = minCutoff + beta * Math.abs(dxPrev)
      const a = alphaFor(cutoff, dt)
      xPrev = a * value + (1 - a) * xPrev
      return xPrev
    },
    reset() {
      xPrev = null
      dxPrev = 0
      tPrev = null
    },
  }
}

/**
 * Smooths a whole landmark array. One filter per landmark per axis, created
 * lazily so it works for hands (21 points) and bodies (33) alike.
 */
export function createLandmarkSmoother(opts = {}) {
  const axes = ['x', 'y', 'z']
  const filters = []

  return {
    apply(landmarks, tSeconds) {
      const out = new Array(landmarks.length)
      for (let i = 0; i < landmarks.length; i++) {
        const lm = landmarks[i]
        if (!lm) { out[i] = lm; continue }
        let slot = filters[i]
        if (!slot) {
          slot = { x: createOneEuro(opts), y: createOneEuro(opts), z: createOneEuro(opts) }
          filters[i] = slot
        }
        const next = { ...lm }
        for (const ax of axes) {
          if (typeof lm[ax] === 'number') next[ax] = slot[ax].filter(lm[ax], tSeconds)
        }
        out[i] = next
      }
      return out
    },
    reset() {
      for (const s of filters) if (s) { s.x.reset(); s.y.reset(); s.z.reset() }
    },
  }
}

/**
 * Rejects detections that are geometrically impossible, before they reach a
 * game. A hand collapsed to a few pixels or landmarks far outside the frame is
 * noise, and acting on it produces phantom inputs.
 */
export function plausibleHand(lm) {
  if (!lm || lm.length < 21) return false
  const span = Math.hypot(lm[0].x - lm[9].x, lm[0].y - lm[9].y)
  if (!(span > 0.015) || span > 0.9) return false
  let inside = 0
  for (const p of lm) {
    if (!Number.isFinite(p.x) || !Number.isFinite(p.y)) return false
    if (p.x > -0.25 && p.x < 1.25 && p.y > -0.25 && p.y < 1.25) inside += 1
  }
  return inside >= lm.length * 0.75
}

export function plausiblePose(lm) {
  if (!lm || lm.length < 33) return false
  const core = [11, 12, 23, 24]
  let seen = 0
  for (const i of core) {
    const p = lm[i]
    if (!p || !Number.isFinite(p.x)) return false
    if ((p.visibility ?? 1) >= 0.35) seen += 1
  }
  if (seen < 2) return false
  const shoulders = Math.hypot(lm[11].x - lm[12].x, lm[11].y - lm[12].y)
  return shoulders > 0.01
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/render.js <<'HANDPLAY_EOF'
// Shared look-and-feel layer.
//
// Every game previously lit its shapes with ctx.shadowBlur, which is convenient
// but re-blurs on every single draw call — with four glowing characters on
// screen that alone can halve the frame rate. Drawing the glowing pass once
// into a half-resolution buffer, blurring it once, and adding it back is both
// faster and a much better looking bloom.

export function createBloom(scale = 0.5) {
  let buf = null
  let bctx = null

  return {
    /** Returns a context to draw the glowing pass into, already cleared. */
    layer(W, H) {
      const w = Math.max(1, Math.round(W * scale))
      const h = Math.max(1, Math.round(H * scale))
      if (!buf) buf = document.createElement('canvas')
      if (buf.width !== w || buf.height !== h) {
        buf.width = w
        buf.height = h
      }
      bctx = buf.getContext('2d')
      bctx.setTransform(scale, 0, 0, scale, 0, 0)
      bctx.clearRect(0, 0, W, H)
      return bctx
    },

    /** Adds the blurred glow back over the scene. */
    composite(ctx, W, H, { blur = 12, alpha = 0.9, passes = 2 } = {}) {
      if (!buf) return
      ctx.save()
      ctx.globalCompositeOperation = 'lighter'
      const canFilter = typeof ctx.filter === 'string'
      for (let i = 0; i < passes; i++) {
        ctx.globalAlpha = alpha / (i + 1)
        if (canFilter) ctx.filter = `blur(${blur * (i + 1)}px)`
        ctx.drawImage(buf, 0, 0, W, H)
      }
      ctx.restore()
      if (typeof ctx.filter === 'string') ctx.filter = 'none'
    },
  }
}

/**
 * Paints the camera feed behind the game, cropped to fill.
 *
 * Showing people themselves is what made Kinect legible — without it players
 * have no idea where they are in frame, and step out of shot without knowing
 * why tracking stopped.
 */
export function drawCameraBackdrop(ctx, video, W, H, opts = {}) {
  const {
    mirror = true,
    alpha = 0.30,
    grade = 'grayscale(0.75) brightness(0.55) contrast(1.15)',
  } = opts
  if (!video || video.readyState < 2 || !video.videoWidth) return false

  const vw = video.videoWidth
  const vh = video.videoHeight
  const scale = Math.max(W / vw, H / vh)
  const dw = vw * scale
  const dh = vh * scale

  ctx.save()
  ctx.globalAlpha = alpha
  if (typeof ctx.filter === 'string' && grade) ctx.filter = grade
  if (mirror) {
    ctx.translate(W, 0)
    ctx.scale(-1, 1)
  }
  try {
    ctx.drawImage(video, (W - dw) / 2, (H - dh) / 2, dw, dh)
  } catch {
    // Safari can throw briefly while the stream is still settling.
  }
  ctx.restore()
  if (typeof ctx.filter === 'string') ctx.filter = 'none'
  return true
}

export function drawVignette(ctx, W, H, strength = 0.55) {
  const g = ctx.createRadialGradient(
    W / 2, H / 2, Math.min(W, H) * 0.28,
    W / 2, H / 2, Math.max(W, H) * 0.78
  )
  g.addColorStop(0, 'rgba(0,0,0,0)')
  g.addColorStop(1, `rgba(0,0,0,${strength})`)
  ctx.fillStyle = g
  ctx.fillRect(0, 0, W, H)
}

/** A colour wash that ties the camera feed and the game art together. */
export function drawColorGrade(ctx, W, H, color, alpha = 0.14) {
  ctx.save()
  ctx.globalCompositeOperation = 'overlay'
  ctx.globalAlpha = alpha
  ctx.fillStyle = color
  ctx.fillRect(0, 0, W, H)
  ctx.restore()
}

/**
 * Frame edge that turns red when the player drifts out of shot, so people
 * self-correct instead of wondering why nothing is responding.
 */
export function drawFrameGuide(ctx, W, H, ok, pulse = 0) {
  const col = ok ? 'rgba(0,229,176,0.18)' : `rgba(255,77,141,${0.30 + pulse * 0.25})`
  ctx.save()
  ctx.strokeStyle = col
  ctx.lineWidth = ok ? 2 : 4
  const m = 12
  const c = 42
  const corners = [
    [m, m, 1, 1], [W - m, m, -1, 1], [m, H - m, 1, -1], [W - m, H - m, -1, -1],
  ]
  for (const [x, y, sx, sy] of corners) {
    ctx.beginPath()
    ctx.moveTo(x + sx * c, y)
    ctx.lineTo(x, y)
    ctx.lineTo(x, y + sy * c)
    ctx.stroke()
  }
  ctx.restore()
}

/** Screen shake helper: returns the offset to translate by, and decays itself. */
export function shakeOffset(state, dt, decay = 3.2) {
  if (!state.amount || state.amount <= 0) return { x: 0, y: 0 }
  state.amount = Math.max(0, state.amount - dt * decay)
  const m = state.amount * (state.magnitude || 14)
  return { x: (Math.random() - 0.5) * m, y: (Math.random() - 0.5) * m }
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/scene3d.js <<'HANDPLAY_EOF'
// A small perspective renderer for the first-person games.
//
// The trick that makes a flat screen feel like a window into a room is
// head-coupled perspective: the virtual camera follows the player's real head,
// so leaning left genuinely reveals what was hidden behind the left edge.
// Everything here works in a right-handed space where +z goes away from the
// viewer, +x is right and +y is down.

export function createCamera({ fov = Math.PI / 2.6, parallax = 1.5, ease = 6 } = {}) {
  const eye = { x: 0, y: 0, z: 0 }
  const target = { x: 0, y: 0 }
  let shake = 0

  return {
    eye,
    get shake() { return shake },
    kick(amount = 1) { shake = Math.min(1.5, shake + amount) },

    /**
     * headX / headY are normalised screen coordinates of the player's head.
     * The camera offset is deliberately larger than life — a subtle shift reads
     * as a rendering wobble, a strong one reads as looking around.
     */
    track(headX, headY, dt) {
      if (Number.isFinite(headX)) target.x = (headX - 0.5) * parallax * 2
      if (Number.isFinite(headY)) target.y = (headY - 0.55) * parallax
      const k = Math.min(1, dt * ease)
      eye.x += (target.x - eye.x) * k
      eye.y += (target.y - eye.y) * k
      shake = Math.max(0, shake - dt * 3)
    },

    /** World point -> screen. Returns null when behind or beside the viewer. */
    project(p, W, H) {
      const focal = H / 2 / Math.tan(fov / 2)
      const dz = p.z - eye.z
      if (dz < 0.35) return null
      const f = focal / dz
      const jitter = shake ? (Math.random() - 0.5) * shake * 14 : 0
      return {
        x: W / 2 + (p.x - eye.x) * f + jitter,
        y: H / 2 + (p.y - eye.y) * f + jitter,
        s: f,
        z: dz,
      }
    },

    reset() {
      eye.x = 0
      eye.y = 0
      target.x = 0
      target.y = 0
      shake = 0
    },
  }
}

/** Distant things fade into the haze — the strongest depth cue after scale. */
export function fogAlpha(z, near = 6, far = 34) {
  if (z <= near) return 1
  if (z >= far) return 0
  return 1 - (z - near) / (far - near)
}

/**
 * A receding corridor. Rings are drawn far to near so nearer geometry covers
 * what is behind it without needing a depth buffer.
 */
export function drawCorridor(ctx, cam, W, H, opts = {}) {
  const {
    z0 = 0, spacing = 4, count = 14, radius = 5.2,
    color = '#7C5CFF', sides = 8, roll = 0,
  } = opts

  for (let i = count; i >= 1; i--) {
    const z = z0 + i * spacing
    const a = fogAlpha(z, spacing * 2, spacing * count)
    if (a <= 0.01) continue
    const pts = []
    for (let s = 0; s < sides; s++) {
      const ang = (s / sides) * Math.PI * 2 + roll + i * 0.05
      const p = cam.project({ x: Math.cos(ang) * radius, y: Math.sin(ang) * radius, z }, W, H)
      if (!p) { pts.length = 0; break }
      pts.push(p)
    }
    if (pts.length < 3) continue
    ctx.save()
    ctx.globalAlpha = a * 0.55
    ctx.strokeStyle = color
    ctx.lineWidth = Math.max(0.5, 2.4 * a)
    ctx.beginPath()
    ctx.moveTo(pts[0].x, pts[0].y)
    for (let k = 1; k < pts.length; k++) ctx.lineTo(pts[k].x, pts[k].y)
    ctx.closePath()
    ctx.stroke()
    ctx.restore()
  }
}

/** Ground plane with lines running to the horizon. */
export function drawFloorGrid(ctx, cam, W, H, opts = {}) {
  const { y = 3.2, z0 = 0, depth = 44, step = 3, halfWidth = 16, color = '#3AF0C8' } = opts
  ctx.save()
  ctx.strokeStyle = color
  ctx.lineWidth = 1

  for (let x = -halfWidth; x <= halfWidth; x += step) {
    const a = cam.project({ x, y, z: z0 + 1.2 }, W, H)
    const b = cam.project({ x, y, z: z0 + depth }, W, H)
    if (!a || !b) continue
    ctx.globalAlpha = 0.18
    ctx.beginPath()
    ctx.moveTo(a.x, a.y)
    ctx.lineTo(b.x, b.y)
    ctx.stroke()
  }
  for (let z = z0 + 2; z < z0 + depth; z += step) {
    const a = cam.project({ x: -halfWidth, y, z }, W, H)
    const b = cam.project({ x: halfWidth, y, z }, W, H)
    if (!a || !b) continue
    ctx.globalAlpha = 0.10 + fogAlpha(z - z0, 4, depth) * 0.22
    ctx.beginPath()
    ctx.moveTo(a.x, a.y)
    ctx.lineTo(b.x, b.y)
    ctx.stroke()
  }
  ctx.restore()
}

/** Shadow blob on the floor, so 3D characters do not look pasted on. */
export function drawGroundShadow(ctx, cam, W, H, x, z, size, floorY = 3.2) {
  const p = cam.project({ x, y: floorY, z }, W, H)
  if (!p) return
  ctx.save()
  ctx.globalAlpha = 0.32 * fogAlpha(p.z, 8, 36)
  ctx.fillStyle = '#000'
  ctx.beginPath()
  ctx.ellipse(p.x, p.y, size * p.s * 0.5, size * p.s * 0.18, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

/** Sorts anything with a `z` so far things draw first. */
export function byDepth(a, b) {
  return b.z - a.z
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/combat.js <<'HANDPLAY_EOF'
// Reading a punch from a single 2D camera.
//
// There is no depth sensor, so forward motion has to be inferred. A hand thrust
// toward the lens grows rapidly on screen, and that growth rate is a reliable
// signal: it is large for a jab and near zero for a hand waved sideways, which
// is exactly the discrimination a brawler needs.

import { handSpan, openness, palmCenter } from './gestures.js'

export function createPunchDetector({
  growthThreshold = 1.6,   // span doublings per second
  cooldownMs = 320,
  minSpan = 0.035,
} = {}) {
  let lastSpan = null
  let lastT = 0
  let armedAt = 0
  let smoothRate = 0

  return {
    /** lm: hand landmarks, t: milliseconds. */
    update(lm, t) {
      if (!lm) {
        lastSpan = null
        return { punching: false, power: 0, rate: 0 }
      }
      const span = handSpan(lm)
      if (lastSpan === null) {
        lastSpan = span
        lastT = t
        return { punching: false, power: 0, rate: 0 }
      }
      let dt = (t - lastT) / 1000
      if (!(dt > 0) || dt > 0.2) dt = 1 / 60
      // Relative growth, so a big hand and a small hand behave the same.
      const rate = (span - lastSpan) / (lastSpan * dt)
      smoothRate += (rate - smoothRate) * 0.45
      lastSpan = span
      lastT = t

      const ready = t - armedAt > cooldownMs
      const punching = ready && smoothRate > growthThreshold && span > minSpan
      if (punching) armedAt = t
      return {
        punching,
        power: Math.min(1, smoothRate / (growthThreshold * 2.2)),
        rate: smoothRate,
      }
    },
    reset() {
      lastSpan = null
      smoothRate = 0
      armedAt = 0
    },
  }
}

/** Both palms open and held high in front of you. */
export function isGuarding(hands) {
  const open = hands.filter((h) => h && h.lm && openness(h.lm) > 0.45)
  if (open.length < 2) return false
  return open.slice(0, 2).every((h) => palmCenter(h.lm).y < 0.62)
}

/** -1 (leaned left on screen) to +1 (right), from the shoulders. */
export function leanOf(poseLm, mirror) {
  if (!poseLm || !poseLm[11] || !poseLm[12]) return 0
  const cx = (poseLm[11].x + poseLm[12].x) / 2
  const sx = mirror ? 1 - cx : cx
  return Math.max(-1, Math.min(1, (sx - 0.5) * 3.4))
}

/** Crouch detection: the head drops relative to the hips. */
export function crouchOf(poseLm) {
  if (!poseLm || !poseLm[0] || !poseLm[23] || !poseLm[24]) return 0
  const hip = (poseLm[23].y + poseLm[24].y) / 2
  const gap = hip - poseLm[0].y
  // A standing adult shows roughly 0.4 of frame between head and hips.
  return Math.max(0, Math.min(1, (0.38 - gap) / 0.2))
}

/* ---------------------------------- NPCs ---------------------------------- */

export const NPC_KINDS = {
  grunt: { hp: 2, speed: 2.6, reach: 3.0, windup: 900, damage: 8, color: '#FF4D8D', size: 1 },
  brute: { hp: 5, speed: 1.7, reach: 3.6, windup: 1250, damage: 16, color: '#FF7A45', size: 1.35 },
  dart: { hp: 1, speed: 4.4, reach: 2.6, windup: 620, damage: 6, color: '#B6FF3C', size: 0.82 },
}

export function spawnNpc(kind, lane, z) {
  const k = NPC_KINDS[kind]
  return {
    kind,
    ...k,
    maxHp: k.hp,
    x: lane,
    z,
    state: 'approach',   // approach | windup | strike | stagger | dead
    stateAt: 0,
    flash: 0,
    bob: Math.random() * Math.PI * 2,
    dead: false,
  }
}

/**
 * One NPC's turn. Returns an event string when something happens that the game
 * needs to react to, so all the scoring and sound stays in the page.
 */
export function stepNpc(npc, dt, now, player) {
  npc.bob += dt * 4
  npc.flash = Math.max(0, npc.flash - dt * 3)

  if (npc.state === 'dead') {
    npc.z += dt * 6
    npc.fade = (npc.fade ?? 1) - dt * 1.6
    return npc.fade <= 0 ? 'gone' : null
  }

  if (npc.state === 'stagger') {
    npc.z += dt * 5
    if (now - npc.stateAt > 420) {
      npc.state = 'approach'
      npc.stateAt = now
    }
    return null
  }

  if (npc.state === 'approach') {
    npc.z -= dt * npc.speed
    // Drift toward the player so dodging actually matters.
    npc.x += Math.sign(player.x - npc.x) * Math.min(Math.abs(player.x - npc.x), dt * 0.9)
    if (npc.z <= npc.reach) {
      npc.state = 'windup'
      npc.stateAt = now
      return 'windup'
    }
    return null
  }

  if (npc.state === 'windup') {
    if (now - npc.stateAt > npc.windup) {
      npc.state = 'strike'
      npc.stateAt = now
      return 'strike'
    }
    return null
  }

  if (npc.state === 'strike') {
    if (now - npc.stateAt > 260) {
      npc.state = 'approach'
      npc.stateAt = now
      npc.z = npc.reach + 1.4
    }
    return null
  }
  return null
}

export function hitNpc(npc, damage, now) {
  if (npc.state === 'dead') return false
  npc.hp -= damage
  npc.flash = 1
  if (npc.hp <= 0) {
    npc.state = 'dead'
    npc.stateAt = now
    npc.fade = 1
    return true
  }
  npc.state = 'stagger'
  npc.stateAt = now
  return false
}

/** Wave composition: later waves get denser and meaner. */
export function buildWave(n) {
  const out = []
  const count = Math.min(9, 2 + Math.floor(n * 0.9))
  for (let i = 0; i < count; i++) {
    let kind = 'grunt'
    if (n >= 2 && i % 4 === 3) kind = 'brute'
    if (n >= 3 && i % 3 === 1) kind = 'dart'
    out.push({
      kind,
      lane: -2.6 + Math.random() * 5.2,
      z: 20 + i * (5 + Math.random() * 4),
    })
  }
  return out
}
HANDPLAY_EOF
mkdir -p src/lib
cat > src/lib/shapes.js <<'HANDPLAY_EOF'
// Recognising a shape drawn in the air.
//
// Template matchers need a stored library and are fussy about rotation and
// starting point. Air-drawn strokes are messy enough that a handful of robust
// geometric features separates the three spells far more reliably: how closed
// the stroke is, how far it turns in total, and how often it changes direction.

/**
 * A finger drawn through the air wobbles, and every wobble looks like a change
 * of direction to the turning measurement. Averaging over neighbouring samples
 * first removes the tremor while leaving the actual shape intact.
 */
function smoothPath(points, k = 2) {
  if (points.length < 5) return points
  const out = []
  for (let i = 0; i < points.length; i++) {
    let sx = 0, sy = 0, n = 0
    for (let j = Math.max(0, i - k); j <= Math.min(points.length - 1, i + k); j++) {
      sx += points[j].x
      sy += points[j].y
      n += 1
    }
    out.push({ x: sx / n, y: sy / n })
  }
  return out
}

function resample(points, n = 48) {
  if (points.length < 2) return points.slice()
  let total = 0
  for (let i = 1; i < points.length; i++) {
    total += Math.hypot(points[i].x - points[i - 1].x, points[i].y - points[i - 1].y)
  }
  if (total <= 0) return points.slice()
  const step = total / (n - 1)
  const out = [points[0]]
  let acc = 0
  let prev = points[0]
  for (let i = 1; i < points.length; i++) {
    let cur = points[i]
    let d = Math.hypot(cur.x - prev.x, cur.y - prev.y)
    while (acc + d >= step && out.length < n) {
      const t = (step - acc) / d
      const np = { x: prev.x + (cur.x - prev.x) * t, y: prev.y + (cur.y - prev.y) * t }
      out.push(np)
      prev = np
      d = Math.hypot(cur.x - prev.x, cur.y - prev.y)
      acc = 0
    }
    acc += d
    prev = cur
  }
  while (out.length < n) out.push(points[points.length - 1])
  return out
}

export function strokeFeatures(points) {
  // Fewer than this and there is no stroke to speak of — resampling a pair of
  // stray points would otherwise manufacture a convincing straight line.
  if (!points || points.length < 8) return null
  const pts = resample(smoothPath(points))
  if (pts.length < 8) return null

  let pathLen = 0
  for (let i = 1; i < pts.length; i++) {
    pathLen += Math.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y)
  }
  if (pathLen <= 1e-6) return null

  const gap = Math.hypot(pts[pts.length - 1].x - pts[0].x, pts[pts.length - 1].y - pts[0].y)
  const closure = gap / pathLen           // 0 = ends meet, high = open stroke

  let xmin = Infinity, xmax = -Infinity, ymin = Infinity, ymax = -Infinity
  for (const p of pts) {
    xmin = Math.min(xmin, p.x); xmax = Math.max(xmax, p.x)
    ymin = Math.min(ymin, p.y); ymax = Math.max(ymax, p.y)
  }
  const diag = Math.hypot(xmax - xmin, ymax - ymin) || 1e-6

  // Turning: signed angle change between consecutive segments.
  let totalTurn = 0
  let absTurn = 0
  let flips = 0
  let lastSign = 0
  for (let i = 1; i < pts.length - 1; i++) {
    const a1 = Math.atan2(pts[i].y - pts[i - 1].y, pts[i].x - pts[i - 1].x)
    const a2 = Math.atan2(pts[i + 1].y - pts[i].y, pts[i + 1].x - pts[i].x)
    let d = a2 - a1
    while (d > Math.PI) d -= Math.PI * 2
    while (d < -Math.PI) d += Math.PI * 2
    totalTurn += d
    absTurn += Math.abs(d)
    // Only count a genuine reversal, not shaky-hand noise.
    if (Math.abs(d) > 0.35) {
      const sign = Math.sign(d)
      if (lastSign !== 0 && sign !== lastSign) flips += 1
      lastSign = sign
    }
  }

  // How far the stroke swings away from the straight line joining its ends.
  // This is what separates a real zigzag from a shaky line: both change
  // direction repeatedly, but only the zigzag travels a long way off the chord.
  let waviness = 0
  {
    const ax = pts[0].x, ay = pts[0].y
    const bx = pts[pts.length - 1].x, by = pts[pts.length - 1].y
    const cx = bx - ax, cy = by - ay
    const chord = Math.hypot(cx, cy)
    if (chord > 1e-6) {
      let sum = 0
      for (const p of pts) sum += Math.abs((p.x - ax) * cy - (p.y - ay) * cx) / chord
      waviness = sum / pts.length / chord
    }
  }

  return {
    pathLen,
    closure,
    waviness,
    straightness: gap / diag,
    totalTurn: Math.abs(totalTurn),
    absTurn,
    flips,
    diag,
    size: diag,
  }
}

/**
 * Classifies a stroke as one of the three spells.
 * Returns { name, confidence } where name is 'circle' | 'bolt' | 'zigzag' | null.
 */
export function recognizeShape(points, { minSize = 0.06 } = {}) {
  const f = strokeFeatures(points)
  if (!f) return { name: null, confidence: 0, reason: 'too short' }
  if (f.size < minSize) return { name: null, confidence: 0, reason: 'too small' }

  // A zigzag reverses direction repeatedly — check it first, because a scribble
  // can accidentally satisfy the loose end of the circle test.
  if (f.flips >= 3 && f.closure > 0.18 && f.waviness > 0.07) {
    return { name: 'zigzag', confidence: Math.min(1, 0.45 + f.flips * 0.14) }
  }

  // A circle comes back to where it started having turned a full revolution.
  if (f.closure < 0.30 && f.totalTurn > 4.2 && f.flips <= 2) {
    const turnFit = 1 - Math.min(1, Math.abs(f.totalTurn - Math.PI * 2) / Math.PI)
    return { name: 'circle', confidence: Math.max(0.45, turnFit) }
  }

  // A bolt is a straight, open stroke that barely turns at all.
  if (f.straightness > 0.68 && f.waviness < 0.07) {
    return { name: 'bolt', confidence: Math.min(1, f.straightness) }
  }

  return { name: null, confidence: 0, reason: 'unclear' }
}

export const SPELLS = {
  bolt: {
    label: 'Bolt', color: '#00D4FF', damage: 2, cost: 0,
    hint: 'Draw a straight line',
  },
  circle: {
    label: 'Ward', color: '#00E5B0', damage: 0, cost: 0,
    hint: 'Draw a circle',
  },
  zigzag: {
    label: 'Chain', color: '#FFB000', damage: 1, cost: 0,
    hint: 'Draw a zigzag',
  },
}
HANDPLAY_EOF
mkdir -p src/components
cat > src/components/ui.jsx <<'HANDPLAY_EOF'
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
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Home.jsx <<'HANDPLAY_EOF'
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
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Dojo.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { palmCenter, openness, handSpan, HAND_CONNECTIONS } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { createPunchDetector, spawnNpc, stepNpc, hitNpc, buildWave } from '../lib/combat.js'
import { createCamera, drawFloorGrid, drawCorridor, drawGroundShadow, fogAlpha, byDepth } from '../lib/scene3d.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'
import { limb, lighten, darken } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ACCENT = '#FF4D8D'
const MAX_HP = 100
const FLOOR_Y = 3.0

export default function Dojo() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 2,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', hp: MAX_HP, wave: 0, score: 0, combo: 0, kills: 0 })

  const g = useRef({
    phase: 'menu',
    cam: createCamera({ parallax: 1.2 }),
    bloom: createBloom(0.5),
    tracker: createTracker({ maxDist: 0.3, maxAge: 400 }),
    punch: [createPunchDetector(), createPunchDetector()],
    npcs: [],
    hits: [],
    wave: 0,
    waveAt: 0,
    hp: MAX_HP,
    score: 0,
    kills: 0,
    combo: 0,
    comboAt: 0,
    guard: 0,
    playerX: 0,
    hurt: 0,
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    Object.assign(g, {
      phase: 'fighting', npcs: [], hits: [], wave: 0, waveAt: 0,
      hp: MAX_HP, score: 0, kills: 0, combo: 0, guard: 0, playerX: 0, hurt: 0, logged: false,
    })
    g.cam.reset()
    g.punch.forEach((p) => p.reset())
    nextWave(performance.now())
    playMusic('dance')
  }

  function nextWave(now) {
    g.wave += 1
    g.waveAt = now
    for (const s of buildWave(g.wave)) g.npcs.push(spawnNpc(s.kind, s.lane, s.z))
    sfx.whoosh()
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
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now).slice(0, 2)

      // Hands drive the camera as well as the fists: moving bodily left shifts
      // the viewpoint, which is what makes the arena feel like a real space.
      if (tracks.length) {
        const avgX = tracks.reduce((a, t) => a + t.x, 0) / tracks.length
        const avgY = tracks.reduce((a, t) => a + t.y, 0) / tracks.length
        g.cam.track(avgX, avgY, dt)
        g.playerX = (avgX - 0.5) * 5
      } else {
        g.cam.track(0.5, 0.55, dt)
      }

      const hands = tracks.map((t) => ({ ...t, lm: t.data }))
      const openCount = hands.filter((h) => h.lm && openness(h.lm) > 0.45).length
      g.guard = openCount >= 2 ? Math.min(1, g.guard + dt * 6) : Math.max(0, g.guard - dt * 5)

      if (g.phase === 'fighting') runFight(dt, now, hands)
      draw(ctx, W, H, dt, now, hands)
      sync()
    }

    function runFight(dt, now, hands) {
      // Punches
      hands.forEach((h, i) => {
        const det = g.punch[i]
        if (!det) return
        const r = det.update(h.lm, now)
        if (r.punching && g.guard < 0.5) throwPunch(h, now, r.power)
      })
      // Detectors for hands that vanished must forget their history.
      for (let i = hands.length; i < g.punch.length; i++) g.punch[i].reset()

      const player = { x: g.playerX }
      for (const npc of [...g.npcs]) {
        const ev = stepNpc(npc, dt, now, player)
        if (ev === 'strike') resolveEnemyStrike(npc, now)
        if (ev === 'windup') sfx.tick()
        if (ev === 'gone') g.npcs = g.npcs.filter((n) => n !== npc)
      }

      for (const h of g.hits) h.life -= dt * 1.8
      g.hits = g.hits.filter((h) => h.life > 0)
      g.hurt = Math.max(0, g.hurt - dt * 1.6)

      if (now - g.comboAt > 2600 && g.combo) g.combo = 0

      const alive = g.npcs.filter((n) => n.state !== 'dead')
      if (!alive.length && now - g.waveAt > 900) nextWave(now)

      if (g.hp <= 0) {
        g.hp = 0
        g.phase = 'over'
        stopMusic()
        sfx.lose()
        if (!g.logged) {
          g.logged = true
          addSession({ game: 'dojo', score: g.score, detail: `wave ${g.wave} · ${g.kills} downed` })
        }
      }
    }

    function throwPunch(hand, now, power) {
      // The nearest enemy inside arm's reach, roughly in front of that fist.
      const aimX = (hand.x - 0.5) * 6
      let best = null
      let bestZ = Infinity
      for (const npc of g.npcs) {
        if (npc.state === 'dead') continue
        if (npc.z > 4.6) continue
        if (Math.abs(npc.x - aimX) > 2.4) continue
        if (npc.z < bestZ) { bestZ = npc.z; best = npc }
      }
      if (!best) {
        sfx.whoosh()
        return
      }
      const dmg = 1 + (power > 0.75 ? 1 : 0)
      const killed = hitNpc(best, dmg, now)
      g.combo += 1
      g.comboAt = now
      g.score += (killed ? 120 : 40) + Math.min(g.combo, 12) * 10
      g.cam.kick(killed ? 0.9 : 0.5)
      g.hits.push({ x: best.x, z: best.z, life: 1, killed, power })
      if (killed) { g.kills += 1; sfx.crash() } else sfx.shot()
      if (g.combo > 1) sfx.combo(g.combo)
    }

    function resolveEnemyStrike(npc, now) {
      const dodged = Math.abs(npc.x - g.playerX) > 1.9
      if (dodged) { sfx.whoosh(); return }
      if (g.guard > 0.5) {
        g.hp -= Math.round(npc.damage * 0.25)
        g.cam.kick(0.4)
        sfx.ricochet()
      } else {
        g.hp -= npc.damage
        g.hurt = 1
        g.combo = 0
        g.cam.kick(1.1)
        sfx.miss()
      }
    }

    /* ------------------------------ rendering ----------------------------- */

    function draw(ctx, W, H, dt, now, hands) {
      const cam = g.cam
      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#12061F')
      sky.addColorStop(0.55, '#1E0A2E')
      sky.addColorStop(1, '#07040F')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.14,
          grade: 'grayscale(0.9) brightness(0.4) contrast(1.3)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const layers = bctx ? [ctx, bctx] : [ctx]

      for (const c of layers) {
        drawCorridor(c, cam, W, H, { radius: 7.5, spacing: 5, count: 11, color: '#7C5CFF', roll: now * 0.00008 })
        drawFloorGrid(c, cam, W, H, { y: FLOOR_Y, depth: 48, step: 3.5, color: ACCENT })
      }

      // Far to near so nearer fighters occlude the ones behind them.
      const order = [...g.npcs].sort(byDepth)
      for (const npc of order) {
        drawGroundShadow(ctx, cam, W, H, npc.x, npc.z, npc.size * 2.2, FLOOR_Y)
        for (const c of layers) drawFighter(c, cam, W, H, npc, now)
      }

      for (const h of g.hits) for (const c of layers) drawImpact(c, cam, W, H, h)
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 12, alpha: 0.6 })

      if (g.guard > 0.05) drawGuard(ctx, W, H, g.guard, now)
      drawFists(ctx, W, H, hands)
      drawVignette(ctx, W, H, 0.55)

      if (g.hurt > 0) {
        ctx.save()
        ctx.globalAlpha = g.hurt * 0.45
        const v = ctx.createRadialGradient(W / 2, H / 2, Math.min(W, H) * 0.25, W / 2, H / 2, Math.max(W, H) * 0.7)
        v.addColorStop(0, 'rgba(255,0,60,0)')
        v.addColorStop(1, 'rgba(255,0,60,1)')
        ctx.fillStyle = v
        ctx.fillRect(0, 0, W, H)
        ctx.restore()
      }
      if (g.phase === 'fighting') drawHud(ctx, W, H, now)
    }

    function drawFighter(ctx, cam, W, H, npc, now) {
      const head = cam.project({ x: npc.x, y: FLOOR_Y - 2.5 * npc.size, z: npc.z }, W, H)
      const foot = cam.project({ x: npc.x, y: FLOOR_Y, z: npc.z }, W, H)
      if (!head || !foot) return
      const a = fogAlpha(npc.z, 6, 40) * (npc.fade ?? 1)
      if (a <= 0.02) return

      const h = foot.y - head.y
      if (h < 4) return
      const unit = h / 7
      const cx = head.x
      const wind = npc.state === 'windup'
        ? Math.min(1, (now - npc.stateAt) / npc.windup)
        : 0
      const striking = npc.state === 'strike'
      const bob = Math.sin(npc.bob) * unit * 0.16
      const col = npc.flash > 0.1 ? '#FFFFFF' : npc.color

      ctx.save()
      ctx.globalAlpha = a
      if (npc.state === 'dead') ctx.globalAlpha = a * 0.7

      const shoulderY = head.y + unit * 1.5 + bob
      const hipY = head.y + unit * 4 + bob
      const sw = unit * 1.15
      const lS = { x: cx - sw, y: shoulderY }
      const rS = { x: cx + sw, y: shoulderY }
      const lH = { x: cx - sw * 0.7, y: hipY }
      const rH = { x: cx + sw * 0.7, y: hipY }

      // Legs
      limb(ctx, lH, { x: cx - sw * 0.8, y: foot.y }, unit * 0.34, unit * 0.22, darken(col, 0.5))
      limb(ctx, rH, { x: cx + sw * 0.8, y: foot.y }, unit * 0.34, unit * 0.22, darken(col, 0.5))

      // Torso
      ctx.beginPath()
      ctx.moveTo(lS.x, lS.y); ctx.lineTo(rS.x, rS.y); ctx.lineTo(rH.x, rH.y); ctx.lineTo(lH.x, lH.y)
      ctx.closePath()
      const tg = ctx.createLinearGradient(0, shoulderY, 0, hipY)
      tg.addColorStop(0, lighten(col, 0.15))
      tg.addColorStop(1, darken(col, 0.4))
      ctx.fillStyle = tg
      ctx.fill()

      // Arms — one cocks back on the windup, then drives at the camera.
      const reach = striking ? 1.5 : wind * -0.6
      const armEnd = { x: cx + sw * 2.1, y: shoulderY + unit * (1.4 - reach * 1.2) }
      const armEndL = { x: cx - sw * 1.5, y: shoulderY + unit * 1.7 }
      limb(ctx, rS, armEnd, unit * 0.3, unit * (striking ? 0.6 : 0.22), lighten(col, 0.1))
      limb(ctx, lS, armEndL, unit * 0.3, unit * 0.2, darken(col, 0.25))

      // Head
      ctx.fillStyle = lighten(col, 0.25)
      ctx.beginPath()
      ctx.arc(cx, head.y + unit * 0.7 + bob, unit * 0.75, 0, Math.PI * 2)
      ctx.fill()
      ctx.fillStyle = '#0A0A12'
      ctx.beginPath()
      ctx.ellipse(cx, head.y + unit * 0.65 + bob, unit * 0.5, unit * 0.2, 0, 0, Math.PI * 2)
      ctx.fill()

      // Health pip
      if (npc.state !== 'dead' && npc.hp < npc.maxHp) {
        const bw = unit * 2.4
        ctx.fillStyle = 'rgba(0,0,0,0.5)'
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.6, bw, unit * 0.28)
        ctx.fillStyle = col
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.6, bw * (npc.hp / npc.maxHp), unit * 0.28)
      }

      // Windup telegraph — the player needs a readable warning.
      if (wind > 0.15) {
        ctx.strokeStyle = `rgba(255,80,80,${0.3 + wind * 0.6})`
        ctx.lineWidth = 2 + wind * 3
        ctx.beginPath()
        ctx.arc(cx, (shoulderY + hipY) / 2, unit * (2.4 + wind * 1.6), 0, Math.PI * 2)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawImpact(ctx, cam, W, H, hit) {
      const p = cam.project({ x: hit.x, y: FLOOR_Y - 1.6, z: hit.z }, W, H)
      if (!p) return
      const r = (1 - hit.life) * 90 * p.s * 0.1 + 18
      ctx.save()
      ctx.globalAlpha = hit.life
      ctx.strokeStyle = hit.killed ? '#FFFFFF' : '#FFD36E'
      ctx.lineWidth = 4 * hit.life
      ctx.beginPath()
      ctx.arc(p.x, p.y, r, 0, Math.PI * 2)
      ctx.stroke()
      for (let i = 0; i < 8; i++) {
        const a = (i / 8) * Math.PI * 2
        ctx.beginPath()
        ctx.moveTo(p.x + Math.cos(a) * r, p.y + Math.sin(a) * r)
        ctx.lineTo(p.x + Math.cos(a) * r * 1.5, p.y + Math.sin(a) * r * 1.5)
        ctx.stroke()
      }
      ctx.restore()
    }

    function drawGuard(ctx, W, H, amount, now) {
      ctx.save()
      ctx.globalAlpha = amount * 0.55
      const g2 = ctx.createRadialGradient(W / 2, H * 0.6, 40, W / 2, H * 0.6, Math.max(W, H) * 0.55)
      g2.addColorStop(0, 'rgba(0,229,176,0)')
      g2.addColorStop(0.75, 'rgba(0,229,176,0.22)')
      g2.addColorStop(1, 'rgba(0,229,176,0.5)')
      ctx.fillStyle = g2
      ctx.fillRect(0, 0, W, H)
      ctx.strokeStyle = `rgba(140,255,225,${0.3 + Math.sin(now * 0.01) * 0.15})`
      ctx.lineWidth = 3
      ctx.beginPath()
      ctx.ellipse(W / 2, H * 0.6, W * 0.42, H * 0.46, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()
    }

    function drawFists(ctx, W, H, hands) {
      for (const h of hands) {
        if (!h.lm) continue
        const lm = h.lm
        const pt = (k) => ({
          x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
          y: lm[k].y * H,
        })
        const span = handSpan(lm)
        const near = Math.min(1, Math.max(0, (span - 0.06) / 0.12))
        ctx.save()
        ctx.globalAlpha = 0.55 + near * 0.45
        ctx.strokeStyle = openness(lm) > 0.45 ? '#00E5B0' : '#FFD36E'
        ctx.lineWidth = 3 + near * 5
        ctx.lineCap = 'round'
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

    function drawHud(ctx, W, H, now) {
      ctx.save()
      // Health
      const bw = Math.min(360, W * 0.4)
      ctx.fillStyle = 'rgba(255,255,255,0.12)'
      ctx.fillRect(24, 26, bw, 14)
      const frac = Math.max(0, g.hp / MAX_HP)
      ctx.fillStyle = frac > 0.5 ? '#00E5B0' : frac > 0.25 ? '#FFB000' : '#FF4D8D'
      ctx.fillRect(24, 26, bw * frac, 14)
      ctx.strokeStyle = 'rgba(255,255,255,0.25)'
      ctx.lineWidth = 1
      ctx.strokeRect(24, 26, bw, 14)
      ctx.fillStyle = '#8A8AA0'
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillText('HEALTH', 24, 58)

      ctx.textAlign = 'right'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 34px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(g.score), W - 24, 46)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`WAVE ${g.wave}`, W - 24, 66)

      if (g.combo > 1) {
        ctx.textAlign = 'center'
        ctx.fillStyle = '#FFD36E'
        ctx.font = '700 26px "Space Grotesk", system-ui, sans-serif'
        ctx.fillText(`${g.combo} HIT`, W / 2, 48)
      }
      ctx.restore()
    }

    let lastKey = ''
    function sync() {
      const next = { phase: g.phase, hp: Math.max(0, g.hp), wave: g.wave, score: g.score, combo: g.combo, kills: g.kills }
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
      {loading && <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="They come to you · you are the camera" accent={ACCENT}>Shadow Dojo</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="fist" title="Punch the air toward the lens" body="A fist thrown at the camera lands on whatever is in front of it. Fast, committed jabs hit hardest." delay={80} />
            <HowTo glyph="openPalm" title="Both palms up to guard" body="Blocks most of the damage, but you cannot punch while guarding." delay={160} />
            <HowTo glyph="wave" title="Move sideways to dodge" body="Step out of a fighter's line and the strike misses completely. The room moves with you." delay={240} />
          </div>
          <p className="text-white/65 mb-7 text-center max-w-md text-sm">
            A red ring means someone is about to swing. Waves get bigger and the brutes take more
            than one clean hit.
          </p>
          <Button accent={ACCENT} onClick={start}>Enter the dojo</Button>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">You went down</p>
          <div className="font-display text-7xl font-700 mb-2 animate-pop" style={{ color: ACCENT }}>
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">Wave {ui.wave} · {ui.kills} fighters downed</p>
          <Button accent={ACCENT} onClick={start}>Back in</Button>
        </Screen>
      )}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Rift.jsx <<'HANDPLAY_EOF'
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
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Arcane.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { palmCenter, isPointing, HAND_CONNECTIONS } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { spawnNpc, stepNpc, hitNpc, buildWave } from '../lib/combat.js'
import { recognizeShape, SPELLS } from '../lib/shapes.js'
import { createCamera, drawFloorGrid, drawGroundShadow, fogAlpha, byDepth } from '../lib/scene3d.js'
import { useCanvasSize, logicalSize } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'
import { limb, lighten, darken, withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

const ACCENT = '#B06BFF'
const MAX_HP = 100
const FLOOR_Y = 3.0
const MAX_STROKE = 90

export default function Arcane() {
  const settings = useRef(loadSettings()).current
  const { videoRef, status, error, detect } = useVision({
    task: 'hand',
    numHands: 2,
    sensitivity: settings.sensitivity,
  })

  const canvasRef = useRef(null)
  useCanvasSize(canvasRef)
  const [ui, setUi] = useState({ phase: 'menu', hp: MAX_HP, score: 0, wave: 0, spell: '', ward: 0 })

  const g = useRef({
    phase: 'menu',
    cam: createCamera({ parallax: 1.1 }),
    bloom: createBloom(0.5),
    tracker: createTracker({ maxDist: 0.3, maxAge: 350 }),
    stroke: [],
    drawing: false,
    lastCast: null,
    lastCastAt: 0,
    npcs: [],
    bolts: [],
    ward: 0,
    wardUntil: 0,
    hp: MAX_HP,
    score: 0,
    wave: 0,
    waveAt: 0,
    hurt: 0,
    runes: [],
    lastTime: 0,
    logged: false,
  }).current

  function start() {
    Object.assign(g, {
      phase: 'casting', stroke: [], drawing: false, lastCast: null, npcs: [], bolts: [],
      ward: 0, wardUntil: 0, hp: MAX_HP, score: 0, wave: 0, waveAt: 0, hurt: 0, runes: [], logged: false,
    })
    g.cam.reset()
    nextWave(performance.now())
    playMusic('space')
  }

  function nextWave(now) {
    g.wave += 1
    g.waveAt = now
    for (const s of buildWave(g.wave)) g.npcs.push(spawnNpc(s.kind, s.lane, s.z + 12))
    sfx.whoosh()
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
      const list = res && res.landmarks ? res.landmarks : []
      const points = list.map((lm) => {
        const c = palmCenter(lm)
        return { x: settings.mirror ? 1 - c.x : c.x, y: c.y, data: lm }
      })
      g.tracker.update(points, now)
      const tracks = g.tracker.live(now).slice(0, 2)
      const hands = tracks.map((t) => ({ ...t, lm: t.data }))

      if (hands.length) {
        const avg = hands.reduce((a, h) => a + h.x, 0) / hands.length
        g.cam.track(avg, 0.5, dt)
      } else {
        g.cam.track(0.5, 0.55, dt)
      }

      if (g.phase === 'casting') {
        handleCasting(hands, now)
        step(dt, now)
      }
      draw(ctx, W, H, dt, now, hands)
      sync()
    }

    function handleCasting(hands, now) {
      // The first pointing hand is the wand. Pointing draws, anything else
      // releases the stroke and casts whatever was drawn.
      const wand = hands.find((h) => h.lm && isPointing(h.lm))
      if (wand) {
        const tip = wand.lm[8]
        const p = { x: settings.mirror ? 1 - tip.x : tip.x, y: tip.y }
        if (!g.drawing) {
          g.drawing = true
          g.stroke = []
          sfx.penDown()
        }
        const last = g.stroke[g.stroke.length - 1]
        if (!last || Math.hypot(p.x - last.x, p.y - last.y) > 0.004) g.stroke.push(p)
        if (g.stroke.length > MAX_STROKE) g.stroke.shift()
      } else if (g.drawing) {
        g.drawing = false
        cast(g.stroke, now)
        g.stroke = []
      }
    }

    function cast(stroke, now) {
      const r = recognizeShape(stroke)
      if (!r.name) {
        g.lastCast = { name: null, label: 'fizzled', color: '#8A8AA0' }
        g.lastCastAt = now
        sfx.back()
        return
      }
      const spell = SPELLS[r.name]
      g.lastCast = { name: r.name, label: spell.label, color: spell.color }
      g.lastCastAt = now

      if (r.name === 'circle') {
        g.ward = 1
        g.wardUntil = now + 5000
        sfx.bank(1)
        g.runes.push({ kind: 'circle', life: 1, color: spell.color })
        return
      }

      const targets = [...g.npcs]
        .filter((n) => n.state !== 'dead')
        .sort((a, b) => a.z - b.z)

      if (!targets.length) { sfx.whoosh(); return }

      if (r.name === 'bolt') {
        const t = targets[0]
        g.bolts.push({ to: t, life: 1, color: spell.color, chain: false })
        applyDamage(t, spell.damage, now)
        sfx.shot()
      } else if (r.name === 'zigzag') {
        // Chain arcs through up to three of them.
        const chain = targets.slice(0, 3)
        chain.forEach((t, i) => {
          g.bolts.push({ to: t, from: i ? chain[i - 1] : null, life: 1, color: spell.color, chain: true })
          applyDamage(t, spell.damage, now)
        })
        sfx.ricochet()
      }
      g.runes.push({ kind: r.name, life: 1, color: spell.color })
    }

    function applyDamage(npc, dmg, now) {
      const killed = hitNpc(npc, dmg, now)
      g.score += killed ? 150 : 45
      g.cam.kick(killed ? 0.7 : 0.35)
      if (killed) sfx.crash()
    }

    function step(dt, now) {
      if (g.ward && now > g.wardUntil) g.ward = 0
      const player = { x: 0 }
      for (const npc of [...g.npcs]) {
        const ev = stepNpc(npc, dt, now, player)
        if (ev === 'strike') {
          if (g.ward) {
            g.ward = 0
            g.cam.kick(0.6)
            sfx.ricochet()
          } else {
            g.hp -= npc.damage
            g.hurt = 1
            g.cam.kick(1)
            sfx.miss()
          }
        }
        if (ev === 'gone') g.npcs = g.npcs.filter((n) => n !== npc)
      }

      for (const b of g.bolts) b.life -= dt * 2.6
      g.bolts = g.bolts.filter((b) => b.life > 0)
      for (const r of g.runes) r.life -= dt * 1.2
      g.runes = g.runes.filter((r) => r.life > 0)
      g.hurt = Math.max(0, g.hurt - dt * 1.6)

      const alive = g.npcs.filter((n) => n.state !== 'dead')
      if (!alive.length && now - g.waveAt > 900) nextWave(now)

      if (g.hp <= 0) {
        g.hp = 0
        g.phase = 'over'
        stopMusic()
        sfx.lose()
        if (!g.logged) {
          g.logged = true
          addSession({ game: 'arcane', score: g.score, detail: `wave ${g.wave}` })
        }
      }
    }

    /* ------------------------------ rendering ----------------------------- */

    function draw(ctx, W, H, dt, now, hands) {
      const cam = g.cam
      const sky = ctx.createLinearGradient(0, 0, 0, H)
      sky.addColorStop(0, '#0B0524')
      sky.addColorStop(0.6, '#170A33')
      sky.addColorStop(1, '#05030E')
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, H)

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.13,
          grade: 'grayscale(0.9) brightness(0.4) contrast(1.3)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const layers = bctx ? [ctx, bctx] : [ctx]

      for (const c of layers) drawFloorGrid(c, cam, W, H, { y: FLOOR_Y, depth: 52, step: 4, color: ACCENT })

      for (const npc of [...g.npcs].sort(byDepth)) {
        drawGroundShadow(ctx, cam, W, H, npc.x, npc.z, npc.size * 2.2, FLOOR_Y)
        for (const c of layers) drawWraith(c, cam, W, H, npc, now)
      }
      for (const b of g.bolts) for (const c of layers) drawBolt(c, cam, W, H, b)
      if (g.ward) for (const c of layers) drawWard(c, W, H, now)
      for (const c of layers) drawStroke(c, W, H, now)
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 13, alpha: 0.65 })

      drawHands(ctx, W, H, hands)
      drawVignette(ctx, W, H, 0.55)

      if (g.hurt > 0) {
        ctx.save()
        ctx.globalAlpha = g.hurt * 0.4
        const v = ctx.createRadialGradient(W / 2, H / 2, Math.min(W, H) * 0.25, W / 2, H / 2, Math.max(W, H) * 0.7)
        v.addColorStop(0, 'rgba(255,0,60,0)')
        v.addColorStop(1, 'rgba(255,0,60,1)')
        ctx.fillStyle = v
        ctx.fillRect(0, 0, W, H)
        ctx.restore()
      }
      if (g.phase === 'casting') drawHud(ctx, W, H, now)
    }

    function drawWraith(ctx, cam, W, H, npc, now) {
      const head = cam.project({ x: npc.x, y: FLOOR_Y - 2.6 * npc.size, z: npc.z }, W, H)
      const foot = cam.project({ x: npc.x, y: FLOOR_Y, z: npc.z }, W, H)
      if (!head || !foot) return
      const a = fogAlpha(npc.z, 6, 46) * (npc.fade ?? 1)
      if (a <= 0.02) return
      const h = foot.y - head.y
      if (h < 4) return
      const unit = h / 7
      const cx = head.x
      const col = npc.flash > 0.1 ? '#FFFFFF' : npc.color
      const drift = Math.sin(npc.bob) * unit * 0.25

      ctx.save()
      ctx.globalAlpha = a * 0.92

      // A robed silhouette that tapers into smoke at the floor.
      const grd = ctx.createLinearGradient(0, head.y, 0, foot.y)
      grd.addColorStop(0, lighten(col, 0.2))
      grd.addColorStop(0.6, col)
      grd.addColorStop(1, withAlpha(darken(col, 0.6), 0))
      ctx.fillStyle = grd
      ctx.beginPath()
      ctx.moveTo(cx, head.y + drift)
      ctx.quadraticCurveTo(cx + unit * 1.9, head.y + unit * 3 + drift, cx + unit * 1.3, foot.y)
      ctx.quadraticCurveTo(cx, foot.y + unit * 0.4, cx - unit * 1.3, foot.y)
      ctx.quadraticCurveTo(cx - unit * 1.9, head.y + unit * 3 + drift, cx, head.y + drift)
      ctx.closePath()
      ctx.fill()

      // Hood and eyes
      ctx.fillStyle = '#0A0716'
      ctx.beginPath()
      ctx.ellipse(cx, head.y + unit * 1.1 + drift, unit * 0.85, unit * 0.95, 0, 0, Math.PI * 2)
      ctx.fill()
      const wind = npc.state === 'windup' ? Math.min(1, (now - npc.stateAt) / npc.windup) : 0
      ctx.fillStyle = wind > 0.1 ? '#FF4040' : '#FFE9A8'
      for (const s of [-1, 1]) {
        ctx.beginPath()
        ctx.ellipse(cx + s * unit * 0.32, head.y + unit * 1.05 + drift, unit * 0.16, unit * 0.1, 0, 0, Math.PI * 2)
        ctx.fill()
      }

      // Arms reach out on the windup
      if (wind > 0.1 || npc.state === 'strike') {
        const ext = npc.state === 'strike' ? 1 : wind
        for (const s of [-1, 1]) {
          limb(ctx,
            { x: cx + s * unit * 1.1, y: head.y + unit * 2.4 + drift },
            { x: cx + s * unit * (1.6 + ext * 1.4), y: head.y + unit * (2.6 - ext * 0.8) + drift },
            unit * 0.26, unit * 0.16, lighten(col, 0.3))
        }
        ctx.strokeStyle = `rgba(255,70,70,${0.25 + wind * 0.6})`
        ctx.lineWidth = 2 + wind * 3
        ctx.beginPath()
        ctx.arc(cx, head.y + unit * 2.8 + drift, unit * (2.2 + wind * 1.5), 0, Math.PI * 2)
        ctx.stroke()
      }

      if (npc.state !== 'dead' && npc.hp < npc.maxHp) {
        const bw = unit * 2.4
        ctx.fillStyle = 'rgba(0,0,0,0.5)'
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.8, bw, unit * 0.26)
        ctx.fillStyle = col
        ctx.fillRect(cx - bw / 2, head.y - unit * 0.8, bw * (npc.hp / npc.maxHp), unit * 0.26)
      }
      ctx.restore()
    }

    function drawBolt(ctx, cam, W, H, b) {
      const t = b.to
      if (!t) return
      const p = cam.project({ x: t.x, y: FLOOR_Y - 1.6, z: Math.max(1, t.z) }, W, H)
      if (!p) return
      const from = b.from
        ? cam.project({ x: b.from.x, y: FLOOR_Y - 1.6, z: Math.max(1, b.from.z) }, W, H)
        : { x: W / 2, y: H * 0.82 }
      if (!from) return

      ctx.save()
      ctx.globalAlpha = b.life
      ctx.strokeStyle = b.color
      ctx.lineWidth = 3 + b.life * 4
      ctx.lineCap = 'round'
      ctx.beginPath()
      ctx.moveTo(from.x, from.y)
      // A jagged path reads as energy rather than a drawn line.
      const segs = 7
      for (let i = 1; i <= segs; i++) {
        const f = i / segs
        const jx = (Math.random() - 0.5) * 26 * (1 - Math.abs(f - 0.5) * 2) * b.life
        const jy = (Math.random() - 0.5) * 26 * (1 - Math.abs(f - 0.5) * 2) * b.life
        ctx.lineTo(from.x + (p.x - from.x) * f + jx, from.y + (p.y - from.y) * f + jy)
      }
      ctx.stroke()
      ctx.restore()
    }

    function drawWard(ctx, W, H, now) {
      ctx.save()
      const pulse = 0.5 + Math.sin(now * 0.005) * 0.5
      ctx.globalAlpha = 0.35 + pulse * 0.25
      ctx.strokeStyle = SPELLS.circle.color
      ctx.lineWidth = 4
      ctx.beginPath()
      ctx.ellipse(W / 2, H * 0.58, W * 0.36, H * 0.4, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.globalAlpha = 0.12 + pulse * 0.08
      const gg = ctx.createRadialGradient(W / 2, H * 0.58, 30, W / 2, H * 0.58, W * 0.4)
      gg.addColorStop(0, 'rgba(0,229,176,0)')
      gg.addColorStop(1, 'rgba(0,229,176,0.7)')
      ctx.fillStyle = gg
      ctx.fillRect(0, 0, W, H)
      ctx.restore()
    }

    function drawStroke(ctx, W, H, now) {
      if (g.stroke.length < 2) return
      ctx.save()
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      for (let i = 1; i < g.stroke.length; i++) {
        const a = i / g.stroke.length
        const p0 = g.stroke[i - 1]
        const p1 = g.stroke[i]
        ctx.globalAlpha = a
        ctx.strokeStyle = ACCENT
        ctx.lineWidth = 2 + a * 7
        ctx.beginPath()
        ctx.moveTo(p0.x * W, p0.y * H)
        ctx.lineTo(p1.x * W, p1.y * H)
        ctx.stroke()
      }
      const tip = g.stroke[g.stroke.length - 1]
      ctx.globalAlpha = 1
      ctx.fillStyle = '#FFFFFF'
      ctx.beginPath()
      ctx.arc(tip.x * W, tip.y * H, 5, 0, Math.PI * 2)
      ctx.fill()
      ctx.restore()
    }

    function drawHands(ctx, W, H, hands) {
      for (const h of hands) {
        if (!h.lm) continue
        const lm = h.lm
        const pt = (k) => ({
          x: (settings.mirror ? 1 - lm[k].x : lm[k].x) * W,
          y: lm[k].y * H,
        })
        ctx.save()
        ctx.globalAlpha = 0.4
        ctx.strokeStyle = isPointing(lm) ? ACCENT : '#8A8AA0'
        ctx.lineWidth = 2.5
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

    function drawHud(ctx, W, H, now) {
      ctx.save()
      const bw = Math.min(340, W * 0.36)
      ctx.fillStyle = 'rgba(255,255,255,0.12)'
      ctx.fillRect(24, 26, bw, 14)
      const frac = Math.max(0, g.hp / MAX_HP)
      ctx.fillStyle = frac > 0.5 ? '#00E5B0' : frac > 0.25 ? '#FFB000' : '#FF4D8D'
      ctx.fillRect(24, 26, bw * frac, 14)
      ctx.fillStyle = '#8A8AA0'
      ctx.font = '500 11px Inter, system-ui, sans-serif'
      ctx.fillText('LIFE', 24, 58)

      ctx.textAlign = 'right'
      ctx.fillStyle = '#EAEAF2'
      ctx.font = '600 32px "Space Grotesk", system-ui, sans-serif'
      ctx.fillText(String(g.score), W - 24, 46)
      ctx.font = '500 12px Inter, system-ui, sans-serif'
      ctx.fillStyle = '#8A8AA0'
      ctx.fillText(`WAVE ${g.wave}`, W - 24, 66)

      // What you just cast, so a fizzle is never a mystery.
      if (g.lastCast && now - g.lastCastAt < 1400) {
        const a = 1 - (now - g.lastCastAt) / 1400
        ctx.globalAlpha = a
        ctx.textAlign = 'center'
        ctx.fillStyle = g.lastCast.color
        ctx.font = '700 30px "Space Grotesk", system-ui, sans-serif'
        ctx.fillText(g.lastCast.label.toUpperCase(), W / 2, H * 0.3)
        ctx.globalAlpha = 1
      }

      // Spellbook along the bottom.
      ctx.textAlign = 'center'
      const book = [['line', 'Bolt', SPELLS.bolt.color], ['circle', 'Ward', SPELLS.circle.color], ['zigzag', 'Chain', SPELLS.zigzag.color]]
      book.forEach((b, i) => {
        const x = W / 2 + (i - 1) * 150
        const y = H - 40
        ctx.strokeStyle = b[2]
        ctx.globalAlpha = 0.85
        ctx.lineWidth = 2.5
        ctx.beginPath()
        if (b[0] === 'line') { ctx.moveTo(x - 22, y + 6); ctx.lineTo(x + 22, y - 6) }
        else if (b[0] === 'circle') { ctx.arc(x, y, 15, 0, Math.PI * 2) }
        else {
          ctx.moveTo(x - 24, y)
          for (let k = 1; k <= 4; k++) ctx.lineTo(x - 24 + k * 12, y + (k % 2 ? -9 : 9))
        }
        ctx.stroke()
        ctx.globalAlpha = 0.65
        ctx.fillStyle = b[2]
        ctx.font = '600 11px Inter, system-ui, sans-serif'
        ctx.fillText(b[1], x, y + 32)
      })
      ctx.restore()
    }

    let lastKey = ''
    function sync() {
      const next = {
        phase: g.phase, hp: Math.max(0, g.hp), score: g.score, wave: g.wave,
        spell: g.lastCast ? g.lastCast.label : '', ward: g.ward,
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
      {loading && <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Write the shape · release the spell" accent={ACCENT}>Arcane</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="point" title="Point to draw" body="Your fingertip leaves a trail in the air. Lower your hand or open it to release and cast." delay={80} />
            <HowTo glyph="gun" title="A straight line is a Bolt" body="Strikes the nearest wraith hard. Any direction works." delay={160} />
            <HowTo glyph="openPalm" title="A circle is a Ward" body="Raises a shield that absorbs the next strike aimed at you." delay={240} />
            <HowTo glyph="wave" title="A zigzag is a Chain" body="Arcs through up to three wraiths at once — best when they cluster." delay={320} />
          </div>
          <Button accent={ACCENT} onClick={start}>Begin the rite</Button>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Overwhelmed</p>
          <div className="font-display text-7xl font-700 mb-2 animate-pop" style={{ color: ACCENT }}>
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">Survived to wave {ui.wave}</p>
          <Button accent={ACCENT} onClick={start}>Cast again</Button>
        </Screen>
      )}
    </div>
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
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

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
    bloom: createBloom(0.5),
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
    playMusic('space')
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
            stopMusic()
            sfx.win()
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
              sfx.grab()
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
            sfx.release()
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
          sfx.bank(g.banked)
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

      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror, alpha: 0.16,
          grade: 'grayscale(0.9) brightness(0.45) contrast(1.2)',
        })
      }

      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      drawGoal(ctx, goal, now)
      if (bctx) drawGoal(bctx, goal, now)

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

      for (const o of g.orbs) { drawOrb(ctx, o, now); if (bctx) drawOrb(bctx, o, now) }
      for (const h of hands) { drawHand(ctx, h, W, H, now); if (bctx) drawHand(bctx, h, W, H, now) }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 13, alpha: 0.6 })
      drawVignette(ctx, W, H, 0.45)

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
  const ACCENT = '#00E5B0'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Move things without touching them" accent={ACCENT}>Kinetic</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="openPalm" title="Open palm" body="A force field pushes every orb away from you. Spread your fingers wider for more power." delay={80} />
            <HowTo glyph="fist" title="Close your fist" body="Snatch the nearest orb out of the air. It follows your hand." delay={160} />
            <HowTo glyph="wave" title="Open again to throw" body="Release, and the orb flies off with whatever speed your hand was moving." delay={240} />
          </div>
          <p className="text-white/70 mb-7 text-center max-w-md">
            Land orbs in the ring on the right. The faster they arrive, the more they score.
            Up to four hands at once, so bring a friend.
          </p>
          <Button accent={ACCENT} onClick={start}>Enter the arena</Button>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Time</p>
          <div className="font-display text-7xl font-700 text-mint mb-2 animate-pop">
            <Odometer value={ui.score} />
          </div>
          <p className="text-muted mb-8">{ui.banked} orbs banked</p>
          <Button accent={ACCENT} onClick={start}>Go again</Button>
        </Screen>
      )}
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
import { createBloom, drawVignette } from '../lib/render.js'
import { drawShip as drawShipArt } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, HowTo, Results, Loading, ErrorScreen } from '../components/ui.jsx'

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
    bloom: createBloom(0.5),
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
    playMusic('space')
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
          sfx.go()
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
            sfx.crash()
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
      stopMusic()
      sfx.win()
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
        const bctx = settings.bloom ? g.bloom.layer(W, H) : null
        for (const w of g.walls) { drawWall(ctx, W, H, w); if (bctx) drawWall(bctx, W, H, w) }
        for (const s of g.ships) { drawShip(ctx, W, H, s, now); if (bctx) drawShip(bctx, W, H, s, now) }
        if (bctx) g.bloom.composite(ctx, W, H, { blur: 11, alpha: 0.55 })
        for (const p of g.sparks) {
          ctx.globalAlpha = Math.max(0, p.life)
          ctx.fillStyle = p.color
          ctx.beginPath()
          ctx.arc(p.x * W, p.y * H, 2.5, 0, Math.PI * 2)
          ctx.fill()
        }
        ctx.globalAlpha = 1
        drawVignette(ctx, W, H, 0.45)
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
      ctx.save()
      for (let i = s.trail.length - 1; i >= 0; i--) {
        const t = s.trail[i]
        ctx.globalAlpha = (1 - i / s.trail.length) * 0.4
        ctx.fillStyle = s.color
        ctx.beginPath()
        ctx.arc(x - i * 6, t.y * H, Math.max(1, 6 - i * 0.28), 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.restore()
      drawShipArt(ctx, x, y, Math.min(1.5, H / 480), s.color, now, false)
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
  const ACCENT = '#00D4FF'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Fly with your palm · last one flying wins" accent={ACCENT}>Rocket Rush</Title>
          <div className="grid gap-2.5 mb-7 max-w-md w-full mt-1">
            <HowTo glyph="openPalm" title="Raise a hand" body="Everyone stands left to right. When all pilots are in, you launch." delay={80} />
            <HowTo glyph="wave" title="Move up and down" body="Your palm height flies the rocket. Thread the gap in every gate." delay={160} />
            <HowTo glyph="fist" title="One clip and you're out" body="The gates speed up and the gaps narrow the further you get." delay={240} />
          </div>
          <div className="flex flex-wrap justify-center gap-3">
            <Button accent={ACCENT} onClick={() => begin(2, false)}>1 v 1</Button>
            <Button variant="ghost" onClick={() => begin(3, false)}>3 players</Button>
            <Button variant="ghost" onClick={() => begin(4, false)}>4 players</Button>
            <Button variant="ghost" onClick={() => begin(4, true)}>2 v 2 teams</Button>
          </div>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Flight over</p>
          <div className="font-display text-4xl md:text-5xl font-700 mb-7 text-center animate-pop">{ui.winner} wins</div>
          <Results
            accent={ACCENT}
            rows={ui.standing.map((s) => ({ name: s.name, color: s.color, note: s.alive ? 'survived' : 'wrecked' }))}
          />
          <div className="flex gap-3 mt-8">
            <Button accent={ACCENT} onClick={() => begin(cfgRef.current.count, cfgRef.current.teams)}>Fly again</Button>
            <Button variant="ghost" onClick={() => { g.phase = 'menu'; setUi({ phase: 'menu', claimed: 0, standing: [], winner: '' }) }}>
              Change mode
            </Button>
          </div>
        </Screen>
      )}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Dance.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, ROUTINES, scorePose, boneScore } from '../lib/poses.js'
import { createTracker, createRoster } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette, drawFrameGuide, drawColorGrade } from '../lib/render.js'
import { drawCharacter, withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, Choice, Results, Loading, ErrorScreen, Stagger, Odometer } from '../components/ui.jsx'

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
    bloom: createBloom(0.5),
    roster: null,
    players: [],
    step: -1,
    stepEndsAt: 0,
    readyAt: 0,
    countStart: 0,
    live: [],
    popups: [],
    beat: 0,
    beeped: -1,
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
          g.beeped = -1
          sfx.whoosh()
        }
      } else g.readyAt = 0
    }

    function runCountdown(now) {
      const n = Math.ceil((3200 - (now - g.countStart)) / 1000)
      if (n !== g.beeped && n > 0) { g.beeped = n; sfx.beep(3 - n) }
      if (now - g.countStart > 3200) {
        sfx.go()
        playMusic('dance')
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
        if (i === 0) {
          if (gr.label === 'PERFECT') sfx.perfect()
          else if (gr.label === 'GREAT') sfx.great()
          else if (gr.label === 'GOOD') sfx.good()
          else sfx.miss()
          if (p.combo > 1 && gr.points > 0) sfx.combo(p.combo)
        }
      }
      g.step += 1
      if (g.step >= routine.steps.length) {
        g.phase = 'over'
        stopMusic()
        sfx.win()
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

      // The dancers themselves, behind everything.
      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror,
          alpha: 0.34,
          grade: 'grayscale(0.7) brightness(0.5) contrast(1.2)',
        })
        drawColorGrade(ctx, W, H, '#FF4D8D', 0.10)
      }
      drawFloor(ctx, W, H, now)

      // Everything that glows goes into the bloom pass, then gets added back
      // once — far cheaper and prettier than blurring each shape separately.
      const useBloom = settings.bloom
      const bctx = useBloom ? g.bloom.layer(W, H) : null

      // With bloom on, the visible pass skips per-shape shadowBlur entirely and
      // lets the blurred layer supply the glow. Cheaper and softer.
      const mainGlow = useBloom ? 0 : null
      if (target) {
        drawTarget(ctx, W, H, target, now, mainGlow ?? 26)
        if (bctx) drawTarget(bctx, W, H, target, now, 0)
      }
      for (let i = 0; i < g.live.length; i++) {
        const l = g.live[i]
        if (!l) continue
        drawPerson(ctx, W, H, l, COLORS[i], mainGlow ?? 16)
        if (bctx) drawPerson(bctx, W, H, l, COLORS[i], 0)
      }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 10, alpha: 0.55 })

      drawVignette(ctx, W, H, 0.5)
      if (g.phase === 'dancing') drawBeat(ctx, W, H)
      drawPopups(ctx, W, H, dt)

      const anyoneSeen = g.live.some(Boolean)
      drawFrameGuide(ctx, W, H, anyoneSeen || g.phase !== 'dancing', Math.sin(now * 0.006) * 0.5 + 0.5)

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

    function drawTarget(ctx, W, H, target, now, glow = 26) {
      const h = H * 0.52
      const box = { x: W * 0.5 - h / 2, y: H * 0.09, w: h, h }
      const pts = {}
      for (const k of Object.keys(target.points)) {
        const p = target.points[k]
        const x = settings.mirror ? 1 - p.x : p.x
        pts[k] = { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      // Projector cone from above sells the hologram.
      ctx.save()
      const cone = ctx.createLinearGradient(W / 2, 0, W / 2, box.y + box.h)
      cone.addColorStop(0, 'rgba(176,107,255,0.16)')
      cone.addColorStop(1, 'rgba(176,107,255,0)')
      ctx.fillStyle = cone
      ctx.beginPath()
      ctx.moveTo(W / 2 - 30, 0)
      ctx.lineTo(W / 2 - box.w * 0.44, box.y + box.h)
      ctx.lineTo(W / 2 + box.w * 0.44, box.y + box.h)
      ctx.lineTo(W / 2 + 30, 0)
      ctx.closePath()
      ctx.fill()
      // Platform the figure stands on, pulsing with the beat.
      const beatPulse = 1 - Math.min(1, g.beat)
      ctx.strokeStyle = withAlpha('#B06BFF', 0.35 + beatPulse * 0.4)
      ctx.lineWidth = 2 + beatPulse * 3
      ctx.beginPath()
      ctx.ellipse(W / 2, box.y + box.h + 6, box.w * 0.32 * (1 + beatPulse * 0.06), box.w * 0.06, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()

      drawCharacter(ctx, pts, {
        color: '#B06BFF',
        accent: '#EBDBFF',
        alpha: 0.55 + (1 - g.beat) * 0.3,
        hologram: true,
        glow,
      })
    }

    function drawPerson(ctx, W, H, l, color, glow = 16) {
      const lm = l.lm
      const pts = {}
      for (const i of [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]) {
        if (!lm[i] || (lm[i].visibility ?? 1) < 0.4) continue
        pts[i] = { x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W, y: lm[i].y * H }
      }
      // Ground shadow anchors the character instead of leaving it floating.
      const feet = [pts[27], pts[28]].filter(Boolean)
      if (feet.length) {
        const fx = feet.reduce((a, p) => a + p.x, 0) / feet.length
        const fy = Math.max(...feet.map((p) => p.y))
        ctx.save()
        ctx.globalAlpha = 0.3
        ctx.fillStyle = '#000'
        ctx.beginPath()
        ctx.ellipse(fx, fy + 8, 46, 10, 0, 0, Math.PI * 2)
        ctx.fill()
        ctx.restore()
      }
      drawCharacter(ctx, pts, {
        color,
        accent: '#FFFFFF',
        glow,
        limbColor: l.result
          ? (a, b) => {
              const sc = boneScore(l.result.bones, a, b)
              return sc == null ? null : scoreColor(sc)
            }
          : null,
      })
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
  const ACCENT = '#FF4D8D'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase === 'dancing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-5 animate-riseIn" key={ui.poseName}>
            <div className="text-[11px] uppercase tracking-[0.2em] text-white/45">
              Move {ui.step + 1} of {ui.total}
            </div>
            <div className="font-display text-3xl md:text-4xl font-700 mt-0.5">{ui.poseName}</div>
            <div className="text-white/60 text-sm max-w-[15rem] mt-1">{ui.hint}</div>
          </div>
          <div className="pointer-events-none absolute right-6 top-5 flex flex-col gap-2 items-end">
            {ui.players.map((p, i) => (
              <div
                key={i}
                className="flex items-center gap-3 rounded-xl border px-3.5 py-2 backdrop-blur-md"
                style={{ background: p.color + '14', borderColor: p.color + '44' }}
              >
                <span className="text-xs" style={{ color: p.color }}>{p.name}</span>
                <Odometer value={p.score} className="font-display text-xl" />
                {p.combo > 1 && (
                  <span className="text-xs font-medium text-mint animate-pop" key={p.combo}>×{p.combo}</span>
                )}
              </div>
            ))}
          </div>
        </>
      )}

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading
          accent={ACCENT}
          label={status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'}
        />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Follow the dancer" accent={ACCENT}>Dance Floor</Title>
          <p className="text-white/70 mb-7 max-w-md text-center animate-riseIn" style={{ animationDelay: '90ms', animationFillMode: 'backwards' }}>
            A figure moves through a routine. Match each shape before the bar runs out — your limbs
            light up green as they line up. Chain hits for a combo multiplier.
          </p>
          <Stagger className="w-full max-w-sm space-y-5 mb-7" gap={110}>
            <Choice
              label="Routine"
              accent={ACCENT}
              options={ROUTINES.map((r, i) => ({ v: i, l: `${r.name} · ${r.level}` }))}
              value={cfg.current.routine}
              onChange={(v) => { cfg.current = { ...cfg.current, routine: v }; setUi((u) => ({ ...u })) }}
            />
            <Choice
              label="Dancers"
              accent={ACCENT}
              options={[1, 2, 3, 4].map((n) => ({ v: n, l: n === 1 ? 'Solo' : n === 2 ? '1 v 1' : `${n} players` }))}
              value={cfg.current.count}
              onChange={(v) => { cfg.current = { ...cfg.current, count: v }; setUi((u) => ({ ...u })) }}
            />
          </Stagger>
          <Button accent={ACCENT} onClick={() => begin(cfg.current.count, cfg.current.routine)}>
            Start the music
          </Button>
          <p className="text-muted text-xs mt-5">Stand back so everyone's legs are in frame.</p>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Routine complete</p>
          <div className="font-display text-4xl md:text-5xl font-700 mb-7 text-center animate-pop">
            {ranked.length > 1 ? `${ranked[0].name} wins` : 'Nice moves'}
          </div>
          <Results
            accent={ACCENT}
            rows={ranked.map((p) => ({ name: p.name, color: p.color, value: p.score, note: `best ×${p.best}` }))}
          />
          <div className="flex gap-3 mt-8">
            <Button accent={ACCENT} onClick={() => begin(cfg.current.count, cfg.current.routine)}>Dance again</Button>
            <Button variant="ghost" onClick={() => { g.phase = 'menu'; setUi((u) => ({ ...u, phase: 'menu' })) }}>
              Change routine
            </Button>
          </div>
        </Screen>
      )}
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
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Paint.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings } from '../lib/storage.js'
import { HAND_CONNECTIONS, isPointing, palmCenter, handSpan } from '../lib/gestures.js'
import { createTracker } from '../lib/tracking.js'
import { useCanvasSize, logicalSize, roundRect } from '../lib/canvas.js'
import { sfx, playMusic } from '../lib/audio.js'
import { Loading, ErrorScreen } from '../components/ui.jsx'

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
    sfx.clear()
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
  useEffect(() => { if (status === 'ready') playMusic('chill') }, [status])

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

        if (drawing && !pen.last && !btn) sfx.penDown()
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
      sfx.pick()
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

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent="#FF7A45" label={status === 'loading-model' ? 'Loading hand model…' : 'Waking up the camera…'} />
      )}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/PoseMatch.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { POSES, scorePose, boneScore } from '../lib/poses.js'
import { useCanvasSize, logicalSize, scoreColor } from '../lib/canvas.js'
import { createBloom, drawCameraBackdrop, drawVignette, drawFrameGuide, drawColorGrade } from '../lib/render.js'
import { drawCharacter, withAlpha } from '../lib/characters.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { Screen, Title, Button, Results, Loading, ErrorScreen, Odometer } from '../components/ui.jsx'

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
    bloom: createBloom(0.5),
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
    playMusic('chill')
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
      if (settings.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: settings.mirror,
          alpha: 0.30,
          grade: 'grayscale(0.75) brightness(0.5) contrast(1.15)',
        })
        drawColorGrade(ctx, W, H, '#7C5CFF', 0.10)
      }
      const bctx = settings.bloom ? g.bloom.layer(W, H) : null
      const mainGlow = bctx ? 0 : null
      if (target) { drawTarget(ctx, W, H, target, now, mainGlow ?? 26); if (bctx) drawTarget(bctx, W, H, target, now, 0) }
      if (person) { drawPlayer(ctx, W, H, person, mainGlow ?? 16); if (bctx) drawPlayer(bctx, W, H, person, 0) }
      if (bctx) g.bloom.composite(ctx, W, H, { blur: 10, alpha: 0.55 })
      drawVignette(ctx, W, H, 0.5)
      drawFrameGuide(ctx, W, H, !!person && g.visible, Math.sin(now * 0.006) * 0.5 + 0.5)
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
      if (locked) sfx.perfect(); else sfx.miss()
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
        stopMusic()
        sfx.win()
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

    function drawTarget(ctx, W, H, target, now, glow = 26) {
      const box = targetBox(W, H)
      const pts = {}
      for (const k of Object.keys(target.points)) {
        const p = target.points[k]
        const x = settings.mirror ? 1 - p.x : p.x
        pts[k] = { x: box.x + x * box.w, y: box.y + p.y * box.h }
      }
      ctx.save()
      const cone = ctx.createLinearGradient(W / 2, 0, W / 2, box.y + box.h)
      cone.addColorStop(0, 'rgba(124,92,255,0.14)')
      cone.addColorStop(1, 'rgba(124,92,255,0)')
      ctx.fillStyle = cone
      ctx.beginPath()
      ctx.moveTo(W / 2 - 26, 0)
      ctx.lineTo(W / 2 - box.w * 0.42, box.y + box.h)
      ctx.lineTo(W / 2 + box.w * 0.42, box.y + box.h)
      ctx.lineTo(W / 2 + 26, 0)
      ctx.closePath()
      ctx.fill()
      ctx.strokeStyle = withAlpha('#7C5CFF', 0.4)
      ctx.lineWidth = 2
      ctx.beginPath()
      ctx.ellipse(W / 2, box.y + box.h + 6, box.w * 0.30, box.w * 0.055, 0, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()

      drawCharacter(ctx, pts, {
        color: '#7C5CFF',
        accent: '#DED3FF',
        alpha: 0.55 + Math.sin(now * 0.003) * 0.12,
        hologram: true,
        glow,
      })
    }

    function drawPlayer(ctx, W, H, lm, glow = 16) {
      const pts = {}
      for (const i of [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]) {
        if (!lm[i] || (lm[i].visibility ?? 1) < 0.4) continue
        pts[i] = { x: (settings.mirror ? 1 - lm[i].x : lm[i].x) * W, y: lm[i].y * H }
      }
      const feet = [pts[27], pts[28]].filter(Boolean)
      if (feet.length) {
        const fx = feet.reduce((a, p) => a + p.x, 0) / feet.length
        const fy = Math.max(...feet.map((p) => p.y))
        ctx.save()
        ctx.globalAlpha = 0.3
        ctx.fillStyle = '#000'
        ctx.beginPath()
        ctx.ellipse(fx, fy + 8, 48, 11, 0, 0, Math.PI * 2)
        ctx.fill()
        ctx.restore()
      }
      drawCharacter(ctx, pts, {
        color: '#00E5B0',
        accent: '#FFFFFF',
        glow,
        limbColor: (a, b) => {
          const sc = boneScore(g.bones, a, b)
          return sc == null ? null : scoreColor(sc)
        },
      })
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
  const ACCENT = '#7C5CFF'

  return (
    <div className="relative h-[calc(100vh-3.5rem)] w-full overflow-hidden">
      <video ref={videoRef} className="hidden" playsInline muted />
      <canvas ref={canvasRef} className="block h-full w-full" />

      {ui.phase === 'playing' && (
        <>
          <div className="pointer-events-none absolute left-6 top-6 animate-riseIn" key={ui.poseName}>
            <div className="text-[11px] uppercase tracking-[0.2em] text-white/45">
              Pose {Math.min(ui.index + 1, ROUND_POSES)} of {ROUND_POSES}
            </div>
            <div className="font-display text-3xl md:text-4xl font-700 mt-0.5">{ui.poseName}</div>
            <div className="text-white/60 text-sm mt-1 max-w-[16rem]">{ui.hint}</div>
            <div className="mt-4 font-display text-2xl text-mint">
              <Odometer value={ui.score} />
            </div>
          </div>
          {!ui.visible && (
            <div className="pointer-events-none absolute inset-x-0 bottom-16 text-center">
              <span className="rounded-full bg-ember/20 border border-ember/40 px-4 py-2 text-ember text-sm animate-pulseSoft">
                Step back so your whole body is in frame
              </span>
            </div>
          )}
        </>
      )}

      {status === 'error' && <ErrorScreen message={error} />}
      {loading && (
        <Loading accent={ACCENT} label={status === 'loading-model' ? 'Loading body model…' : 'Waking up the camera…'} />
      )}

      {status === 'ready' && ui.phase === 'menu' && (
        <Screen accent={ACCENT}>
          <Title kicker="Match the shape · hold it · bank it" accent={ACCENT}>Copy That</Title>
          <p className="text-white/70 mb-8 max-w-md text-center animate-riseIn" style={{ animationDelay: '90ms', animationFillMode: 'backwards' }}>
            A glowing figure strikes a pose. Copy it with your own body — your limbs turn green as
            they line up. Hold the shape for half a second to bank the points before the timer runs
            out. {ROUND_POSES} poses per round.
          </p>
          <Button accent={ACCENT} onClick={start}>Start round</Button>
          <p className="text-muted text-xs mt-5">Stand back about 2 metres so your legs are in frame.</p>
        </Screen>
      )}

      {ui.phase === 'over' && (
        <Screen accent={ACCENT}>
          <p className="text-muted mb-2 tracking-[0.2em] uppercase text-xs">Round complete</p>
          <div className="font-display text-6xl font-700 text-mint mb-7 animate-pop">
            <Odometer value={ui.score} />
          </div>
          <Results
            accent={ACCENT}
            rows={ui.results.map((r) => ({ name: r.name, color: scoreColor(r.quality / 100), value: r.points, note: r.quality + '%' }))}
          />
          <Button accent={ACCENT} onClick={start} className="mt-8">Play again</Button>
        </Screen>
      )}
    </div>
  )
}
HANDPLAY_EOF
mkdir -p src/pages
cat > src/pages/Orbs.jsx <<'HANDPLAY_EOF'
import { useEffect, useRef, useState } from 'react'
import { useVision } from '../lib/useVision.js'
import { loadSettings, addSession } from '../lib/storage.js'
import { sfx, playMusic, stopMusic } from '../lib/audio.js'
import { createBloom, drawCameraBackdrop, drawVignette } from '../lib/render.js'

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
  const bloomRef = useRef(createBloom(0.5))
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
      if (s.cameraFeed) {
        drawCameraBackdrop(ctx, videoRef.current, W, H, {
          mirror: s.mirror, alpha: 0.16,
          grade: 'grayscale(0.85) brightness(0.45) contrast(1.2)',
        })
      }
      const bctx = s.bloom ? bloomRef.current.layer(W, H) : null

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
              sfx.combo(g.combo)
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
          sfx.release()
        }
        g.wasPinching = pinching

        g.orbs = g.orbs.filter((o) => o.alive)
        drawOrbs(ctx, g.orbs, now)
        if (bctx) drawOrbs(bctx, g.orbs, now)
        drawParticles(ctx, g, dt)
        if (bctx) bloomRef.current.composite(ctx, W, H, { blur: 11, alpha: 0.55 })
        drawVignette(ctx, W, H, 0.45)
        drawHud(ctx, W, g)
      } else {
        drawParticles(ctx, g, dt)
        if (bctx) bloomRef.current.composite(ctx, W, H, { blur: 11, alpha: 0.55 })
        drawVignette(ctx, W, H, 0.45)
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
    playMusic('chill')
    setPhase('playing')
  }

  function endRound() {
    const g = game.current
    g.running = false
    stopMusic()
    sfx.win()
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


/* ======================= added with the visual overhaul ===================== */

console.log('\nAudio degrades safely when the browser blocks it')
global.window = { addEventListener() {} }
const audio = await import('../src/lib/audio.js')
let audioThrew = null
try {
  audio.installUnlockListener()
  audio.unlock()                       // no AudioContext available at all
  for (const [name, fn] of Object.entries(audio.sfx)) {
    try { fn(1) } catch (e) { audioThrew = `${name}: ${e.message}` }
  }
  audio.playMusic('dance')
  audio.playMusic('nope')
  audio.stopMusic()
  audio.setMuted(true)
} catch (e) { audioThrew = e.message }
check('no sound effect throws without Web Audio', audioThrew === null, audioThrew || '')
check('every documented effect exists', Object.keys(audio.sfx).length >= 18,
  `got ${Object.keys(audio.sfx).length}`)
check('muting is reflected in state', audio.isMuted() === true)

console.log('\nCharacter rendering')
const chars = await import('../src/lib/characters.js')
// A recording stub — enough surface for the renderer to run headlessly.
function stubCtx() {
  const calls = []
  const grad = { addColorStop() {} }
  const handler = {
    get(_, k) {
      if (k === '__calls') return calls
      if (k === 'createLinearGradient' || k === 'createRadialGradient') return () => grad
      if (k === 'canvas') return { width: 1280, height: 720 }
      return (...a) => { calls.push(k); return undefined }
    },
    set() { return true },
  }
  return new Proxy({}, handler)
}
const full = {}
for (const [i, xy] of Object.entries({
  0: [500, 100], 11: [560, 200], 12: [440, 200], 13: [600, 300], 14: [400, 300],
  15: [640, 400], 16: [360, 400], 23: [540, 400], 24: [460, 400],
  25: [550, 520], 26: [450, 520], 27: [555, 640], 28: [445, 640],
})) full[i] = { x: xy[0], y: xy[1] }

let charThrew = null
try {
  const c1 = stubCtx()
  chars.drawCharacter(c1, full, { color: '#00E5B0' })
  check('a full body renders', c1.__calls.length > 20, `${c1.__calls.length} draw ops`)

  // Upper body only — legs cropped out of frame.
  const upper = { ...full }
  for (const i of [25, 26, 27, 28]) delete upper[i]
  const c2 = stubCtx()
  chars.drawCharacter(c2, upper, { color: '#00E5B0' })
  check('an upper body only still renders', c2.__calls.length > 10, `${c2.__calls.length} draw ops`)

  // Missing an arm entirely.
  const oneArm = { ...full }
  for (const i of [13, 15]) delete oneArm[i]
  const c3 = stubCtx()
  chars.drawCharacter(c3, oneArm, { color: '#FF4D8D' })
  check('a missing limb does not break the rig', c3.__calls.length > 10)

  // Too little data to be a body at all.
  const c4 = stubCtx()
  chars.drawCharacter(c4, { 0: { x: 1, y: 1 } }, {})
  check('an unusable skeleton is skipped rather than crashing', c4.__calls.length === 0,
    `${c4.__calls.length} draw ops`)

  const c5 = stubCtx()
  chars.drawCharacter(c5, full, { hologram: true, limbColor: () => '#fff' })
  check('hologram styling renders', c5.__calls.length > 20)

  const c6 = stubCtx()
  chars.drawGunslinger(c6, 200, 500, 1.2, { color: '#FFB000', raise: 0.5, facing: 1, t: 1000 })
  check('the gunslinger renders', c6.__calls.length > 15)
  const hand = chars.drawGunslinger(stubCtx(), 200, 500, 1.2, { raise: 1, facing: 1, t: 0 })
  check('the gunslinger reports a hand position for the revolver',
    Number.isFinite(hand.x) && Number.isFinite(hand.y), JSON.stringify(hand))

  const c7 = stubCtx()
  chars.drawShip(c7, 100, 100, 1, '#00D4FF', 0, false)
  check('the ship renders', c7.__calls.length > 10)
} catch (e) { charThrew = e.stack }
check('character rendering never throws', charThrew === null, charThrew || '')

console.log('\nColour helpers')
check('lighten moves toward white', chars.lighten('#000000', 1) === 'rgb(255,255,255)',
  chars.lighten('#000000', 1))
check('darken moves toward black', chars.darken('#FFFFFF', 1) === 'rgb(0,0,0)', chars.darken('#FFFFFF', 1))
check('withAlpha builds valid rgba', chars.withAlpha('#00E5B0', 0.5) === 'rgba(0,229,176,0.5)',
  chars.withAlpha('#00E5B0', 0.5))
check('shorthand hex is handled', chars.lighten('#0f0', 0) === 'rgb(0,255,0)', chars.lighten('#0f0', 0))


/* ==================== added with the accuracy overhaul ===================== */
const { createOneEuro, createLandmarkSmoother, plausibleHand, plausiblePose } =
  await import('../src/lib/filter.js')

console.log('\nJitter smoothing')
// A hand held still, with the pixel-level noise MediaPipe actually produces.
let rawVar = 0, smoothVar = 0
{
  const f = createOneEuro()
  const raws = [], smooths = []
  for (let i = 0; i < 240; i++) {
    const t = i / 60
    const raw = 0.5 + (Math.random() - 0.5) * 0.012   // ~1.2% frame jitter
    raws.push(raw)
    smooths.push(f.filter(raw, t))
  }
  const settled = 60
  const variance = (a) => {
    const m = a.reduce((x, y) => x + y, 0) / a.length
    return a.reduce((x, y) => x + (y - m) ** 2, 0) / a.length
  }
  rawVar = variance(raws.slice(settled))
  smoothVar = variance(smooths.slice(settled))
}
check('a still hand is dramatically steadier', smoothVar < rawVar / 8,
  `noise cut ${(rawVar / smoothVar).toFixed(0)}x`)

console.log('\nResponsiveness (lag is worse than jitter in a game)')
let maxLag = 0
{
  const f = createOneEuro()
  // A fast swipe across the frame in a third of a second.
  for (let i = 0; i < 20; i++) {
    const t = i / 60
    const truth = i / 19
    const out = f.filter(truth, t)
    if (i > 4) maxLag = Math.max(maxLag, Math.abs(truth - out))
  }
}
check('fast motion still tracks closely', maxLag < 0.08, `worst gap ${(maxLag * 100).toFixed(1)}% of frame`)

{
  const f = createOneEuro()
  const first = f.filter(0.42, 0)
  check('the first sample passes through untouched', first === 0.42)
  f.filter(0.5, 1000000)          // absurd time gap, e.g. a backgrounded tab
  const after = f.filter(0.5, 1000000.016)
  check('a huge time gap does not blow up the filter', Number.isFinite(after), String(after))
  const bad = f.filter(NaN, 1000000.033)
  check('NaN input never propagates', Number.isFinite(bad), String(bad))
}

console.log('\nLandmark smoother')
{
  const sm = createLandmarkSmoother()
  const mk = (n, jit) => Array.from({ length: n }, (_, i) => ({
    x: 0.5 + (Math.random() - 0.5) * jit, y: 0.5, z: 0, visibility: 0.9,
  }))
  let out
  for (let i = 0; i < 120; i++) out = sm.apply(mk(21, 0.01), i / 60)
  check('smoother returns every landmark', out.length === 21)
  check('non-coordinate fields survive', out[0].visibility === 0.9)
  const spread = Math.max(...out.map((p) => Math.abs(p.x - 0.5)))
  check('smoothed points settle near the true position', spread < 0.004,
    `worst ${(spread * 100).toFixed(2)}%`)
  const poseOut = sm.apply(mk(33, 0.01), 3)
  check('the same smoother handles a 33 point body', poseOut.length === 33)
}

console.log('\nRejecting impossible detections')
{
  const goodHand = Array.from({ length: 21 }, (_, i) => ({ x: 0.5 + i * 0.005, y: 0.5 + i * 0.004 }))
  check('a normal hand is accepted', plausibleHand(goodHand))
  const collapsed = Array.from({ length: 21 }, () => ({ x: 0.5, y: 0.5 }))
  check('a hand collapsed to a point is rejected', !plausibleHand(collapsed))
  const offscreen = Array.from({ length: 21 }, (_, i) => ({ x: 8 + i * 0.01, y: 9 }))
  check('landmarks far outside the frame are rejected', !plausibleHand(offscreen))
  check('a truncated hand is rejected', !plausibleHand(goodHand.slice(0, 10)))
  check('null is rejected', !plausibleHand(null))
  const nanHand = goodHand.map((p, i) => (i === 3 ? { x: NaN, y: 0.5 } : p))
  check('a NaN landmark is rejected', !plausibleHand(nanHand))

  const body = Array.from({ length: 33 }, () => ({ x: 0.5, y: 0.5, visibility: 0.9 }))
  body[11] = { x: 0.56, y: 0.3, visibility: 0.9 }
  body[12] = { x: 0.44, y: 0.3, visibility: 0.9 }
  body[23] = { x: 0.54, y: 0.6, visibility: 0.9 }
  body[24] = { x: 0.46, y: 0.6, visibility: 0.9 }
  check('a visible body is accepted', plausiblePose(body))
  const hidden = body.map((p) => ({ ...p, visibility: 0.05 }))
  check('a body nobody can see is rejected', !plausiblePose(hidden))
  check('a truncated body is rejected', !plausiblePose(body.slice(0, 20)))
}


/* ===================== added with the first-person games ==================== */
const { createCamera, fogAlpha } = await import('../src/lib/scene3d.js')
const { recognizeShape, strokeFeatures } = await import('../src/lib/shapes.js')
const { createPunchDetector, leanOf, crouchOf, spawnNpc, stepNpc, hitNpc, buildWave, isGuarding } =
  await import('../src/lib/combat.js')

console.log('\n3D camera')
{
  const cam = createCamera()
  const W = 1280, H = 720
  const centre = cam.project({ x: 0, y: 0, z: 10 }, W, H)
  check('a point straight ahead lands at screen centre',
    Math.abs(centre.x - W / 2) < 1 && Math.abs(centre.y - H / 2) < 1)
  const near = cam.project({ x: 1, y: 0, z: 5 }, W, H)
  const far = cam.project({ x: 1, y: 0, z: 20 }, W, H)
  check('nearer objects appear larger', near.s > far.s * 3, `${near.s.toFixed(1)} vs ${far.s.toFixed(1)}`)
  check('nearer objects sit further from centre', Math.abs(near.x - W / 2) > Math.abs(far.x - W / 2))
  check('geometry behind the viewer is culled', cam.project({ x: 0, y: 0, z: -2 }, W, H) === null)
  check('fog fades with distance', fogAlpha(5) === 1 && fogAlpha(100) === 0 && fogAlpha(20) > 0 && fogAlpha(20) < 1)
}

console.log('\nHead-coupled parallax (the effect that sells the window)')
{
  const cam = createCamera()
  const W = 1280, H = 720
  const before = cam.project({ x: 0, y: 0, z: 8 }, W, H).x
  for (let i = 0; i < 90; i++) cam.track(0.8, 0.5, 1 / 60)   // player leans right
  const after = cam.project({ x: 0, y: 0, z: 8 }, W, H).x
  check('leaning shifts the view', Math.abs(after - before) > 30, `moved ${(after - before).toFixed(0)}px`)
  // Near geometry must shift MORE than far geometry, or it reads as a flat pan.
  const camB = createCamera()
  const n0 = camB.project({ x: 0, y: 0, z: 4 }, W, H).x
  const f0 = camB.project({ x: 0, y: 0, z: 24 }, W, H).x
  for (let i = 0; i < 90; i++) camB.track(0.8, 0.5, 1 / 60)
  const n1 = camB.project({ x: 0, y: 0, z: 4 }, W, H).x
  const f1 = camB.project({ x: 0, y: 0, z: 24 }, W, H).x
  check('near geometry parallaxes more than far',
    Math.abs(n1 - n0) > Math.abs(f1 - f0) * 3,
    `near ${Math.abs(n1 - n0).toFixed(0)}px vs far ${Math.abs(f1 - f0).toFixed(0)}px`)
}

console.log('\nPunch detection')
{
  // A hand thrust at the lens: span grows fast. Others must not trigger.
  const mkHand = (span) => {
    const lm = []
    for (let i = 0; i < 21; i++) lm[i] = { x: 0.5, y: 0.5 }
    lm[0] = { x: 0.5, y: 0.5 }
    lm[9] = { x: 0.5, y: 0.5 - span }
    return lm
  }
  const punch = createPunchDetector()
  let fired = false
  for (let i = 0; i < 30; i++) punch.update(mkHand(0.09), i * 16)      // settle
  for (let i = 0; i < 8; i++) {
    const r = punch.update(mkHand(0.09 + i * 0.022), (30 + i) * 16)    // thrust
    if (r.punching) fired = true
  }
  check('a thrust toward the camera registers as a punch', fired)

  const still = createPunchDetector()
  let falsePositive = false
  for (let i = 0; i < 90; i++) {
    const jitter = 0.09 + Math.sin(i) * 0.002
    if (still.update(mkHand(jitter), i * 16).punching) falsePositive = true
  }
  check('a still hand never fires a punch', !falsePositive)

  const sideways = createPunchDetector()
  let sideFire = false
  for (let i = 0; i < 60; i++) {
    const lm = mkHand(0.09)
    for (const p of lm) p.x += i * 0.01          // moving across, same size
    if (sideways.update(lm, i * 16).punching) sideFire = true
  }
  check('a hand waved sideways is not a punch', !sideFire)

  const cool = createPunchDetector()
  let count = 0
  for (let i = 0; i < 30; i++) cool.update(mkHand(0.09), i * 16)
  for (let rep = 0; rep < 3; rep++) {
    for (let i = 0; i < 6; i++) {
      if (cool.update(mkHand(0.09 + i * 0.03), (30 + rep * 6 + i) * 16).punching) count++
    }
  }
  check('one thrust cannot register as many punches', count <= 2, `fired ${count}x`)
}

console.log('\nBody reads')
{
  const body = Array.from({ length: 33 }, () => ({ x: 0.5, y: 0.5, visibility: 0.9 }))
  body[11] = { x: 0.55, y: 0.3, visibility: 0.9 }
  body[12] = { x: 0.45, y: 0.3, visibility: 0.9 }
  check('a centred player reads as no lean', Math.abs(leanOf(body, true)) < 0.05)
  const leaning = body.map((p) => ({ ...p }))
  leaning[11] = { x: 0.75, y: 0.3, visibility: 0.9 }
  leaning[12] = { x: 0.65, y: 0.3, visibility: 0.9 }
  check('leaning is detected and signed', leanOf(leaning, true) < -0.5, String(leanOf(leaning, true)))
  check('mirroring flips the lean', leanOf(leaning, false) > 0.5)

  const standing = body.map((p) => ({ ...p }))
  standing[0] = { x: 0.5, y: 0.15, visibility: 0.9 }
  standing[23] = { x: 0.52, y: 0.6, visibility: 0.9 }
  standing[24] = { x: 0.48, y: 0.6, visibility: 0.9 }
  check('standing reads as no crouch', crouchOf(standing) < 0.1, String(crouchOf(standing)))
  const crouched = standing.map((p) => ({ ...p }))
  crouched[0] = { x: 0.5, y: 0.42, visibility: 0.9 }
  check('crouching is detected', crouchOf(crouched) > 0.6, String(crouchOf(crouched)))
  check('guard needs two open hands', !isGuarding([]))
}

console.log('\nNPC behaviour')
{
  const npc = spawnNpc('grunt', 0, 20)
  const player = { x: 0 }
  let sawWindup = false, sawStrike = false
  for (let i = 0; i < 2000 && !sawStrike; i++) {
    const ev = stepNpc(npc, 1 / 60, i * 16, player)
    if (ev === 'windup') sawWindup = true
    if (ev === 'strike') sawStrike = true
  }
  check('an NPC closes in and winds up', sawWindup)
  check('an NPC follows through to a strike', sawStrike)
  check('windup always precedes the strike', sawWindup && sawStrike)

  const target = spawnNpc('grunt', 0, 10)
  check('a hit does not instantly kill a 2hp grunt', hitNpc(target, 1, 0) === false)
  check('a hit staggers it', target.state === 'stagger')
  check('the killing blow reports a kill', hitNpc(target, 1, 100) === true)
  check('a dead NPC stays dead', target.state === 'dead')
  check('hitting a corpse does nothing', hitNpc(target, 5, 200) === false)

  const w1 = buildWave(1), w5 = buildWave(5)
  check('later waves are bigger', w5.length > w1.length, `${w1.length} then ${w5.length}`)
  check('waves stay within the arena', w5.every((s) => Math.abs(s.lane) <= 3.2))
  check('later waves include heavies', w5.some((s) => s.kind === 'brute'))
}

console.log('\nAir-drawn spell recognition')
{
  const circle = (n = 40, r = 0.2, noise = 0) =>
    Array.from({ length: n }, (_, i) => {
      const a = (i / (n - 1)) * Math.PI * 2
      return { x: 0.5 + Math.cos(a) * r + (Math.random() - 0.5) * noise,
               y: 0.5 + Math.sin(a) * r + (Math.random() - 0.5) * noise }
    })
  const line = (n = 30, noise = 0) =>
    Array.from({ length: n }, (_, i) => ({
      x: 0.2 + (i / (n - 1)) * 0.55 + (Math.random() - 0.5) * noise,
      y: 0.5 + (Math.random() - 0.5) * noise,
    }))
  const zig = (n = 40, noise = 0) =>
    Array.from({ length: n }, (_, i) => {
      const t = i / (n - 1)
      return { x: 0.2 + t * 0.55 + (Math.random() - 0.5) * noise,
               y: 0.5 + (Math.floor(t * 5) % 2 ? 0.13 : -0.13) + (Math.random() - 0.5) * noise }
    })

  check('a clean circle is read as a Ward', recognizeShape(circle()).name === 'circle',
    JSON.stringify(recognizeShape(circle())))
  check('a clean line is read as a Bolt', recognizeShape(line()).name === 'bolt',
    JSON.stringify(recognizeShape(line())))
  check('a clean zigzag is read as a Chain', recognizeShape(zig()).name === 'zigzag',
    JSON.stringify(recognizeShape(zig())))

  // Shaky real-world strokes must still land.
  let ok = { circle: 0, bolt: 0, zigzag: 0 }
  const N = 60
  for (let i = 0; i < N; i++) {
    if (recognizeShape(circle(40, 0.2, 0.015)).name === 'circle') ok.circle++
    if (recognizeShape(line(30, 0.015)).name === 'bolt') ok.bolt++
    if (recognizeShape(zig(40, 0.02)).name === 'zigzag') ok.zigzag++
  }
  check('shaky circles still recognised', ok.circle > N * 0.8, `${ok.circle}/${N}`)
  check('shaky lines still recognised', ok.bolt > N * 0.8, `${ok.bolt}/${N}`)
  check('shaky zigzags still recognised', ok.zigzag > N * 0.8, `${ok.zigzag}/${N}`)

  check('a tiny stroke is rejected', recognizeShape(line(30).map((p) => ({ x: p.x * 0.02 + 0.5, y: p.y * 0.02 }))).name === null)
  check('two points are rejected', recognizeShape([{ x: 0, y: 0 }, { x: 1, y: 1 }]).name === null)
  check('an empty stroke is rejected', recognizeShape([]).name === null)
  check('features are null for junk', strokeFeatures([{ x: 0, y: 0 }]) === null)

  // Rotation invariance: a line drawn at any angle is still a bolt.
  let rotOk = 0
  for (let deg = 0; deg < 360; deg += 30) {
    const a = (deg * Math.PI) / 180
    const rot = line(30).map((p) => {
      const dx = p.x - 0.5, dy = p.y - 0.5
      return { x: 0.5 + dx * Math.cos(a) - dy * Math.sin(a), y: 0.5 + dx * Math.sin(a) + dy * Math.cos(a) }
    })
    if (recognizeShape(rot).name === 'bolt') rotOk++
  }
  check('a bolt is recognised at any angle', rotOk === 12, `${rotOk}/12`)
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
