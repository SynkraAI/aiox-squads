/**
 * Contact form — INTENTIONAL ISSUES FOR APEX DEMO:
 * - [A11Y] Inputs without associated <label> elements (placeholder-only)
 * - [A11Y] Submit button is a <div>, not <button type="submit">
 * - [A11Y] No form validation feedback for screen readers
 * - [CSS] Hardcoded colors throughout
 * - [REACT] Form state could use useActionState (React 19)
 */

import { useState } from 'react'

export default function ContactForm() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState('')
  const [sent, setSent] = useState(false)

  const handleSubmit = () => {
    if (!name || !email || !message) return
    setSent(true)
  }

  if (sent) {
    return (
      <section style={{ padding: '80px 32px', textAlign: 'center' }}>
        <div style={{ fontSize: '48px', marginBottom: '16px' }}>✓</div>
        <h2 style={{ fontSize: '28px', fontWeight: 700, color: '#1e293b' }}>
          Message sent!
        </h2>
        <p style={{ color: '#94a3b8', marginTop: '8px' }}>
          We'll get back to you within 24 hours.
        </p>
      </section>
    )
  }

  return (
    <section style={{
      padding: '80px 32px',
      maxWidth: '600px',
      margin: '0 auto',
    }}>
      <h2 style={{
        fontSize: '36px',
        fontWeight: 700,
        textAlign: 'center',
        marginBottom: '32px',
        color: '#1e293b',
      }}>
        Get in touch
      </h2>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <input
          type="text"
          placeholder="Your name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{
            padding: '12px 16px',
            borderRadius: '8px',
            border: '1px solid #e2e8f0',
            fontSize: '16px',
            outline: 'none',
          }}
        />
        <input
          type="email"
          placeholder="Email address"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={{
            padding: '12px 16px',
            borderRadius: '8px',
            border: '1px solid #e2e8f0',
            fontSize: '16px',
            outline: 'none',
          }}
        />
        <textarea
          placeholder="Your message"
          rows={4}
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          style={{
            padding: '12px 16px',
            borderRadius: '8px',
            border: '1px solid #e2e8f0',
            fontSize: '16px',
            outline: 'none',
            resize: 'vertical',
          }}
        />
        <div
          onClick={handleSubmit}
          style={{
            background: '#6366f1',
            color: 'white',
            padding: '14px',
            borderRadius: '8px',
            textAlign: 'center',
            cursor: 'pointer',
            fontWeight: 600,
            fontSize: '16px',
            transition: 'background 0.2s ease',
          }}
        >
          Send Message
        </div>
      </div>
    </section>
  )
}
