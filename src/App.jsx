import Navbar from './components/Navbar'
import About from './components/About'
import Features from './components/Features'
import Downloads from './components/Downloads'
import Install from './components/Install'
import Verify from './components/Verify'
import Footer from './components/Footer'

export default function App() {
  return (
    <>
      <Navbar />
      <main>
        <About />
        <Features />
        <Downloads />
        <Install />
        <Verify />
      </main>
      <Footer />
    </>
  )
}

