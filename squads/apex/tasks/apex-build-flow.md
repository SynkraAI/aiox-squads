# Task: apex-build-flow

```yaml
id: apex-build-flow
version: "1.0.0"
title: "Apex Build Flow"
description: >
  Implement an approved design specification across all target platforms.
  Takes the output of apex-design-flow as its input and produces a fully
  implemented, polished, accessible, and performant feature ready for QA.
elicit: true
owner: apex-lead
agents:
  architecture: frontend-arch
  web: [react-eng, css-eng]
  mobile: mobile-eng
  cross_platform: cross-plat-eng
  spatial: spatial-eng
  polish_motion: motion-eng
  polish_a11y: a11y-eng
  polish_perf: perf-eng
quality_gates:
  - QG-AX-003
  - QG-AX-004
  - QG-AX-005
  - QG-AX-006
  - QG-AX-007
requires:
  - apex-design-flow outputs (QG-AX-001 and QG-AX-002 must be PASSED)
outputs:
  - Implemented components across target platforms
  - Unit and integration tests
  - Storybook stories for all states
  - Updated token files (if new tokens were created)
```

---

## Inputs

This task requires the following artifacts from `apex-design-flow`:

| Input | Source | Required |
|-------|--------|----------|
| `design-spec.md` | apex-design-flow Step 1 | Yes |
| `token-map.yaml` | apex-design-flow Step 2 | Yes |
| `component-api.ts` | apex-design-flow Step 2 | Yes |
| `responsive-variants.md` | apex-design-flow Step 1 | Yes |
| `QG-AX-001` verdict | apex-design-flow | PASS required |
| `QG-AX-002` verdict | apex-design-flow | PASS required |
| `target_platforms` | config / story | Yes |

### Elicitation

If the design artifacts are missing, halt and request:

```
Apex Build Flow — Missing Design Artifacts

This task requires completed design flow outputs.
Please run apex-design-flow first, or provide:

1. Path to design-spec.md:
   > {user input}

2. Path to token-map.yaml:
   > {user input}

3. Target platforms for this build (web / mobile / spatial):
   > {user input}

4. Has apex-design-flow QG-AX-001 and QG-AX-002 passed?
   > {yes / no}
```

If QG-AX-001 or QG-AX-002 have not passed, BLOCK this task and return to
the design flow.

**Automated Verification (before proceeding):**
The following artifacts MUST exist — this is verified automatically, not by asking the executor:
- `docs/design/{story_id}-spec.md` must exist and be non-empty
- `docs/design/{story_id}-token-delta.md` must exist and be non-empty
- Design spec must contain "APPROVED" marker

```bash
# Automated artifact verification — run BEFORE trusting executor answers
test -s "docs/design/${STORY_ID}-spec.md" || { echo "BLOCK: design spec missing or empty"; exit 1; }
test -s "docs/design/${STORY_ID}-token-delta.md" || { echo "BLOCK: token delta missing or empty"; exit 1; }
grep -q "APPROVED" "docs/design/${STORY_ID}-spec.md" || { echo "BLOCK: design spec not APPROVED"; exit 1; }
```

If any artifact is missing, BLOCK and return to apex-design-flow. Do not proceed based on executor confirmation alone.

---

## Execution

### Step 1 — Architecture (@frontend-arch)

**Agent:** Arch (frontend-arch)
**Input:** `design-spec.md`, `component-api.ts`, `target_platforms`
**Deliverable:** Architecture decision + monorepo structure definition

#### 1.1 — Monorepo Placement Decision

Determine where the component lives:

```yaml
placement:
  question: "Is this component shared across multiple apps or app-specific?"
  shared: "packages/ui/src/patterns/{ComponentName}/"
  app_specific_web: "apps/web/components/{ComponentName}/"
  app_specific_mobile: "apps/mobile/components/{ComponentName}/"
```

**Decision rules:**
- If it will be used in 2+ apps → `packages/ui`
- If it is only for web → `apps/web/components`
- If it is only for mobile → `apps/mobile/components`
- If it is only for spatial → `apps/spatial/scenes` or equivalent

#### 1.2 — RSC Boundary Decision

For web components, decide the server/client split:

```
Is this component interactive (onClick, useState, browser APIs)?
├── NO → React Server Component (default, zero client JS)
│   └── Example: ProductCard, ArticleBody, NavigationLinks
└── YES → Client Component ('use client')
    └── Can we split static parts out?
        ├── YES → Server wrapper + Client island
        │   └── Example: <ProductCard> (RSC) wrapping <AddToCartButton> (client)
        └── NO → Full client component
            └── Justify in architecture decision
```

For each `use client` directive, produce a justification:

```yaml
client_boundary:
  file: "components/SearchBar/SearchInput.tsx"
  reason: "Requires controlled input state (useState) and keyboard event handlers"
  alternatives_considered: "Server action with form — rejected because real-time filtering requires immediate client state"
  bundle_impact: "~2.4KB gzipped"
```

#### 1.3 — Performance Budget Allocation

Before any implementation begins, define the performance budget for this feature:

```yaml
performance_budget:
  feature: "{FeatureName}"
  js_budget: "{X}KB"  # Additional JS allowed (gzipped)
  css_budget: "{X}KB" # Additional CSS allowed (gzipped)
  lcp_impact: "none | low | medium"  # Does this affect LCP?
  cls_risk: "none | low | medium"    # Does this risk layout shift?
  notes: "{any constraints or considerations}"
```

**Constraint:** The feature's JS contribution must keep the total first load JS under 80KB gzipped.

#### 1.4 — File Structure

Define the exact file structure before any agent writes code:

```
packages/ui/src/patterns/{ComponentName}/
├── index.ts                   # Public exports
├── {ComponentName}.tsx        # Main component (RSC or client)
├── {ComponentName}.client.tsx # Client island (if needed)
├── {ComponentName}.module.css # Component styles (CSS Modules)
├── {ComponentName}.stories.tsx # Storybook stories
├── {ComponentName}.test.tsx   # Unit tests
└── types.ts                   # TypeScript types (re-exports component-api.ts)
```

---

### Step 2 — Platform Implementation

Implementation runs per platform. For each target platform listed in `target_platforms`,
the relevant agent implements the component following the approved design spec.

#### 2A — Web Implementation (@react-eng + @css-eng)

**Agents:** Kent (react-eng) + Josh (css-eng)

**Kent (react-eng) implements:**

```typescript
// Pattern: Server wrapper + Client island

// {ComponentName}.tsx — Server Component (default)
import { ComponentNameClient } from './{ComponentName}.client';
import styles from './{ComponentName}.module.css';

interface ComponentNameProps {
  // from component-api.ts
}

export function ComponentName({ ...props }: ComponentNameProps) {
  // Fetch data server-side here
  // Pass serializable data to client island
  return (
    <div className={styles.root}>
      <ComponentNameClient {...props} />
    </div>
  );
}

// {ComponentName}.client.tsx — Client Component (interactive parts only)
'use client';

import { useState, useCallback } from 'react';
import { motion } from 'framer-motion';

export function ComponentNameClient({ ...props }) {
  const [state, setState] = useState(/* initial */);
  // Event handlers, local state, browser APIs
}
```

**State management rules (Kent's framework):**
- Server state → RSC or React Query / SWR
- UI state → `useState` (local) or Jotai (shared)
- Form state → React Hook Form
- URL state → `useSearchParams` / `useRouter`
- Never use `useEffect` for data fetching — use RSC or React Query

**Josh (css-eng) implements:**

```css
/* {ComponentName}.module.css */

/* Use design tokens as CSS custom properties — never hardcode */
.root {
  /* Spacing from token-map.yaml */
  padding-block: var(--spacing-3);    /* 12px */
  padding-inline: var(--spacing-4);   /* 16px */

  /* Color from token-map.yaml */
  background-color: var(--color-background-surface);
  border: 1px solid var(--color-border-subtle);

  /* Typography from token-map.yaml */
  font-size: var(--text-sm-size);
  line-height: var(--text-sm-leading);

  /* Radius from token-map.yaml */
  border-radius: var(--radius-md);

  /* Layout */
  display: grid;
  grid-template-columns: {as specified in responsive-variants.md};
}

/* Responsive — mobile-first */
@container ({breakpoint}) {
  .root { /* tablet+ adjustments */ }
}

/* Theme modes — use @media not class selectors */
@media (prefers-color-scheme: dark) {
  /* Tokens automatically switch — no overrides needed */
}

@media (prefers-contrast: more) {
  /* High-contrast tokens automatically apply */
}

/* Interaction states */
.root:hover { background-color: var(--color-background-hover); }
.root:focus-visible { outline: 2px solid var(--color-border-focus); }
.root:active { background-color: var(--color-background-pressed); }
```

**CSS rules (Josh's principles):**
- CSS Modules only — no global styles, no inline styles, no Tailwind in components
- Container queries over media queries for component-level responsiveness
- No `z-index` values without a comment explaining the stacking context
- No `!important` — fix the specificity instead
- Cascade layers for third-party CSS isolation

#### 2B — Mobile Implementation (@mobile-eng)

**Agent:** Krzysztof (mobile-eng)

Mobile implementation runs on the UI thread. All animations are Reanimated 3 worklets.

```typescript
// {ComponentName}.native.tsx — React Native implementation

import { StyleSheet, Pressable } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

// Spring config from motion tokens
const SPRING_SNAPPY = {
  stiffness: 500,
  damping: 25,
  mass: 0.8,
};

export function ComponentName({ onAction, isDisabled, ...props }) {
  const scale = useSharedValue(1);

  // Worklet — runs on UI thread, not JS thread
  const handlePressIn = () => {
    'worklet';
    scale.value = withSpring(0.97, SPRING_SNAPPY);
  };

  const handlePressOut = () => {
    'worklet';
    scale.value = withSpring(1, SPRING_SNAPPY);
  };

  const handlePress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    onAction?.();
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      onPress={handlePress}
      disabled={isDisabled}
      accessibilityRole="button"
      accessibilityLabel={props['aria-label']}
    >
      <Animated.View style={[styles.root, animatedStyle]}>
        {/* content */}
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  root: {
    // All values must be from the design token map
    // Import from packages/tokens
    paddingVertical: 12,  // spacing.3
    paddingHorizontal: 16, // spacing.4
    borderRadius: 8,       // radius.md
    minHeight: 44,         // WCAG 2.5.8 touch target minimum
    minWidth: 44,
  },
});
```

**Mobile implementation rules:**
- All animations in worklets (`'worklet'` annotation)
- Minimum touch target 44x44px (WCAG 2.5.8)
- Haptic feedback for all primary interactions
- Gesture Handler for any swipe, pinch, or drag
- `accessibilityRole` and `accessibilityLabel` required

#### 2C — Cross-Platform Coordination (@cross-plat-eng)

**Agent:** Fernando (cross-plat-eng)

Fernando ensures web and mobile implementations share as much code as possible:

```typescript
// packages/ui/src/patterns/{ComponentName}/index.ts
// Platform-agnostic export — consumer gets the right version

export { ComponentName } from './{ComponentName}';

// Platform resolution (Expo/Metro handles .native.tsx extension):
// On web  → ./{ComponentName}.tsx
// On native → ./{ComponentName}.native.tsx
```

**Cross-platform shared code (in packages/utils or packages/hooks):**
```typescript
// Shared logic — no platform dependencies
export function use{ComponentName}State(initialValue) {
  // Business logic shared between web and native
  // No DOM or React Native APIs here
}
```

#### 2D — Spatial Implementation (@spatial-eng)

**Agent:** Paul (spatial-eng) — only if `spatial` is in `target_platforms`

```typescript
// {ComponentName}.spatial.tsx — React Three Fiber implementation

import { useRef } from 'react';
import { useSpring, animated } from '@react-spring/three';
import { Text, RoundedBox } from '@react-three/drei';
import { useXR } from '@react-three/xr';

export function ComponentNameSpatial({ position, onAction, ...props }) {
  const meshRef = useRef();
  const { isPresenting } = useXR();

  // Spring physics for 3D transforms
  const [springs, api] = useSpring(() => ({
    scale: [1, 1, 1],
    config: { stiffness: 300, damping: 20 },
  }));

  const handlePointerOver = () => api.start({ scale: [1.05, 1.05, 1.05] });
  const handlePointerOut = () => api.start({ scale: [1, 1, 1] });
  const handleClick = () => {
    api.start({ scale: [0.97, 0.97, 0.97] });
    setTimeout(() => api.start({ scale: [1, 1, 1] }), 100);
    onAction?.();
  };

  return (
    <animated.group scale={springs.scale} position={position}>
      <RoundedBox
        ref={meshRef}
        onPointerOver={handlePointerOver}
        onPointerOut={handlePointerOut}
        onClick={handleClick}
      >
        <meshStandardMaterial color={/* token */} />
      </RoundedBox>
      <Text>{props.label}</Text>
    </animated.group>
  );
}
```

---

### Step 3 — Motion Polish (@motion-eng)

**Agent:** Matt (motion-eng)
**Input:** Implemented components from Step 2
**Deliverable:** Spring animations added, orchestration defined, reduced-motion fallbacks

Matt reviews every animation in the implementation and upgrades or replaces them
with spring-physics-based motion following the design spec.

#### 3.1 — Animation Inventory

List every animation present in the implementation:

```yaml
animations:
  - id: "modal-enter"
    current: "transition: opacity 0.3s ease, transform 0.3s ease"
    verdict: "REPLACE — bezier curves, not spring physics"
    replacement: "spring gentle (stiffness: 120, damping: 14)"

  - id: "button-press"
    current: "transition: transform 0.1s ease-out"
    verdict: "REPLACE — wrong physics preset for feedback"
    replacement: "spring snappy (stiffness: 500, damping: 25, mass: 0.8)"

  - id: "list-item-enter"
    current: "none"
    verdict: "ADD — items should enter with stagger"
    addition: "spring responsive with 30ms stagger per child"
```

#### 3.2 — Spring Implementation (Framer Motion — web)

```typescript
// Web animation with Framer Motion (spring physics)

import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';

// Motion tokens from packages/tokens
import { springGentleConfig, springSnappyConfig } from '@repo/tokens/motion';

function AnimatedComponent({ isVisible, children }) {
  const shouldReduceMotion = useReducedMotion();

  // Reduced motion: instant state change
  const variants = shouldReduceMotion
    ? {
        initial: { opacity: 0 },
        animate: { opacity: 1 },
        exit: { opacity: 0, transition: { duration: 0.15 } },
      }
    : {
        initial: { opacity: 0, scale: 0.95, y: 8 },
        animate: {
          opacity: 1,
          scale: 1,
          y: 0,
          transition: { type: 'spring', ...springGentleConfig },
        },
        exit: {
          opacity: 0,
          scale: 0.95,
          transition: { duration: 0.15 },
        },
      };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          key="content"
          variants={variants}
          initial="initial"
          animate="animate"
          exit="exit"
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

#### 3.3 — Choreography for Multi-Element Sequences

```typescript
// Staggered list entrance
const containerVariants = {
  animate: {
    transition: {
      staggerChildren: 0.03, // 30ms between each child
    },
  },
};

const itemVariants = {
  initial: { opacity: 0, y: 12 },
  animate: {
    opacity: 1,
    y: 0,
    transition: { type: 'spring', stiffness: 300, damping: 20 },
  },
};
```

#### 3.4 — Quality Gate: QG-AX-005 (Motion & Polish)

```yaml
QG-AX-005:
  name: "Motion & Polish"
  checks:
    - id: "005-a"
      description: "No CSS transition or keyframe animations — spring physics only"
      test: "Search codebase for 'transition:' and 'animation:' in component CSS"
    - id: "005-b"
      description: "prefers-reduced-motion fallback for every animation"
      test: "Every motion variant has a shouldReduceMotion alternative"
    - id: "005-c"
      description: "All animations tested at 0.25x speed and feel intentional"
      test: "Manual review"
    - id: "005-d"
      description: "60fps on target devices (Chrome DevTools, Flipper)"
      test: "Profiler shows no frame drops during animations"
    - id: "005-e"
      description: "Exit duration <= 150ms (exits faster than entries)"
      test: "Code review of exit transition durations"
    - id: "005-f"
      description: "Stagger timing 30-50ms for list/grid children"
      test: "Code review of staggerChildren values"
  verdict: "PASS | FAIL"
  blocker: true
```

---

### Step 4 — Accessibility Audit (@a11y-eng)

**Agent:** Sara (a11y-eng)
**Input:** Implemented and motion-polished components
**Deliverable:** WCAG 2.2 AA compliance report + fixes

Sara audits every component for accessibility compliance.

#### 4.1 — Automated Scan

```bash
# Run axe-core in Storybook
npx storybook --smoke-test
npx axe-storybook

# Expected: 0 violations, 0 incomplete issues
```

Any automated violation is a blocker. Fix before proceeding.

#### 4.2 — Manual Checklist

**Focus Management:**
```
[ ] Tab order is logical (matches visual order)
[ ] All interactive elements are reachable via keyboard
[ ] Focus is not trapped unexpectedly
[ ] For modals/drawers: focus moves to modal on open, returns on close
[ ] Focus indicator is visible on all interactive elements
[ ] Focus indicator contrast: minimum 3:1 against background
```

**Screen Reader:**
```
[ ] Test with VoiceOver + Safari (macOS)
[ ] Test with NVDA + Firefox (Windows)
[ ] Component announces its role correctly
[ ] Interactive elements have accessible names
[ ] State changes are announced (loading → loaded, error message)
[ ] Icons have accessible labels (aria-label or title)
[ ] Loading states use aria-busy="true"
[ ] Error messages are associated with their input (aria-describedby)
```

**ARIA Compliance:**
```
[ ] No redundant ARIA (aria-label on a <button> that already has text)
[ ] No invalid ARIA (role="button" on a div without keyboard handling)
[ ] Live regions present for dynamic content updates
[ ] Table/grid semantics correct (if component uses table layout)
```

**Color & Contrast:**
```
[ ] Text contrast: 4.5:1 minimum for normal text (WCAG 2.2 AA)
[ ] Text contrast: 3:1 minimum for large text (18px+ or 14px bold)
[ ] Non-text contrast: 3:1 for UI component boundaries
[ ] Information not conveyed by color alone
```

**Mobile Touch:**
```
[ ] Touch targets: minimum 44x44px (WCAG 2.5.8)
[ ] Touch targets: 8px spacing between adjacent targets
[ ] Gesture alternatives provided for swipe/pinch (if applicable)
```

#### 4.3 — Quality Gate: QG-AX-006 (Accessibility)

```yaml
QG-AX-006:
  name: "Accessibility (WCAG 2.2 AA)"
  checks:
    - id: "006-a"
      description: "axe-core score: 100 (zero violations)"
    - id: "006-b"
      description: "Screen reader tested: VoiceOver + NVDA"
    - id: "006-c"
      description: "Keyboard-only navigation fully functional"
    - id: "006-d"
      description: "Color contrast meets WCAG 2.2 requirements"
    - id: "006-e"
      description: "Touch targets minimum 44x44px on mobile"
    - id: "006-f"
      description: "Focus indicators visible and meet 3:1 contrast"
    - id: "006-g"
      description: "Dynamic content updates announced via live regions"
  verdict: "PASS | FAIL"
  blocker: true
```

---

### Step 5 — Performance Audit (@perf-eng)

**Agent:** Addy (perf-eng)
**Input:** Implemented, motion-polished, a11y-compliant components
**Deliverable:** Performance report + optimizations

Addy validates the implementation against the performance budgets defined in Step 1.

#### 5.1 — Bundle Analysis

```bash
# Analyze bundle impact of new code
npx @next/bundle-analyzer

# Check what the component adds to first load JS
# Target: feature contribution keeps total under 80KB gzipped
```

#### 5.2 — Core Web Vitals Check

```bash
# Run Lighthouse CI
npx lhci autorun

# Targets
# LCP < 1.2s
# INP < 200ms
# CLS < 0.1
```

#### 5.3 — Image Optimization

If the component includes images:
- Format: WebP (with AVIF for supporting browsers)
- Size: serve at display size, not larger
- Loading: `loading="lazy"` for below-fold, `loading="eager"` for LCP image
- Decode: `decoding="async"` for all non-critical images
- Use `next/image` on web — never raw `<img>` for content images

#### 5.4 — Code Splitting

```typescript
// Lazy load heavy dependencies
import dynamic from 'next/dynamic';

// Only for non-critical below-fold content
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // only if chart requires browser APIs
});
```

#### 5.5 — Quality Gate: QG-AX-007 (Performance Budgets)

```yaml
QG-AX-007:
  name: "Performance Budgets"
  checks:
    - id: "007-a"
      description: "LCP < 1.2s (if component is LCP element)"
      measurement: "Lighthouse CI"
    - id: "007-b"
      description: "INP < 200ms (for all interactive components)"
      measurement: "Chrome DevTools > Performance"
    - id: "007-c"
      description: "CLS < 0.1 (no layout shift on mount)"
      measurement: "Lighthouse CI"
    - id: "007-d"
      description: "First load JS delta within budget"
      measurement: "Bundle analyzer"
    - id: "007-e"
      description: "No layout thrashing (no reads after writes)"
      measurement: "Chrome DevTools > Performance flamechart"
    - id: "007-f"
      description: "Images optimized (WebP/AVIF, correct size, lazy loaded)"
      measurement: "Lighthouse audit"
  verdict: "PASS | FAIL"
  blocker: true
```

---

## Quality Gate Summary

| Gate | ID | Phase | Owner | Status Required |
|------|----|-------|-------|-----------------|
| Structure & Architecture | QG-AX-003 | Pre-implementation | @frontend-arch | PASS |
| Behavior & States | QG-AX-004 | Implementation | @react-eng | PASS |
| Motion & Polish | QG-AX-005 | Motion step | @motion-eng | PASS |
| Accessibility | QG-AX-006 | A11y step | @a11y-eng | PASS |
| Performance Budgets | QG-AX-007 | Perf step | @perf-eng | PASS |

All five gates must pass before this task is complete. The output is the required
input for `apex-ship-flow`.

---

## Storybook Stories

Every component must have Storybook stories documenting all states:

```typescript
// {ComponentName}.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { ComponentName } from './{ComponentName}';

const meta: Meta<typeof ComponentName> = {
  title: 'Patterns/{ComponentName}',
  component: ComponentName,
  parameters: {
    a11y: { disable: false }, // Always run axe-core
  },
};
export default meta;

type Story = StoryObj<typeof ComponentName>;

export const Default: Story = {};
export const Loading: Story = { args: { isLoading: true } };
export const Empty: Story = { args: { isEmpty: true } };
export const Error: Story = { args: { isError: true } };
export const Disabled: Story = { args: { isDisabled: true } };
```

---

## Handoff to Ship Flow

When all five quality gates pass, produce the handoff artifact:

```yaml
# .aios/handoffs/build-to-ship-{timestamp}.yaml
handoff:
  from_agent: "perf-eng"
  to_agent: "qa-visual"
  feature: "{feature_description}"
  platforms_implemented: [{platforms}]
  gates_passed: ["QG-AX-003", "QG-AX-004", "QG-AX-005", "QG-AX-006", "QG-AX-007"]
  files_modified:
    - "{path to component files}"
    - "{path to token files if new tokens created}"
  decisions:
    - "{key architectural decision}"
    - "{key motion decision}"
  next_action: "Run apex-ship-flow for visual regression and cross-platform QA"
```

---

*Apex Squad — Build Flow Task v1.0.0*
