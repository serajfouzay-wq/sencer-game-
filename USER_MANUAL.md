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
