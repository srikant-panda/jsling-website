import { useState, useEffect } from 'react'

const SunIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="4" />
    <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
  </svg>
)
const MonitorIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
    <line x1="8" y1="21" x2="16" y2="21" />
    <line x1="12" y1="17" x2="12" y2="21" />
  </svg>
)
const MoonIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
  </svg>
)

const navLinks = [
  { href: '#about', label: 'About' },
  { href: '#features', label: 'Features' },
  { href: '#downloads', label: 'Downloads' },
  { href: '#install', label: 'Install' },
  { href: '#verify', label: 'Verify' },
]

export default function Navbar() {
  const [menuOpen, setMenuOpen] = useState(false)
  const [theme, setTheme] = useState(() => localStorage.getItem('jsling-theme') || 'system')

  useEffect(() => {
    const active = theme === 'system'
      ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
      : theme
    document.documentElement.setAttribute('data-theme', active)
    localStorage.setItem('jsling-theme', theme)
  }, [theme])

  useEffect(() => {
    const mq = window.matchMedia('(prefers-color-scheme: dark)')
    const handler = (e) => {
      if (localStorage.getItem('jsling-theme') === 'system') {
        document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light')
      }
    }
    mq.addEventListener('change', handler)
    return () => mq.removeEventListener('change', handler)
  }, [])

  return (
    <header>
      <div className="topbar">
        <a className="brand" href="/">
          <span className="brand-mark">JS</span>
          <span>jsling</span>
        </a>
        <div className="topbar-right">
          <nav aria-label="Main navigation">
            {navLinks.map(l => (
              <a key={l.href} href={l.href}>{l.label}</a>
            ))}
          </nav>

          <div className="header-actions">
            <div className="theme-selector" role="radiogroup" aria-label="Theme preference">
              <div className="theme-slider-bg" />
              {[
                { value: 'light', icon: <SunIcon />, label: 'Light' },
                { value: 'system', icon: <MonitorIcon />, label: 'System' },
                { value: 'dark', icon: <MoonIcon />, label: 'Dark' },
              ].map(t => (
                <button
                  key={t.value}
                  className={`theme-btn${theme === t.value ? ' active' : ''}`}
                  data-theme={t.value}
                  onClick={() => setTheme(t.value)}
                  aria-label={`${t.label} theme`}
                  title={`${t.label} theme`}
                >
                  {t.icon}
                </button>
              ))}
            </div>

            <a className="github-link" href="https://github.com/srikant-panda/jsling" target="_blank" rel="noopener noreferrer" aria-label="GitHub" title="GitHub">
              <svg viewBox="0 0 16 16" fill="currentColor">
                <path d="M8 0c4.42 0 8 3.58 8 8a8.013 8.013 0 0 1-5.45 7.59c-.4.08-.55-.17-.55-.38 0-.27.01-1.13.01-2.2 0-.75-.25-1.23-.54-1.48 1.78-.2 3.65-.88 3.65-3.95 0-.88-.31-1.59-.82-2.15.08-.2.36-1.02-.08-2.12 0 0-.67-.22-2.2.82-.64-.18-1.32-.27-2-.27-.68 0-1.36.09-2 .27-1.53-1.03-2.2-.82-2.2-.82-.44 1.1-.16 1.92-.08 2.12-.51.56-.82 1.28-.82 2.15 0 3.06 1.86 3.75 3.64 3.95-.23.2-.44.55-.51 1.07-.46.21-1.61.55-2.33-.66-.15-.24-.6-.83-1.23-.82-.67.01-.27.38.01.53.34.19.73.9.82 1.13.16.45.68 1.35 3.12.88.01.64.01 1.11.01 1.20 0 .21-.15.46-.55.38A8.013 8.013 0 0 1 0 8c0-4.42 3.58-8 8-8z" />
              </svg>
            </a>

            <button
              className="menu-toggle"
              aria-label="Toggle navigation"
              aria-expanded={menuOpen}
              onClick={() => setMenuOpen(o => !o)}
            >
              {menuOpen ? (
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M18 6L6 18M6 6l12 12" /></svg>
              ) : (
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M3 6h18M3 12h18M3 18h18" /></svg>
              )}
            </button>
          </div>
        </div>
      </div>

      <nav className={`mobile-nav${menuOpen ? ' open' : ''}`} aria-label="Mobile navigation">
        {navLinks.map(l => (
          <a key={l.href} href={l.href} onClick={() => setMenuOpen(false)}>{l.label}</a>
        ))}
      </nav>
    </header>
  )
}
