import Header from './components/Header'
import HeroSection from './components/HeroSection'
import FeatureCards from './components/FeatureCards'
import ContactForm from './components/ContactForm'
import Footer from './components/Footer'

export default function App() {
  return (
    <div>
      <Header />
      <main>
        <HeroSection />
        <FeatureCards />
        <ContactForm />
      </main>
      <Footer />
    </div>
  )
}
