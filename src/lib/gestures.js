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
