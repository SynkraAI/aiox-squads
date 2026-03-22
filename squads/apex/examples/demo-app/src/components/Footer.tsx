/**
 * Footer — INTENTIONAL ISSUES FOR APEX DEMO:
 * - [A11Y] Links are divs, not <a> elements
 * - [A11Y] Low contrast text
 * - [CSS] Hardcoded values everywhere
 */

export default function Footer() {
  return (
    <footer style={{
      padding: '40px 32px',
      borderTop: '1px solid #e2e8f0',
      textAlign: 'center',
    }}>
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        gap: '24px',
        marginBottom: '16px',
      }}>
        {['Privacy', 'Terms', 'Support'].map((link) => (
          <div
            key={link}
            onClick={() => {}}
            style={{
              color: '#94a3b8',
              cursor: 'pointer',
              fontSize: '14px',
            }}
          >
            {link}
          </div>
        ))}
      </div>
      <p style={{ color: '#cbd5e1', fontSize: '13px' }}>
        2026 ApexDemo. All rights reserved.
      </p>
    </footer>
  )
}
