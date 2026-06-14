import { useState } from 'react'
import { useReveal } from '../hooks/useReveal'

const commands = [
  {
    title: 'Windows',
    code: 'powershell -ExecutionPolicy Bypass -File .\\scripts\\install-windows.ps1 -AddToPath',
  },
  {
    title: 'Linux/macOS (Local script)',
    code: 'cd COMPILER_CPP\nbash scripts/install-local.sh',
  },
  {
    title: 'Linux/macOS (Quick curl & bash)',
    code: 'bash <(curl -fsSL {origin}/download/unix-source-installer)',
  },
]

function CopyBlock({ code }) {
  const [copied, setCopied] = useState(false)
  const origin = typeof window !== 'undefined' ? window.location.origin : ''
  const resolved = code.replace('{origin}', origin)

  const handleCopy = () => {
    navigator.clipboard.writeText(resolved)
    setCopied(true)
    setTimeout(() => setCopied(false), 1400)
  }

  return (
    <pre>
      <code className="copyable-pre" onClick={handleCopy} role="button" tabIndex={0}>
        {resolved}
        {copied && <span className="copy-tooltip">Copied!</span>}
      </code>
    </pre>
  )
}

export default function Install() {
  const ref = useReveal()

  return (
    <section id="install" className="section split">
      <div className="reveal" ref={ref}>
        <p className="eyebrow">Quick install</p>
        <h2>Copy a command</h2>
        <p>
          The website serves installer files directly. Download one, then run it from
          the project directory or keep it beside the source tree.
        </p>
      </div>
      <div className="commands">
        {commands.map((c, i) => (
          <InstallCmdBlock key={i} title={c.title} code={c.code} delay={i} />
        ))}
      </div>
    </section>
  )
}

function InstallCmdBlock({ title, code, delay }) {
  const ref = useReveal()
  return (
    <div className={`reveal reveal-delay-${delay}`} ref={ref}>
      <h3>{title}</h3>
      <CopyBlock code={code} />
    </div>
  )
}
