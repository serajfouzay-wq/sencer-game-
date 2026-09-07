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
