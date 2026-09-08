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
