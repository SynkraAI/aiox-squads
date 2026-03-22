# Task: motion-audit

```yaml
id: motion-audit
version: "1.0.0"
title: "Motion Compliance Audit"
description: >
  Audits all animations within a defined scope for compliance with
  the motion design system. Checks that all animations use spring
  physics, have reduced-motion fallbacks, pass the 0.25x speed
  test, and maintain 60fps on target devices. Reports all
  violations with severity and fix recommendations.
elicit: false
owner: motion-eng
executor: motion-eng
outputs:
  - Animation inventory
  - Spring physics compliance check
  - Reduced-motion fallback verification
  - 0.25x speed test results
  - Target device fps measurements
  - Violation report with recommendations
```

---

## When This Task Runs

This task runs when:
- Before a major release, to ensure motion quality across the product
- After a sprint where multiple animations were added
- When motion inconsistency is observed across the product
- During a design system audit
- `*motion-audit` or `*audit-animations` is invoked

This task does NOT run when:
- A single animation needs design (use `animation-design`)
- Spring tuning is needed for one animation (use `spring-config`)
- The scope is visual regression testing (delegate to `@qa-visual`)

---

## Execution Steps

### Step 1: Inventory All Animations in Scope

Create a comprehensive list of every animation in the audited area.

Search for animations by looking for:
- Framer Motion components (`motion.div`, `motion.span`, `AnimatePresence`)
- CSS transitions (`transition:` property in stylesheets)
- CSS animations (`@keyframes`, `animation:` property)
- Reanimated shared values (`useSharedValue`, `useAnimatedStyle`)
- React Spring (`useSpring`, `useTransition`)
- Manual `requestAnimationFrame` calls
- GSAP timelines (`gsap.to`, `gsap.from`)

For each animation found:
| # | Location | Type | Library | Properties Animated | Duration/Spring | Purpose |
|---|----------|------|---------|---------------------|----------------|---------|
| 1 | Modal.tsx:45 | Enter | Framer Motion | opacity, scale, y | spring(200,20) | Modal open |
| 2 | Button.css:12 | Hover | CSS transition | background-color | 150ms ease | Hover feedback |
| 3 | List.tsx:78 | Enter | Framer Motion | opacity, y | spring(150,14) | List stagger |

**Output:** Complete animation inventory table.

### Step 2: Check Spring Physics Compliance

Verify that all animations use physics-based spring motion, not duration-based easing.

**Violations to flag:**

| Severity | Violation | Example |
|----------|----------|---------|
| **Critical** | Linear easing on UI motion | `transition: transform 300ms linear` |
| **High** | Duration-based easing on interactive elements | `transition={{ duration: 0.3, ease: "easeInOut" }}` |
| **Medium** | CSS transition on transform properties | `transition: transform 200ms ease` |
| **Low** | CSS transition on color/opacity only | `transition: background-color 150ms ease` (acceptable for micro-interactions) |
| **Acceptable** | Spring physics on all motion | `transition={{ type: "spring", stiffness: 200 }}` |

**Allowed exceptions:**
- Color transitions can use CSS `transition` with short duration (< 200ms)
- Opacity-only fades can use CSS `transition` (< 200ms)
- SVG path animations may use linear interpolation
- Loading spinners can use CSS `@keyframes` with linear rotation

**Not allowed:**
- Any transform animation (scale, translate, rotate) using `ease-in-out` or `ease`
- Any `duration`-based animation on interactive elements in Framer Motion
- Any fixed-duration animation over 300ms (should be a spring)

**Output:** Compliance results per animation with violation severity.

### Step 3: Verify Reduced-Motion Fallbacks

Check that every animation respects `prefers-reduced-motion: reduce`.

**Testing method:**
1. Enable reduced motion in OS settings
   - macOS: System Settings → Accessibility → Display → Reduce Motion
   - iOS: Settings → Accessibility → Motion → Reduce Motion
   - Windows: Settings → Ease of Access → Display → Show animations
   - Chrome DevTools: Rendering → Emulate CSS media feature → prefers-reduced-motion: reduce
2. Navigate through the entire audited scope
3. Verify each animation behavior

**Expected behavior with reduced motion enabled:**
- Transform animations (translate, scale, rotate): REMOVED completely or replaced with instant state change
- Opacity transitions: SHORTENED to < 150ms
- Scroll-linked animations: REMOVED
- Auto-playing animations: STOPPED
- Decorative animations: REMOVED
- State communication: PRESERVED (color changes, visibility changes still work)

**Violation severity:**
| Severity | Issue |
|----------|-------|
| **Critical** | No reduced-motion check at all — full animation plays regardless |
| **High** | Transform animation still runs with reduced motion (vestibular risk) |
| **Medium** | Animation runs but with reduced intensity (acceptable if short) |
| **Acceptable** | Animation replaced with instant/opacity-only alternative |

**Output:** Reduced-motion compliance results per animation.

### Step 4: Test at 0.25x Speed

Slow all animations to 25% speed and evaluate quality.

**How to apply 0.25x globally:**
```tsx
// Framer Motion: create a speed context
const MotionConfig = ({ children }) => (
  <LazyMotion features={domAnimation}>
    <MotionConfigProvider transition={{ duration: 4 }}> {/* 4x normal */}
      {children}
    </MotionConfigProvider>
  </LazyMotion>
);

// CSS: add to root during testing
* {
  animation-duration: 4s !important;  /* 4x slower */
  transition-duration: 4s !important;
}
```

**Evaluation criteria at 0.25x:**

| Criterion | Pass | Fail |
|-----------|------|------|
| Motion path is smooth | Continuous movement, no jumps | Sudden position changes, "teleporting" |
| Spring overshoot is visible | Slight natural overshoot | No overshoot (dead feel) or excessive bounce |
| Stagger timing is even | Consistent delay between items | Irregular gaps, some items grouping |
| Exit is intentional | Exit animation designed separately | Exit = enter animation reversed |
| No conflicting motion | Elements coordinate movement | Elements fighting or overlapping awkwardly |

**Output:** 0.25x speed test results with pass/fail per animation.

### Step 5: Measure FPS on Target Devices

Profile animation performance on actual target devices.

**Testing protocol:**
1. Identify the 3 most complex animation scenarios in the audited scope
2. Record performance traces for each scenario on each target device
3. Measure minimum fps during animation

**Measurement tool per platform:**
- Web: Chrome DevTools Performance tab, Lighthouse
- iOS: Safari Web Inspector, Xcode Instruments
- Android: Chrome DevTools remote, Android Studio Profiler

**Target devices:**
| Category | Example Device | Min FPS Target |
|----------|---------------|---------------|
| Desktop (high-end) | MacBook Pro M3 | 60fps |
| Desktop (integrated) | Intel laptop | 55fps |
| Mobile (flagship) | iPhone 15 Pro | 60fps |
| Mobile (mid-range) | iPhone SE / Pixel 6a | 50fps |
| Tablet | iPad Air | 60fps |

**Common fps killers:**
- Animating `width`/`height` (triggers layout every frame)
- Multiple simultaneous spring animations on different stacking contexts
- Large element opacity animation (compositing cost)
- Shadow animation (repaint every frame)
- Filter animation (blur, brightness — repaint every frame)

**Output:** FPS measurements per device per animation scenario.

### Step 6: Generate Violation Report

Compile all findings into a prioritized violation report.

**Report format:**
```markdown
## Motion Audit Report — [Scope]

### Summary
- Total animations found: {N}
- Compliant: {N}
- Violations: {N}
  - Critical: {N}
  - High: {N}
  - Medium: {N}
  - Low: {N}

### Critical Violations
| # | File | Line | Issue | Recommended Fix |
|---|------|------|-------|----------------|
| 1 | Modal.tsx | 45 | Uses ease-in-out on scale transform | Replace with spring(200, 20) |

### High Violations
...

### FPS Issues
| Scenario | Device | FPS | Target | Delta |
|----------|--------|-----|--------|-------|
| Modal open with stagger | Pixel 6a | 42 | 50 | -8 |

### Recommendations
1. ...
2. ...
```

**Output:** Complete violation report with prioritized recommendations.

---

## Quality Criteria

- Every animation in scope must be inventoried (none missed)
- Spring compliance must be checked against the specific violations list
- Reduced-motion must be tested with actual OS settings, not just code review
- 0.25x test must evaluate each animation individually
- FPS must be measured on at least one mid-range device

---

*Squad Apex — Motion Compliance Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-motion-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every animation in scope must be inventoried (none missed)"
    - "Reduced-motion must be tested with actual OS settings, not just code review"
    - "FPS must be measured on at least one mid-range device"
    - "Report must contain at least one actionable finding or explicit all-clear"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Motion compliance audit report with violation inventory, fps measurements, and prioritized recommendations |
| Next action | Route critical/high violations to `@motion-eng` for remediation or approve motion quality for release |
