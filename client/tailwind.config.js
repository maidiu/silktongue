/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Crimson Text', 'Georgia', 'serif'],
        serif: ['Crimson Text', 'Georgia', 'serif'],
        display: ['Cinzel', 'Georgia', 'serif'],
        decorative: ['Cinzel Decorative', 'Cinzel', 'serif'],
      },
      colors: {
        // Hollow Knight: Silksong inspired palette
        silk: {
          50: '#f0f4ff',
          100: '#e0e9ff',
          200: '#c7d9ff',
          300: '#a5c0ff',
          400: '#8aa8ff',
          500: '#7a8fff',
          600: '#5e6fd6',
          700: '#4a56ab',
          800: '#3a4482',
          900: '#2d3461',
        },
        void: {
          50: '#1a1a2e',
          100: '#16161f',
          200: '#12121a',
          300: '#0f0f16',
          400: '#0a0a12',
          500: '#07070e',
          600: '#05050a',
          700: '#030306',
          800: '#020203',
          900: '#000000',
        },
        soul: {
          50: '#f0fdff',
          100: '#ccf7ff',
          200: '#99efff',
          300: '#66e7ff',
          400: '#33dfff',
          500: '#00d4ff',
          600: '#00a8cc',
          700: '#007d99',
          800: '#005266',
          900: '#002633',
        },
        shade: {
          50: '#e6e0ff',
          100: '#c7b8ff',
          200: '#a890ff',
          300: '#8968ff',
          400: '#6a40ff',
          500: '#4b18ff',
          600: '#3c13cc',
          700: '#2d0e99',
          800: '#1e0966',
          900: '#0f0533',
        },
      },
      boxShadow: {
        'silk': '0 0 15px rgba(0, 212, 255, 0.3), 0 0 30px rgba(0, 212, 255, 0.1)',
        'silk-lg': '0 0 25px rgba(0, 212, 255, 0.4), 0 0 50px rgba(0, 212, 255, 0.2)',
        'void': '0 10px 40px rgba(0, 0, 0, 0.8)',
        'glow': '0 0 10px rgba(138, 168, 255, 0.5)',
      },
      animation: {
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'float': 'float 6s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-10px)' },
        }
      }
    },
  },
  plugins: [],
}

