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
