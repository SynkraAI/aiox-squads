/**
 * Hero section — INTENTIONAL ISSUES FOR APEX DEMO:
 * - [A11Y] Low contrast text (#94a3b8 on #f8fafc = ~2.5:1, fails WCAG AA)
 * - [A11Y] Decorative image without empty alt=""
 * - [PERF] Large image loaded eagerly (no lazy loading)
 * - [CSS] Fixed pixel widths — not responsive
 * - [MOTION] No entrance animation
 */

export default function HeroSection() {
  return (
    <section style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: '60px',
      padding: '80px 32px',
      maxWidth: '1200px',
      margin: '0 auto',
    }}>
      <div style={{ width: '500px' }}>
        <h1 style={{
          fontSize: '48px',
          fontWeight: 800,
          lineHeight: 1.1,
          color: '#1e293b',
          marginBottom: '16px',
        }}>
          Build better products, faster
        </h1>

        <p style={{
          fontSize: '18px',
          color: '#94a3b8',
          marginBottom: '32px',
          lineHeight: 1.6,
        }}>
          A modern platform for teams that want to ship quality software
          without sacrificing speed or developer experience.
        </p>

        <div style={{ display: 'flex', gap: '12px' }}>
          <div
            onClick={() => {}}
            style={{
              background: '#6366f1',
              color: 'white',
              padding: '12px 28px',
              borderRadius: '8px',
              cursor: 'pointer',
              fontWeight: 600,
            }}
          >
            Start Free Trial
          </div>
          <div
            onClick={() => {}}
            style={{
              border: '1px solid #e2e8f0',
              padding: '12px 28px',
              borderRadius: '8px',
              cursor: 'pointer',
              fontWeight: 600,
              color: '#64748b',
            }}
          >
            Watch Demo
          </div>
        </div>
      </div>

      <div style={{ width: '500px' }}>
        <img
          src="https://placehold.co/500x400/e2e8f0/94a3b8?text=Product+Screenshot"
          alt="product screenshot showing the dashboard interface"
          style={{ width: '100%', borderRadius: '12px', boxShadow: '0 4px 24px rgba(0,0,0,0.1)' }}
        />
      </div>
    </section>
  )
}
