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
