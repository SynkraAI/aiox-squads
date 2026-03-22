# Apex Squad — Knowledge Base

> Version: 1.0
> Maintained by: apex-lead
> Scope: Authoritative reference for squad philosophy, standards, and patterns.

---

## 1. Squad Philosophy and Principles

The Apex squad exists to make the product feel **fast, beautiful, and trustworthy** on every surface — web, mobile, and spatial. We do not ship average. We ship the kind of UI that users describe to friends.

### Core Principles

**1. Feel before function.**
Performance and correctness are table stakes. The squad's differentiator is the quality of the felt experience — timing, spring weight, color warmth, and the micro-interactions that reward attention.

**2. Tokens are law.**
Every visual decision — color, spacing, shadow, radius, duration — lives in the design token system. Hardcoded values are defects, not shortcuts. A value not in the token system does not exist yet and must be added through proper process.

**3. Accessibility is not optional.**
WCAG 2.2 AA is the minimum. AAA for primary text and high-stakes flows. Keyboard and screen reader support is built-in from the first commit, never retrofitted.

**4. Reduced motion is a first-class user.**
Every animation has a `prefers-reduced-motion` implementation. We do not gate entire features on motion. We substitute.

**5. Performance is a design constraint.**
LCP, INP, and CLS targets are set before implementation begins. Bundle size is a UX decision. Every kilobyte justifies itself.

**6. Ship in layers.**
Core functionality ships clean. Polish iterates on top. No feature waits forever for perfect motion — but no motion ships that breaks reduced-motion users.

---

## 2. Tech Stack Overview

See `data/tech-stack.md` for the complete reference. Summary:

| Layer | Primary |
|-------|---------|
| Web Framework | Next.js 15+ (App Router, Edge Runtime) |
| UI Library | React 19+ with Server Components |
| Language | TypeScript 5.x strict mode |
| Styling | Tailwind CSS 4 + CVA |
| Primitive Components | Radix UI / Ark UI |
| Motion | Framer Motion + GSAP + Rive |
| 3D | Three.js + React Three Fiber |
| Mobile | React Native 0.80+ New Arch + Expo 52+ |
| Build | Turborepo + pnpm + Turbopack |

---

## 3. Design Token System

Tokens follow a strict 3-tier hierarchy. Violating the hierarchy is a defect.

### Tier 1 — Primitive Tokens
Raw values. Never used directly in component code.

```
color.blue.500 = #3B82F6
spacing.4 = 16px
radius.2 = 8px
duration.200 = 200ms
```

### Tier 2 — Semantic Tokens
Intent-mapped aliases of primitives. These are what components consume.

```
color.action.primary = color.blue.500
color.surface.default = color.neutral.0 (light) / color.neutral.950 (dark)
spacing.component.padding.md = spacing.4
radius.component.card = radius.2
duration.interaction.hover = duration.200
```

### Tier 3 — Component Tokens
Component-specific overrides. Use only when a component's token cannot map cleanly to a semantic token.

```
button.background.primary.default = color.action.primary
button.border.radius = radius.squircle.md
```

### Token Files
- Source: `packages/design-tokens/src/`
- Build output: `packages/design-tokens/dist/` (CSS variables, JS object, mobile theme)
- Tooling: Style Dictionary
- Platform outputs: CSS custom properties (web), JS constants (web runtime), React Native StyleSheet values (mobile)

### Token Naming Convention
`{tier}.{category}.{variant}.{state}`

Examples:
- `color.surface.elevated.default`
- `color.text.on-action.disabled`
- `spacing.layout.section.gap`
- `motion.spring.snappy.stiffness`

---

## 4. Motion Language

The Apex motion language defines how the product moves. All motion decisions originate here.

### Spring Profiles

| Profile | Stiffness | Damping | Mass | Use Case |
|---------|-----------|---------|------|----------|
| `gentle` | 120 | 14 | 1 | Large panels, page transitions |
| `default` | 200 | 20 | 1 | Standard UI elements |
| `snappy` | 300 | 24 | 1 | Micro-interactions, hover |
| `bouncy` | 400 | 12 | 1 | Playful confirms, success states |
| `stiff` | 500 | 30 | 1 | Tooltips, instant-feel overlays |

### Duration Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `duration.instant` | 80ms | Hover color changes |
| `duration.fast` | 150ms | Micro-interactions |
| `duration.base` | 250ms | Standard transitions |
| `duration.slow` | 400ms | Modals, large panels |
| `duration.crawl` | 600ms | Page-level choreography |

### Choreography Rules
1. **Enter before exit.** New content arrives before old content leaves (cross-fade pattern).
2. **Stagger children.** List items stagger at `stagger.base = 40ms` delay between items.
3. **Orchestrate outside-in.** Container animates first, then children.
4. **Exit is faster than enter.** Exit duration = enter duration * 0.6.

### Reduced Motion Substitutes
| Animation | Reduced-Motion Substitute |
|-----------|--------------------------|
| Scale in/out | Opacity fade only |
| Slide in/out | Opacity fade only |
| Stagger | All items appear simultaneously |
| Continuous loops | Paused at first frame |
| Parallax scroll | Disabled (static) |

---

## 5. Accessibility Standards

### Compliance Targets
- **Primary target:** WCAG 2.2 Level AA (all features)
- **Elevated target:** WCAG 2.2 Level AAA for body text, form labels, and high-stakes CTAs
- **Testing tools:** axe-core (automated, 0 violations required), VoiceOver, NVDA, TalkBack

### Color Contrast Requirements
| Context | Minimum Ratio | Target |
|---------|--------------|--------|
| Normal text (< 18px) | 4.5:1 (AA) | 7:1 (AAA) |
| Large text (>= 18px regular, >= 14px bold) | 3:1 (AA) | 4.5:1 |
| UI components and focus indicators | 3:1 (AA) | 4.5:1 |
| Decorative elements | None | — |

### Keyboard Interaction Patterns
Follow the ARIA Authoring Practices Guide (APG) for all composite widgets:
- **Menu:** Arrow keys navigate, Enter activates, Escape closes
- **Dialog:** Focus trapped, Escape closes, focus returns to trigger
- **Tabs:** Arrow keys switch tabs, Tab moves to panel
- **Listbox / Combobox:** APG spec implemented exactly
- **Grid/Table:** Arrow key navigation within cells

### Focus Management Rules
- Focus ring: minimum 3px offset, 3:1 contrast against adjacent color
- Modals: focus moves to first focusable element on open
- Route transitions: focus moves to main heading or `<main>` on navigation
- Dynamic insertions: focus moves to new content only if user-triggered

---

## 6. Performance Budgets

These are hard budgets. Exceeding them blocks ship.

### Web Core Web Vitals (Mobile)
| Metric | Budget | Tool |
|--------|--------|------|
| LCP | <= 2.5s | Lighthouse CI |
| INP | <= 200ms | Lighthouse CI / CrUX |
| CLS | <= 0.1 | Lighthouse CI |
| FCP | <= 1.8s | Lighthouse CI |
| Lighthouse Score | >= 90 | Lighthouse CI |

### Bundle Size
| Artifact | Budget |
|----------|--------|
| Initial JS (gzipped) | <= 150kb |
| Per-route JS chunk (gzipped) | <= 50kb |
| CSS (gzipped) | <= 30kb |
| Total page weight (images excluded) | <= 300kb |

### Runtime
| Metric | Budget |
|--------|--------|
| Animation frame time | <= 16ms (60fps) |
| Input handler time | <= 50ms |
| React render time (component) | <= 10ms |
| Time to Interactive | <= 3.5s (mobile 4G) |

---

## 7. Cross-Platform Strategy

The Apex squad ships on 3 surfaces. Code is shared where possible; platform-specific implementations are explicitly chosen, not incidental.

### Web (Next.js App Router)
- RSC for data-heavy pages (no client bundle cost)
- Client components only when interactivity or browser APIs required
- Edge Runtime for latency-sensitive routes
- ISR for content pages; dynamic rendering for personalized pages

### Mobile (React Native + Expo)
- Shared business logic and design tokens via monorepo packages
- Platform-specific UI components where native feel requires it (do not force web patterns on mobile)
- Reanimated 4 for all gesture-driven animations (not Framer Motion)
- Expo Router for navigation
- New Architecture (JSI) required — no legacy bridge allowed

### Spatial (Vision Pro)
- Spatial layouts avoid hover-only interactions (no hover state as primary UI)
- Eye-tracking tap targets >= 60px
- Depth used intentionally — not decorative
- Reviewed in visionOS simulator before any spatial feature ships

### Shared Packages (Monorepo)
- `packages/design-tokens` — tokens for all platforms
- `packages/ui` — web component library
- `packages/ui-native` — React Native component library
- `packages/utils` — platform-agnostic utilities

---

## 8. Quality Gates Summary

| Gate | Owner | Tool | Pass Criteria |
|------|-------|------|--------------|
| Visual Review | apex-lead | Figma overlay, browser | visual-review-checklist.md fully checked |
| Component Quality | apex-lead | Manual + Storybook | component-quality-checklist.md fully checked |
| Automated Tests | @qa | Vitest, Playwright | 0 failing tests |
| Accessibility | @qa | axe-core | 0 violations |
| Visual Regression | apex-lead | Chromatic | 0 unexpected changes |
| Performance | @qa | Lighthouse CI | All budgets met |
| Ship Readiness | apex-lead + @qa | Manual gate | ship-readiness-checklist.md fully checked |

All gates must pass before `@devops` is requested to push or create a PR.

---

## 9. Escalation and Decisions

- **Design token additions:** apex-lead approves; PRD team notified
- **New external dependency:** apex-lead + @architect approval required
- **Performance budget exception:** apex-lead + @pm sign-off, time-boxed with remediation date
- **Accessibility waiver:** Never accepted without documented user research justification
- **Motion exception (no reduced-motion support):** Never accepted
