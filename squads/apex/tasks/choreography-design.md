# Task: choreography-design

```yaml
id: choreography-design
version: "1.0.0"
title: "Multi-Element Animation Choreography"
description: >
  Designs choreographed animation sequences for multi-element
  interactions. Defines element relationships, designs stagger
  sequences, plans shared layout animations, designs exit
  choreography, tests orchestration timing, and creates
  reduced-motion alternatives.
elicit: false
owner: motion-eng
executor: motion-eng
outputs:
  - Element relationship map
  - Stagger sequence design
  - Shared layout animation plan
  - Exit choreography
  - Orchestration timing validation
  - Reduced-motion alternative
```

---

## When This Task Runs

This task runs when:
- Multiple elements need to animate in a coordinated sequence (page transition, dashboard load, wizard steps)
- A list or grid of elements needs staggered enter/exit animations
- Shared element transitions are needed between routes or views
- A complex interaction involves multiple UI sections responding together
- `*choreography` or `*design-choreography` is invoked

This task does NOT run when:
- A single element needs animation (use `animation-design`)
- Only spring tuning is needed (use `spring-config`)
- A full audit is needed (use `motion-audit`)

---

## Execution Steps

### Step 1: Define Element Relationships

Map how the elements in the choreography relate to each other spatially and temporally.

**Relationship types:**

| Relationship | Description | Example |
|-------------|-------------|---------|
| **Parent-Child** | Parent contains children, animates first | Card container → card content |
| **Sibling-Sequential** | Siblings animate in order | List items top-to-bottom |
| **Sibling-Simultaneous** | Siblings animate together | Grid columns appearing at once |
| **Independent** | Elements animate without relationship | Header and footer independently |
| **Shared-Identity** | Same logical element across two views | Product card → product detail hero |

Create a relationship diagram:
```
Page Transition Choreography:

[Old Page] ─ exit ──→ [Empty] ──→ [New Page] ─ enter
                                      │
                                      ├── Header (first)
                                      │     ├── Logo (with header)
                                      │     └── Nav items (stagger 50ms)
                                      │
                                      ├── Hero (after header, 100ms delay)
                                      │     ├── Image (shared element from previous page)
                                      │     └── Text (fade in after image settles)
                                      │
                                      └── Content Grid (after hero, 150ms delay)
                                            └── Cards (stagger 60ms, max 8)
```

For each element:
- When does it start animating relative to the trigger?
- What does it depend on? (Does it wait for another element to finish?)
- What is its animation type? (enter, exit, transform, shared)

**Output:** Element relationship diagram with temporal dependencies.

### Step 2: Design Stagger Sequence

Define how sequential elements animate with staggered timing.

**Stagger types:**

| Type | Behavior | Use When |
|------|----------|----------|
| **Linear stagger** | Fixed delay between each item | Short lists (< 8 items) |
| **Accelerating** | Delay decreases per item | Long lists (faster as it goes) |
| **Decelerating** | Delay increases per item | Content that fans out |
| **Center-out** | Middle items first, edges last | Grid centered layouts |
| **Edge-in** | Edge items first, center last | Surrounding content |

```tsx
// Linear stagger (Framer Motion)
const container = {
  animate: {
    transition: {
      staggerChildren: 0.06, // 60ms between each
      delayChildren: 0.1,    // 100ms before first child
    },
  },
};

// Accelerating stagger (custom)
const getStaggerDelay = (index: number, total: number) => {
  const progress = index / total;
  return 0.08 * (1 - progress * 0.5); // Starts at 80ms, decreases
};
```

**Stagger constraints:**
- Maximum total stagger time: 600ms (beyond this, users lose patience)
- Minimum per-item delay: 30ms (below this, items appear simultaneous)
- Maximum per-item delay: 100ms (above this, feels sluggish)
- Maximum items to stagger: 12 (beyond this, batch the rest)
- Items outside viewport should appear instantly (no stagger for off-screen)

**Virtual stagger for long lists:**
```tsx
// Only stagger items currently in viewport
const visibleItems = items.filter(item => isInViewport(item.ref));
visibleItems.forEach((item, i) => {
  if (i < 12) {
    animateWithDelay(item, i * 0.06);
  } else {
    showInstantly(item);
  }
});
```

**Output:** Stagger sequence specification with timing values.

### Step 3: Plan Shared Layout Animations

Design animations where an element transitions smoothly between two positions or two views.

**Shared layout animation (Framer Motion `layoutId`):**
```tsx
// Page A: Product card
<motion.div layoutId={`product-${id}`}>
  <motion.img layoutId={`product-image-${id}`} src={thumbnail} />
  <motion.h3 layoutId={`product-title-${id}`}>{name}</motion.h3>
</motion.div>

// Page B: Product detail
<motion.div layoutId={`product-${id}`}>
  <motion.img layoutId={`product-image-${id}`} src={fullImage} />
  <motion.h3 layoutId={`product-title-${id}`}>{name}</motion.h3>
</motion.div>
```

**Layout animation design rules:**
- Keep `layoutId` stable across routes (same string for the same logical element)
- Animate position and size — these are handled automatically by `layout` prop
- Add `layout="position"` if only position should animate (not size)
- Wrap route transitions in `AnimatePresence` for enter/exit coordination
- Avoid animating `borderRadius` during layout transitions (can look jarring)

**Cross-route shared elements:**
```tsx
// Wrap the entire app in LayoutGroup for cross-route animations
<LayoutGroup>
  <AnimatePresence mode="wait">
    <Routes />
  </AnimatePresence>
</LayoutGroup>
```

**Output:** Shared layout animation specification with layoutId mapping.

### Step 4: Design Exit Choreography

Design how elements leave the screen — exit choreography is as important as enter.

**Exit principles:**
- Exit animations are FASTER than enter animations (users want to move forward)
- Exit direction should be the OPPOSITE of enter direction (spatial consistency)
- Group exits: related elements exit together, not individually
- Critical content exits last (user might still be reading it)

**Exit patterns:**

| Pattern | Behavior | Use For |
|---------|----------|---------|
| **Fade out** | Simple opacity to 0 | Quick dismissals, background content |
| **Slide out** | Translate in exit direction + fade | Pages, panels, drawers |
| **Collapse** | Height to 0 + fade | List item removal, accordion close |
| **Scale down** | Scale to 0.95 + fade | Modals, cards, popups |
| **Reverse stagger** | Items exit in reverse order (bottom-first) | Lists, grids |

```tsx
// Exit choreography for a page
const pageExit = {
  exit: {
    opacity: 0,
    y: -10,  // Slight upward movement (opposite of enter which comes from below)
    transition: {
      type: "spring",
      stiffness: 300,
      damping: 25,
      staggerChildren: 0.03, // Faster stagger than enter
      staggerDirection: -1,  // Reverse order
    },
  },
};
```

**AnimatePresence modes:**
- `mode="wait"`: Old content exits completely before new content enters (clean, slower)
- `mode="popLayout"`: Old and new content animate simultaneously (faster, more complex)
- `mode="sync"`: Both animate at the same time without waiting

**Output:** Exit choreography specification with timing and direction.

### Step 5: Test Orchestration Timing

Validate that the full choreography feels cohesive when all elements animate together.

**Testing method:**
1. Record a screen capture of the full choreography
2. Play at 1x speed — does it feel smooth and intentional?
3. Play at 0.25x speed — are transitions smooth, is stagger even?
4. Play at 2x speed — does it still read as choreographed (not chaotic)?
5. Interrupt mid-choreography — does it recover gracefully?

**Timing validation checklist:**
- [ ] Total choreography duration is under 800ms (enter) / 500ms (exit)
- [ ] No element animates before its parent is visible
- [ ] Stagger feels rhythmic, not random
- [ ] Shared elements transition smoothly without "teleporting"
- [ ] Exit completes before enter begins (if using `mode="wait"`)
- [ ] No two unrelated elements start at exactly the same time (slight offset feels more natural)
- [ ] The "hero" element (most important) has the most prominent animation

**Interruption test:**
- Trigger the choreography and immediately navigate away — no stuck animations
- Trigger the choreography and rapidly trigger it again — no double animations
- Trigger the choreography and resize the browser — layout animations adapt

**Output:** Orchestration timing validation results.

### Step 6: Create Reduced-Motion Alternative

Design a choreography alternative for users with `prefers-reduced-motion: reduce`.

**Reduced-motion choreography rules:**
- Replace all transform animations with instant state changes
- Remove stagger delays — all items appear simultaneously
- Keep opacity transitions but shorten to < 100ms
- Remove shared layout animations — use instant view switches
- Remove scroll-linked choreography
- Preserve information hierarchy through visual means (color, size) not motion

```tsx
const choreography = useReducedMotion()
  ? {
      // Instant: no stagger, no transform, short fade only
      initial: { opacity: 0 },
      animate: { opacity: 1 },
      transition: { duration: 0.1 },
    }
  : {
      // Full choreography
      initial: { opacity: 0, y: 20 },
      animate: { opacity: 1, y: 0 },
      transition: { type: "spring", stiffness: 200, damping: 20 },
    };
```

**Reduced-motion must still communicate:**
- What is new on the screen (use opacity fade)
- What was removed (instant removal is fine)
- What changed state (use color/border changes)
- Where focus should go (programmatic focus management)

**Output:** Reduced-motion choreography specification.

---

## Quality Criteria

- Element relationships must be documented before timing is designed
- Total enter choreography must complete within 800ms
- Total exit choreography must complete within 500ms
- Stagger must not exceed 12 individually-animated items
- Reduced-motion must preserve all information communication
- Interruption must be handled gracefully (no stuck states)

---

*Squad Apex — Multi-Element Animation Choreography Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-choreography-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Element relationship map must define parent-child and sibling coordination"
    - "Stagger sequence must specify delay values and ordering logic"
    - "Exit choreography must be defined (not just enter animations)"
    - "Reduced-motion alternative must preserve functional meaning without motion"
    - "Timing validation must confirm total choreography duration is within budget"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@mobile-eng` or `@react-eng` |
| Artifact | Choreography design spec with stagger sequences, shared layout plan, and timing validation |
| Next action | Implement multi-element animation choreography using the specified timing and coordination patterns |
