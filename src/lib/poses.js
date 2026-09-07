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
