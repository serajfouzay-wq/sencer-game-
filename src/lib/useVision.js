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
