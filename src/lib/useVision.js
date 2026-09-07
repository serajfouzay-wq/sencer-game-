import { useEffect, useRef, useState } from 'react'
import { HandLandmarker, PoseLandmarker, FilesetResolver } from '@mediapipe/tasks-vision'

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
    }
  }, [task, numHands, numPoses, sensitivity])

  /**
   * Runs detection for the current frame. Only re-runs the model when the video
   * has actually advanced, and never reuses a timestamp (MediaPipe throws on
   * non-increasing timestamps). Returns the most recent result either way.
   */
  function detect(timeMs) {
    const lm = landmarkerRef.current
    const video = videoRef.current
    if (!lm || !video || video.readyState < 2 || !video.videoWidth) return lastResultRef.current

    if (video.currentTime === lastVideoTimeRef.current) return lastResultRef.current
    lastVideoTimeRef.current = video.currentTime

    const stamp = timeMs <= lastStampRef.current ? lastStampRef.current + 1 : timeMs
    lastStampRef.current = stamp

    try {
      lastResultRef.current = lm.detectForVideo(video, stamp)
    } catch (e) {
      // A dropped frame should never kill the game loop.
      console.warn('detect skipped', e)
    }
    return lastResultRef.current
  }

  return { videoRef, status, error, detect }
}
