/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#0A0A12',
        surface: '#151521',
        surface2: '#1E1E2E',
        line: '#2A2A3C',
        mint: '#00E5B0',
        violet: '#7C5CFF',
        ember: '#FF7A45',
        fg: '#EAEAF2',
        muted: '#8A8AA0',
        p1: '#FFB000',
        p2: '#00D4FF',
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'system-ui', 'sans-serif'],
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        glow: '0 0 24px rgba(0,229,176,0.35)',
        glowv: '0 0 24px rgba(124,92,255,0.35)',
      },
    },
  },
  plugins: [],
}
