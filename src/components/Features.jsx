import { useReveal } from '../hooks/useReveal'

const features = [
  {
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="4 17 10 11 4 5" /><line x1="12" y1="19" x2="20" y2="19" />
      </svg>
    ),
    title: 'Node-like CLI',
    desc: 'Run scripts, evaluate expressions, or drop into a REPL — just like Node.js.',
    code: `$ jsling script.js\n$ jsling -e "console.log(1 + 2)"\n$ jsling`,
  },
  {
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 2L2 7l10 5 10-5-10-5z" /><path d="M2 17l10 5 10-5" /><path d="M2 12l10 5 10-5" />
      </svg>
    ),
    title: 'Full Language Support',
    desc: 'Variables, closures, arrow functions, rest/spread, template literals, and more.',
    code: `const greet = (name = "world") =>\n  \`Hello, \${name}!\`;\n\nconsole.log(greet("jsling"));`,
  },
  {
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z" />
      </svg>
    ),
    title: 'Pure C++17 Engine',
    desc: 'No V8, no QuickJS. Lexer → Parser → AST → Interpreter, all in C++.',
    code: `// Tree-walking interpreter pipeline\nSource → Lexer → Parser\n     → AST → Interpreter\n     → Environment + built-ins\n     → stdout / stderr`,
  },
  {
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="2" width="20" height="8" rx="2" /><rect x="2" y="14" width="20" height="8" rx="2" /><circle cx="6" cy="6" r="1" /><circle cx="6" cy="18" r="1" />
      </svg>
    ),
    title: 'Built-in Modules',
    desc: 'Arrays, objects, Math, Date, console, and common string/number methods.',
    code: `const arr = [1, 2, 3, 4, 5];\nconst sum = arr.reduce(\n  (a, b) => a + b, 0\n);\nconsole.log(Math.max(...arr));`,
  },
  {
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
      </svg>
    ),
    title: 'Easy Install',
    desc: 'One-command install on Linux, macOS, and Windows. GUI installer for Windows.',
    code: `# Linux / macOS\nbash <(curl -fsSL example.com/install.sh)\n\n# Windows\npowershell -File install.ps1`,
  },
  {
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="12" cy="12" r="10" /><path d="M12 6v6l4 2" />
      </svg>
    ),
    title: 'Instant REPL',
    desc: 'Interactive shell with immediate feedback — perfect for experiments.',
    code: `>>> let x = 10, y = 20\n>>> x + y\n30\n>>> [1,2,3].map(n => n * 2)\n[ 2, 4, 6 ]`,
  },
]

export default function Features() {
  return (
    <section id="features" className="section features-section">
      <div className="section-heading">
        <p className="eyebrow">Features</p>
        <h2>Everything you need to run JavaScript-like code</h2>
      </div>
      <div className="features-grid">
        {features.map((f, i) => (
          <FeatureCard key={i} feature={f} delay={i} />
        ))}
      </div>
    </section>
  )
}

function FeatureCard({ feature, delay }) {
  const ref = useReveal()
  return (
    <article className={`feature-card reveal reveal-delay-${delay % 4}`} ref={ref}>
      <div className="feature-icon">{feature.icon}</div>
      <h3>{feature.title}</h3>
      <p>{feature.desc}</p>
      <pre><code>{feature.code}</code></pre>
    </article>
  )
}
