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
