# Task: animation-design

```yaml
id: animation-design
version: "1.0.0"
title: "Animation Design"
description: >
  Designs animation for a component or interaction following
  physics-based motion principles. Defines the animation intent,
  selects spring configurations, designs sequences and orchestration
  patterns, creates reduced-motion fallbacks, and validates by
  testing at 0.25x speed.
elicit: false
owner: motion-eng
executor: motion-eng
outputs:
  - Animation intent definition
  - Spring configuration selection
  - Animation sequence design
  - Orchestration plan (stagger, cascade)
  - Reduced-motion fallback
  - 0.25x speed test validation
```

---

## When This Task Runs

This task runs when:
- A new component needs animation (enter, exit, transform, feedback)
- An existing animation needs redesign (feels wrong, too slow, too fast)
- A complex interaction needs choreographed multi-element animation
- A feature needs both standard and reduced-motion versions
- `*animation-design` or `*design-animation` is invoked

This task does NOT run when:
- The animation is React Native specific (delegate to `@mobile-eng` for Reanimated)
- The task is about spring physics tuning specifically (use `spring-config`)
- The task is a full animation audit (use `motion-audit`)
- The task is about choreography specifically (use `choreography-design`)

---

## Execution Steps

### Step 1: Define Animation Intent

Clearly articulate what the animation communicates to the user. Every animation must have a purpose.

| Intent | Purpose | Examples |
|--------|---------|---------|
| **Enter** | Introduce new content to the scene | Page transition, modal opening, list item appearing |
| **Exit** | Remove content from the scene | Modal closing, notification dismissing, item deleting |
| **Transform** | Show state change | Toggle switch, accordion open/close, tab switch |
| **Feedback** | Acknowledge user action | Button press, form submit, drag completion |
| **Attention** | Direct focus to something important | Notification badge, error shake, pulse highlight |
| **Continuity** | Maintain spatial awareness during navigation | Shared element transition, page slide |

For the specific animation being designed:
- What is the animation intent? (Choose ONE primary intent)
- What information does the animation convey? (e.g., "this element is new", "your action succeeded")
- What would be lost if the animation were removed? (If nothing, the animation should not exist)
- How long should the user notice it? (Subtle: < 200ms, Standard: 200-500ms, Dramatic: 500ms+)

**Rule:** If an animation does not communicate something useful, it is decoration and should be removed. Animation tax is real — every animation adds cognitive load and battery drain.

**Output:** Animation intent statement with duration target.

### Step 2: Select Spring Configuration

Choose the physics-based spring parameters that match the animation intent.

**Spring presets (Framer Motion syntax):**

| Preset | Config | Feel | Use For |
|--------|--------|------|---------|
| Gentle | `{ stiffness: 120, damping: 14 }` | Soft, relaxed | Enter animations, page transitions |
| Responsive | `{ stiffness: 200, damping: 20 }` | Quick, precise | UI feedback, toggle switches |
| Snappy | `{ stiffness: 300, damping: 25 }` | Fast, decisive | Button press, dropdown open |
| Bouncy | `{ stiffness: 400, damping: 10 }` | Energetic, playful | Attention, celebration |

**Why springs, not duration-based easing:**
- Springs feel natural — they model real-world physics
- Springs are interruptible — mid-animation direction changes feel correct
- Springs do not have a fixed duration — they settle when the physics say so
- Easing curves (`ease-in-out`) feel artificial and cannot be interrupted cleanly

```tsx
// Framer Motion spring
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{
    type: "spring",
    stiffness: 200,
    damping: 20,
  }}
/>
```

**Never use:**
- `linear` easing (robotic, unnatural)
- `ease-in` for enter animations (starts slow, feels laggy)
- Fixed `duration` with `ease-in-out` (not interruptible)

**Output:** Selected spring configuration with rationale.

### Step 3: Design Animation Sequence

Define the exact animated properties, their start and end values, and timing.

```tsx
// Example: Modal enter animation
const modalAnimation = {
  initial: {
    opacity: 0,
    scale: 0.95,
    y: 10,
  },
  animate: {
    opacity: 1,
    scale: 1,
    y: 0,
  },
  exit: {
    opacity: 0,
    scale: 0.98,
    y: 5,
  },
  transition: {
    type: "spring",
    stiffness: 200,
    damping: 20,
  },
};
```

Animation property guidelines:
- **Prefer transform properties:** `scale`, `x/y` (translateX/Y), `rotate` — GPU-accelerated, no layout recalculation
- **Use opacity sparingly:** Fading is fine, but avoid animating opacity on large elements (causes compositing overhead)
- **Avoid layout properties:** `width`, `height`, `padding`, `margin` — triggers layout recalculation every frame
- **Keep transform values small:** `y: 20` not `y: 200` for enter animations (subtle is better)

Enter animation rule: animate FROM a state that is close to the final state. Large movements feel disorienting. Small movements feel intentional.

Exit animation rule: exit animations should be faster than enter animations (users do not want to wait for something to disappear). Use ~70% of the enter animation duration.

**Output:** Animation sequence specification with property values.

### Step 4: Plan Orchestration (Stagger, Cascade)

If multiple elements animate together, design their timing relationship.

**Stagger pattern (list items):**
```tsx
<motion.ul>
  {items.map((item, i) => (
    <motion.li
      key={item.id}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{
        type: "spring",
        stiffness: 200,
        damping: 20,
        delay: i * 0.05, // 50ms stagger
      }}
    />
  ))}
</motion.ul>
```

**Stagger guidelines:**
- 30-80ms per item for list staggers
- Maximum 10-12 items before it feels too long
- First items animate faster, later items can be delayed more
- Consider staggering by visibility (only stagger items in viewport)

**Cascade pattern (parent then children):**
```tsx
const parent = {
  animate: { transition: { staggerChildren: 0.05 } }
};
const child = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
};
```

**Orchestration rules:**
- Parent should reach its final state before children start (or simultaneously)
- Never animate children before their parent is visible
- Group related elements to animate together (header + subheader = same timing)
- Separate unrelated elements with a slight delay (content section vs. sidebar)

**Output:** Orchestration timing diagram.

### Step 5: Create Reduced-Motion Fallback

Design an alternative for users who have `prefers-reduced-motion: reduce` enabled.

```tsx
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;

// Framer Motion approach
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={
    prefersReducedMotion
      ? { duration: 0 }       // Instant, no motion
      : { type: "spring", stiffness: 200, damping: 20 }
  }
/>
```

**Reduced-motion rules:**
- **Remove all transform animations** (scale, rotate, translate) — these cause vestibular issues
- **Keep opacity fades** with short duration (opacity changes do not cause vestibular symptoms)
- **Remove stagger delays** — show all items immediately
- **Keep state changes** — the UI must still communicate the same information
- **Never remove functionality** — reduced motion means less motion, not less function

**What to preserve in reduced-motion:**
- Color changes (hover states, focus indicators)
- Opacity transitions (short, < 150ms)
- Instant state switches (appear/disappear without movement)

**What to remove in reduced-motion:**
- All translate/scale/rotate transforms
- Spring physics (replace with instant or very short fade)
- Scroll-linked animations
- Parallax effects
- Auto-playing animations

**Output:** Reduced-motion variant specification.

### Step 6: Test at 0.25x Speed

Slow the animation to 25% speed and evaluate its quality.

**Why 0.25x?** At normal speed, animation flaws are invisible. At quarter speed, every awkward transition, wrong easing, and timing error becomes obvious.

**How to test:**
```tsx
// Framer Motion: multiply all duration/stiffness values
// Chrome DevTools: Animation tab → set playback rate to 0.25x
// Custom: wrap all animations in a speed multiplier context
```

**What to look for at 0.25x:**
- Does the motion path feel natural? (Straight lines feel robotic, arcs feel natural)
- Is there any "pop" or sudden change? (Indicates missing interpolation)
- Do elements overshoot and settle, or stop abruptly? (Springs should overshoot slightly)
- Do staggered items feel evenly spaced? (Timing gaps should be consistent)
- Does the exit feel intentional? (Not just the enter animation in reverse)

**Pass criteria:**
- The animation looks intentional and well-crafted at 0.25x
- No sudden jumps, pops, or jarring transitions
- Spring overshoot is visible but not excessive
- All elements move in a coordinated, purposeful way

**Output:** 0.25x speed test results with pass/fail assessment.

---

## Quality Criteria

- Every animation must have a defined intent (no decorative animation)
- All animations must use spring physics (no linear, no ease-in-out)
- Reduced-motion fallback must be provided for every animation
- Animation must pass the 0.25x speed test
- Enter animations must be subtle (small transform values)

---

*Squad Apex — Animation Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-animation-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Animation intent must clearly state purpose (feedback, transition, decoration)"
    - "Spring configuration must use physics-based parameters (mass, damping, stiffness)"
    - "Reduced-motion fallback must be defined for every animation"
    - "0.25x speed test must confirm animation feels correct at slow speed"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@mobile-eng` or `@react-eng` |
| Artifact | Animation design spec with spring configs, sequences, and reduced-motion fallbacks |
| Next action | Implement animations in code using the specified spring parameters and orchestration plan |
