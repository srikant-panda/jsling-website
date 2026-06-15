export default function Footer() {
  return (
    <footer>
      <div className="footer-inner">
        <div className="footer-left">
          <a className="brand" href="/">
            <span className="brand-mark">JS</span>
            <span>jsling</span>
          </a>
          <span className="footer-copy">&copy; {new Date().getFullYear()} jsling. Built from scratch in C++17.</span>
        </div>

        <div className="footer-links">
          <a href="/api/artifacts">API Status</a>
          <a href="https://github.com/srikant-panda/jsling" target="_blank" rel="noopener noreferrer">GitHub</a>
          <a href="https://www.linkedin.com/in/srikant-panda-66069432b" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="social-icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.852 3.37-1.852 3.601 0 4.267 2.37 4.267 5.455v6.288zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
            </svg>
          </a>
          <a href="https://x.com/Srikant_panda09" target="_blank" rel="noopener noreferrer" aria-label="X (Twitter)" className="social-icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584H.474l8.6-9.83L0 1.154h7.594l5.243 6.931ZM17.61 20.644h2.039L6.486 3.24H4.298Z"/>
            </svg>
          </a>
        </div>
      </div>
    </footer>
  )
}
