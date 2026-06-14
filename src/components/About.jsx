import { useReveal } from '../hooks/useReveal'

export default function About() {
  const ref = useReveal()

  return (
    <section id="about" className="section about">
      <div className="about-inner reveal" ref={ref}>
        <div className="about-text">
          <p className="eyebrow">About jsling</p>
          <h2>A JavaScript-like runtime, built from the ground up</h2>
          <p className="about-desc">
            jsling is a <strong>from-scratch JavaScript-like runtime</strong> written in C++17.
            It is designed to behave like a small Node.js-style CLI for a supported language subset —
            without embedding V8, QuickJS, or any other JavaScript engine.
          </p>
          <p className="about-desc">
            Every component — the lexer, parser, AST, and tree-walking interpreter — is implemented
            in pure C++, giving you a fast, dependency-free runtime for scripts, REPL sessions,
            and language experiments.
          </p>
          <div className="about-stats">
            <div className="stat">
              <span className="stat-number">0</span>
              <span className="stat-label">External JS engines</span>
            </div>
            <div className="stat">
              <span className="stat-number">C++17</span>
              <span className="stat-label">Pure implementation</span>
            </div>
            <div className="stat">
              <span className="stat-number">3</span>
              <span className="stat-label">Platforms supported</span>
            </div>
          </div>
        </div>
        <div className="about-visual">
          <div className="architecture-card">
            <h3>Architecture</h3>
            <div className="arch-flow">
              {['Source', 'Lexer', 'Parser', 'AST', 'Interpreter', 'Output'].map((step, i) => (
                <div key={step} className="arch-step">
                  <span className="arch-step-num">{i + 1}</span>
                  <span className="arch-step-name">{step}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
