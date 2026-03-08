/**
 * Feature cards — INTENTIONAL ISSUES FOR APEX DEMO:
 * - [A11Y] Cards are clickable divs without role="button" or keyboard support
 * - [A11Y] Icon-only content without aria-label
 * - [CSS] Hardcoded spacing (24px, 32px) instead of design tokens
 * - [CSS] Hover effect uses CSS transition, not spring
 * - [PERF] Inline style objects re-created every render
 * - [REACT] Missing Error Boundary wrapper
 */

import { Zap, Shield, Gauge } from 'lucide-react'

const features = [
  {
    icon: Zap,
    title: 'Lightning Fast',
    description: 'Optimized build pipeline that reduces deployment time by 10x.',
    color: '#f59e0b',
  },
  {
    icon: Shield,
    title: 'Secure by Default',
    description: 'Enterprise-grade security with zero-trust architecture built in.',
    color: '#10b981',
  },
  {
    icon: Gauge,
    title: 'Real-time Metrics',
    description: 'Monitor performance, errors, and user behavior in real time.',
    color: '#6366f1',
  },
]

export default function FeatureCards() {
  return (
    <section style={{
      padding: '80px 32px',
      background: '#f1f5f9',
    }}>
      <h2 style={{
        textAlign: 'center',
        fontSize: '36px',
        fontWeight: 700,
        marginBottom: '48px',
        color: '#1e293b',
      }}>
        Why teams choose us
      </h2>

      <div style={{
        display: 'flex',
        gap: '24px',
        maxWidth: '1000px',
        margin: '0 auto',
        justifyContent: 'center',
      }}>
        {features.map((feature) => (
          <div
            key={feature.title}
            onClick={() => console.log(feature.title)}
            style={{
              background: '#ffffff',
              borderRadius: '12px',
              padding: '32px',
              width: '300px',
              cursor: 'pointer',
              boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
              transition: 'transform 0.2s ease, box-shadow 0.2s ease',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-4px)'
              e.currentTarget.style.boxShadow = '0 8px 24px rgba(0,0,0,0.15)'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)'
              e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)'
            }}
          >
            <div style={{
              width: '48px',
              height: '48px',
              borderRadius: '10px',
              background: `${feature.color}15`,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              marginBottom: '16px',
            }}>
              <feature.icon size={24} color={feature.color} />
            </div>

            <h3 style={{
              fontSize: '20px',
              fontWeight: 600,
              marginBottom: '8px',
              color: '#1e293b',
            }}>
              {feature.title}
            </h3>

            <p style={{
              fontSize: '14px',
              color: '#94a3b8',
              lineHeight: 1.6,
            }}>
              {feature.description}
            </p>
          </div>
        ))}
      </div>
    </section>
  )
}
