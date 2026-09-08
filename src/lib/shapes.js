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
