# Apex Squad — Real Session Log

> This is an edited session log showing Apex Squad in action on a real React + Vite project.
> Sensitive project data has been removed. The flow and outputs are real.

---

## Session 1: Discovery + Fix Cycle

### 1. User activates Apex

```
User: @apex "como ta a acessibilidade?"

Emil: Scanning project...
  Stack: React 19 + Vite + Tailwind CSS 4 + Motion + Lucide
  Profile: web-spa (8 agents active)
  Components: 12 found

  Routing to *discover-a11y — this is a static accessibility scan.
```

### 2. Apex runs a11y discovery

```
Emil: Delegating to Sara (@a11y-eng) — static WCAG scan.

Sara aqui. Scanning 12 components for WCAG 2.2 compliance.

A11y Discovery Report
=====================
Health Score: 42/100

CRITICAL (3):
  - Header.tsx:28 — Interactive <div> without keyboard support (WCAG 2.1.1)
  - ContactForm.tsx:62 — Submit is <div>, not <button> (WCAG 4.1.2)
  - ContactForm.tsx:45-57 — 3 inputs without <label> (WCAG 1.3.1)

HIGH (4):
  - HeroSection.tsx:42 — Text contrast 2.5:1, needs 4.5:1 (WCAG 1.4.3)
  - FeatureCards.tsx:52 — Clickable cards without role="button" (WCAG 4.1.2)
  - Header.tsx:22 — Nav links are divs, not <a>/<button> (WCAG 4.1.2)
  - Footer.tsx:18 — Footer links are divs (WCAG 4.1.2)

MEDIUM (2):
  - HeroSection.tsx:52 — Decorative image needs alt="" (WCAG 1.1.1)
  - App.tsx — No skip-to-content link (WCAG 2.4.1)

Summary: 3 CRITICAL | 4 HIGH | 2 MEDIUM

Next:
  1. Fix critical issues first
  2. Run full *discover-components
  3. Done

What do you prefer?
```

### 3. User chooses to fix

```
User: 1

Emil: Fixing 3 critical a11y issues — staying with Sara (@a11y-eng).

Sara aqui. Fixing critical issues:

  1. Header.tsx — Changed nav <div> to <button> with onKeyDown={Enter/Space}
  2. ContactForm.tsx — Changed submit <div> to <button type="submit">
  3. ContactForm.tsx — Added <label> to all 3 inputs (visually hidden, sr-only)

3 files modified. typecheck PASS. lint PASS.

Next:
  1. Fix HIGH issues too
  2. Run *discover-motion
  3. Done

What do you prefer?
```

### 4. User asks for motion discovery

```
User: 2

Emil: Delegating to Matt (@motion-eng) — animation inventory.

Matt aqui. Scanning for motion patterns.

Motion Discovery Report
=======================
Health Score: 35/100

VETO VIOLATIONS (2):
  - FeatureCards.tsx:58 — CSS transition for hover, should be spring (QG-AX-006)
  - Header.tsx:37 — CSS transition for color, should be spring (QG-AX-006)

MISSING (3):
  - HeroSection.tsx — No entrance animation on hero content
  - FeatureCards.tsx — No stagger animation on cards
  - prefers-reduced-motion — Not handled anywhere (QG-AX-005)

CSS Transitions: 4 found (all should be springs)
Spring Configs: 0 found
Framer Motion usage: 0 components (installed but unused)

Next:
  1. Convert transitions to springs + add entrance animations
  2. Run *discover-performance
  3. Done

What do you prefer?
```

### 5. User asks to fix motion

```
User: 1

Matt aqui. Converting to springs and adding entrances:

  1. FeatureCards.tsx — Replaced CSS hover with motion.div + whileHover spring
  2. Header.tsx — Added spring transition for active state
  3. HeroSection.tsx — Added motion.div entrance (opacity + y, spring damping:20)
  4. FeatureCards.tsx — Added stagger animation (staggerChildren: 0.1)
  5. All components — Added prefers-reduced-motion check

5 files modified. typecheck PASS. lint PASS.

Next:
  1. Run suggestions on modified files
  2. Run *discover-design
  3. Done

What do you prefer?
```

---

## Session 2: Style Transform

### 1. User wants to explore styles

```
User: @apex "mostra estilos disponiveis"

Emil: Opening preset catalog via *apex-inspire.

31 Design Presets Available:

APPLE (3):
  1. apple-liquid-glass — Frosted glass, depth, fluid typography
  2. apple-hig — Standard HIG with SF Pro, system colors
  3. apple-visionos — Spatial UI, glass layers, 3D depth

GOOGLE (2):
  4. material-3 — Material Design 3, dynamic color, elevation
  5. material-you — Personalized Material with user color extraction

TECH COMPANIES (7):
  6. linear-style — Ultra-clean, keyboard-first, monospace accents
  7. vercel-style — Black/white, geometric, code-focused
  ...

Type a number to preview, or:
  *apex-transform --style {id} — Apply directly
```

### 2. User applies a style

```
User: *apex-transform --style linear-style

Emil: Scanning current design tokens...

Current: Custom (adhoc, no design system)
Target: Linear Style

Transform Plan:
  @design-sys-eng (Diana) — Generate token set
  @css-eng (Josh) — Apply CSS variables
  @motion-eng (Matt) — Configure motion (snappy springs, subtle)
  @a11y-eng (Sara) — Verify contrast meets WCAG AA

Estimated: 4 agents, ~8 files modified

Proceed? (yes/no)

User: yes

Diana: Generating Linear token set...
  --primary: #5E6AD2, --bg: #0A0A0B, --card: #1A1A1E, --text: #E8E8ED
  --radius: 8px, --font: Inter, --mono: JetBrains Mono
  Typography scale: 13/14/16/20/28px
  12 tokens generated.

Josh: Applying tokens to all components...
  index.css — Updated :root variables
  Header.tsx — Using var(--primary), var(--bg)
  All components — Replaced hardcoded values with tokens
  8 files updated.

Matt: Configuring Linear motion...
  Spring config: stiffness:400, damping:30 (snappy)
  Hover: scale(1.02), not translateY
  Transitions: 150ms max

Sara: Contrast check...
  All text passes WCAG AA on dark background.
  Primary (#5E6AD2) on dark (#0A0A0B) = 5.8:1 PASS

Transform complete.
  4 agents involved. 8 files modified. typecheck PASS.

  Before: adhoc (DS Score 20/100)
  After: Linear Style (DS Score 92/100)

Next:
  1. Run suggestions
  2. Try another style
  3. Done
```

---

## Key Takeaways

1. **Natural language in, structured action out** — User never typed a command name, Apex auto-routed
2. **Visible handoffs** — Every agent delegation was announced, user always knew WHO was working
3. **Discovery before action** — Apex scanned the codebase before suggesting fixes
4. **User always in control** — Every step ended with options, nothing auto-executed
5. **Intent chaining** — After each operation, Apex suggested the logical next step
6. **Quality gates enforced** — Veto conditions (QG-AX-005, QG-AX-006) were flagged as violations
