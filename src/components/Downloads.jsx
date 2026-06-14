import { useState } from 'react'
import { useReveal } from '../hooks/useReveal'

const downloads = [
  {
    title: 'Windows',
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 17.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z" />
      </svg>
    ),
    desc: 'Graphical installer with PATH integration.',
    primary: { href: '/download/windows-installer', label: 'Download .exe' },
    code: 'JSling-Setup.exe',
  },
  {
    title: 'Linux & macOS',
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 2L2 7l10 5 10-5-10-5z" /><path d="M2 17l10 5 10-5" /><path d="M2 12l10 5 10-5" />
      </svg>
    ),
    desc: 'Local source-tree installer for Unix-like systems.',
    primary: { href: '/download/unix-local-installer', label: 'Download .sh' },
    subCmd: true,
    code: 'bash scripts/install-local.sh',
  },
  {
    title: 'Source Installer',
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M4 17V9l8-6 8 6v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" />
      </svg>
    ),
    desc: 'Installer script for fetching and building from Git.',
    primary: { href: '/download/unix-source-installer', label: 'Download install.sh' },
    subCmd: true,
    code: 'bash install.sh --prefix "$HOME/.local"',
  },
  {
    title: 'Linux Binary',
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="2" width="20" height="8" rx="2" /><rect x="2" y="14" width="20" height="8" rx="2" /><line x1="6" y1="6" x2="6.01" y2="6" /><line x1="6" y1="18" x2="6.01" y2="18" />
      </svg>
    ),
    desc: 'Pre-built Linux binary when available on this machine.',
    primary: { href: '/download/linux-binary', label: 'Download binary' },
    code: 'bash COMPILER_CPP/scripts/build.sh',
  },
]

function CopyableCode({ text, className }) {
  const [copied, setCopied] = useState(false)
  const handleCopy = () => {
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 1200)
  }
  return (
    <code className={className} onClick={handleCopy} role="button" tabIndex={0} title="Click to copy">
      {text}
      {copied && <span className="copy-tooltip">Copied!</span>}
    </code>
  )
}

function CopyCmd({ text }) {
  const [copied, setCopied] = useState(false)
  const handleCopy = () => {
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 1200)
  }
  return (
    <code className="copy-cmd-inline" onClick={handleCopy} role="button" tabIndex={0} title="Click to copy">
      {text}
      {copied && <span className="copy-tooltip">Copied!</span>}
    </code>
  )
}

export default function Downloads() {
  const origin = typeof window !== 'undefined' ? window.location.origin : ''
  const headingRef = useReveal()

  return (
    <section id="downloads" className="section">
      <div className="section-heading reveal" ref={headingRef}>
        <p className="eyebrow">Downloads</p>
        <h2>Choose your platform</h2>
      </div>
      <div className="download-grid">
        {downloads.map((d, i) => (
          <DownloadCard key={i} item={d} origin={origin} delay={i} />
        ))}
      </div>
    </section>
  )
}

function DownloadCard({ item, origin, delay }) {
  const ref = useReveal()
  const curlCmd = `bash <(curl -fsSL ${origin}/download/unix-source-installer)`

  return (
    <article className={`download-card reveal reveal-delay-${delay}`} ref={ref}>
      <h3>{item.icon} {item.title}</h3>
      <p>{item.desc}</p>
      <a className="button primary" href={item.primary.href}>{item.primary.label}</a>
      {item.subCmd && (
        <div className="sub-cmd-block">
          <span className="sub-cmd-label">Or run:</span>
          <CopyCmd text={curlCmd} />
        </div>
      )}
      <CopyableCode text={item.code} className="download-filename" />
    </article>
  )
}
