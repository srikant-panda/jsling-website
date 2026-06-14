import { useReveal } from '../hooks/useReveal'

export default function Verify() {
  const ref = useReveal()

  return (
    <section id="verify" className="section verify reveal" ref={ref}>
      <p className="eyebrow">Check it</p>
      <h2>Verify your install</h2>
      <pre><code>{`jsling --version\njsling -e "console.log(1 + 2)"`}</code></pre>
      <p>Expected output: <strong>jsling v1.0.0</strong> and <strong>3</strong>.</p>
    </section>
  )
}
