/**
 * Header component — INTENTIONAL ISSUES FOR APEX DEMO:
 * - [A11Y] Nav links are divs with onClick instead of <a> or <button>
 * - [A11Y] No keyboard navigation (no tabIndex, no onKeyDown)
 * - [CSS] Hardcoded colors instead of CSS variables
 * - [CSS] No responsive handling — breaks on mobile
 * - [MOTION] Uses CSS transition instead of spring
 */

import { useState } from 'react'

export default function Header() {
  const [active, setActive] = useState('home')

  return (
    <header style={{
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: '16px 32px',
      background: '#ffffff',
      borderBottom: '1px solid #e2e8f0',
      position: 'sticky',
      top: 0,
      zIndex: 100,
    }}>
      <div style={{ fontSize: '20px', fontWeight: 700, color: '#6366f1' }}>
        ApexDemo
      </div>

      <nav style={{ display: 'flex', gap: '24px' }}>
        {['home', 'features', 'contact'].map((item) => (
          <div
            key={item}
            onClick={() => setActive(item)}
            style={{
              cursor: 'pointer',
              color: active === item ? '#6366f1' : '#64748b',
              fontWeight: active === item ? 600 : 400,
              textTransform: 'capitalize',
              transition: 'color 0.3s ease',
            }}
          >
            {item}
          </div>
        ))}
      </nav>

      <div
        onClick={() => alert('CTA clicked')}
        style={{
          background: '#6366f1',
          color: 'white',
          padding: '8px 20px',
          borderRadius: '8px',
          cursor: 'pointer',
          fontSize: '14px',
          fontWeight: 600,
          transition: 'background 0.2s ease',
        }}
      >
        Get Started
      </div>
    </header>
  )
}
