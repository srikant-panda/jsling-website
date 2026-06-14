import { useState } from 'react'

export default function Hero() {
  const [copied, setCopied] = useState(false)
  const origin = typeof window !== 'undefined' ? window.location.origin : ''
  const curlCmd = `bash <(curl -fsSL ${origin}/download/unix-source-installer)`

  const handleCopy = () => {
    navigator.clipboard.writeText(curlCmd)
    setCopied(true)
    setTimeout(() => setCopied(false), 1400)
  }

  return (
    <section className="hero">
      <div className="hero-copy">
        <p className="eyebrow">C++17 JavaScript-like runtime</p>
        <h1>Run JavaScript,<br />your&nbsp;way.</h1>
        <p className="lead">
          jsling is a lightweight, Node-style command line runtime for JavaScript-like scripts,
          REPL sessions, and language experiments — built entirely from scratch in C++17.
        </p>

        <div className="hero-quickstart">
          <div className="platform-tabs">
            <a className="platform-tag" href="/download/windows-installer">Windows</a>
            <a className="platform-tag" href="/download/unix-local-installer">Linux &amp; macOS</a>
            <span className="platform-tag platform-tag--label">C++17</span>
          </div>
          <div className="hero-cmd" onClick={handleCopy} role="button" tabIndex={0} title="Click to copy">
            <span className="hero-cmd-prompt">$</span>
            <code className="hero-cmd-code">{curlCmd}</code>
            {copied
              ? <span className="hero-cmd-status">Copied!</span>
              : <span className="hero-cmd-hint">Click to copy</span>
            }
          </div>
          <p className="hero-cmd-note">
            Works on macOS, Linux, and Windows. The one-liner installs jsling and adds it to your PATH.
            Switch to a platform-specific installer from the <a href="#downloads">downloads section</a>.
          </p>
        </div>
      </div>

      <div className="terminal" aria-label="jsling terminal preview">
        <div className="terminal-bar">
          <span /><span /><span />
        </div>
        <pre><code><span className="prompt">$</span> jsling -e <span className="terminal-str">"console.log(1 + 2)"</span>
<span className="output">3</span>

<span className="prompt">$</span> jsling
<span className="terminal-comment">jsling v1.0.0 — JavaScript Runtime (REPL)</span>
<span className="prompt">&gt;&gt;&gt;</span> <span className="terminal-kw">const</span> add = (a, b) =&gt; a + b
<span className="prompt">&gt;&gt;&gt;</span> console.log(add(<span className="terminal-num">2</span>, <span className="terminal-num">5</span>))
<span className="output">7</span><span className="terminal-caret" /></code></pre>
      </div>
    </section>
  )
}
