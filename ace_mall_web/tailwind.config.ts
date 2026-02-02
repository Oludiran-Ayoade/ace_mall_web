import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: "class",
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        border: '#e5e7eb',
        input: '#e5e7eb',
        ring: '#4CAF50',
        background: '#ffffff',
        foreground: '#1f2937',
        primary: {
          DEFAULT: "#4CAF50",
          foreground: "#ffffff",
          dark: "#2E7D32",
        },
        secondary: {
          DEFAULT: '#f3f4f6',
          foreground: '#1f2937',
        },
        destructive: {
          DEFAULT: '#ef4444',
          foreground: '#ffffff',
        },
        muted: {
          DEFAULT: '#f3f4f6',
          foreground: '#6b7280',
        },
        accent: {
          DEFAULT: '#f3f4f6',
          foreground: '#1f2937',
        },
        popover: {
          DEFAULT: '#ffffff',
          foreground: '#1f2937',
        },
        card: {
          DEFAULT: '#ffffff',
          foreground: '#1f2937',
        },
      },
      borderRadius: {
        lg: '0.75rem',
        md: '0.5rem',
        sm: '0.25rem',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
export default config
