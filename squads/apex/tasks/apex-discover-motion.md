# Task: apex-discover-motion

```yaml
id: apex-discover-motion
version: "1.0.0"
title: "Apex Discover Motion"
description: >
  Inventories ALL animations and transitions in the project. Detects CSS
  transitions that should be springs (veto QG-AX-006), missing prefers-reduced-motion
  (veto QG-AX-005), missing exit animations, and non-GPU animations.
  Feeds motion-audit and choreography-design tasks.
elicit: false
owner: apex-lead
executor: motion-eng
dependencies:
  - tasks/apex-scan.md
  - tasks/motion-audit.md
  - tasks/animation-architecture.md
  - data/spring-configs.yaml
outputs:
  - Animation inventory with classification
  - Veto violations list (QG-AX-005, QG-AX-006)
  - Motion health score
```

---

## Command

### `*discover-motion`

Inventories all animations and transitions in the project.

---

## How It Works

### Step 1: Detect Animation Libraries

```yaml
detection:
  libraries:
    - framer_motion:
        import: "framer-motion OR motion"
        patterns: ["motion.", "animate(", "useSpring", "useMotionValue", "AnimatePresence"]
    - react_spring:
        import: "@react-spring/web"
        patterns: ["useSpring", "animated.", "useTrail", "useTransition"]
    - gsap:
        import: "gsap"
        patterns: ["gsap.to", "gsap.from", "gsap.timeline", "ScrollTrigger"]
    - css_animations:
        patterns: ["@keyframes", "animation:", "animation-name:"]
    - css_transitions:
        patterns: ["transition:", "transition-property:", "transition-duration:"]
    - tailwind_transitions:
        patterns: ["transition-", "duration-", "ease-", "animate-"]

  result:
    primary_library: "{detected}"
    secondary_libraries: ["{others}"]
    css_only_count: N
    library_count: N
```

### Step 2: Build Animation Inventory

```yaml
inventory:
  per_animation:
    component: "{component name}"
    file: "{file path}:{line}"
    type: "spring | css_transition | css_animation | keyframe | gesture"
    library: "framer-motion | react-spring | gsap | css | tailwind"
    trigger: "mount | hover | click | scroll | gesture | state_change"
    properties: ["opacity", "transform", "height", "color", "etc"]
    duration: "{ms or spring config}"
    has_exit: true | false
    has_reduced_motion: true | false
    gpu_accelerated: true | false
    spring_config: "{config name from spring-configs.yaml or custom}"

  classification:
    entrance: "Animations on mount/appear"
    exit: "Animations on unmount/disappear"
    hover: "Hover state animations"
    interaction: "Click/tap/drag animations"
    scroll: "Scroll-triggered animations"
    layout: "Layout animations (reflow)"
    loading: "Skeleton/spinner/progress animations"
    micro: "Micro-interactions (button press, toggle, etc.)"
```

### Step 3: Detect Issues

```yaml
checks:

  css_transition_should_be_spring:
    description: "CSS transition used where spring physics would be better"
    detection: "transition: on interactive elements (buttons, modals, drawers, toggles)"
    veto: "QG-AX-006"
    severity: HIGH
    exceptions:
      - "Color transitions (opacity, background-color) — CSS is fine"
      - "Simple hover color changes"
      - "Loading bar progress"

  missing_reduced_motion:
    description: "Animation without prefers-reduced-motion alternative"
    detection: |
      Component has motion.* or @keyframes but:
      - No useReducedMotion() hook
      - No @media (prefers-reduced-motion: reduce) in CSS
      - No reducedMotion prop on motion components
    veto: "QG-AX-005"
    severity: CRITICAL

  missing_exit_animation:
    description: "Component animates in but doesn't animate out"
    detection: |
      Component has initial/animate but:
      - No exit prop on motion component
      - No AnimatePresence wrapper
      - No useTransition (react-spring)
    severity: MEDIUM

  non_gpu_animation:
    description: "Animation triggers layout/paint instead of composite"
    detection: "Animating width, height, top, left, margin, padding, border instead of transform/opacity"
    severity: MEDIUM
    gpu_safe: ["transform", "opacity", "filter", "clip-path"]
    gpu_unsafe: ["width", "height", "top", "left", "right", "bottom", "margin", "padding", "border", "font-size"]

  inconsistent_timing:
    description: "Different durations/easings for similar interactions"
    detection: "Same type of animation (e.g., modal entrance) with different timing across components"
    severity: LOW

  animation_without_purpose:
    description: "Decorative animation that adds no UX value"
    detection: "manual — flagged for review"
    severity: LOW
```

### Step 4: Calculate Motion Health Score

```yaml
health_score:
  formula: "100 - (penalties)"
  penalties:
    missing_reduced_motion: -10 each
    css_transition_interactive: -5 each
    missing_exit_animation: -3 each
    non_gpu_animation: -3 each
    inconsistent_timing: -1 each

  classification:
    90-100: "fluid — motion system well-designed"
    70-89: "good — minor motion gaps"
    50-69: "rough — significant motion issues"
    0-49: "janky — motion needs overhaul"
```

### Step 5: Output

```yaml
output_format: |
  ## Motion Discovery

  **Primary Library:** {library} ({version})
  **Total Animations:** {total} ({entrance} entrance, {exit} exit, {hover} hover, {interaction} interaction)
  **Motion Health Score:** {score}/100 ({classification})

  ### Veto Violations
  | Veto | Count | Components |
  |------|-------|------------|
  | QG-AX-006 (CSS transition → spring) | {n} | {list} |
  | QG-AX-005 (missing reduced-motion) | {n} | {list} |

  ### Issues Found
  | Issue | Count | Severity |
  |-------|-------|----------|
  | CSS transitions on interactive | {n} | HIGH |
  | Missing reduced-motion | {n} | CRITICAL |
  | Missing exit animations | {n} | MEDIUM |
  | Non-GPU animations | {n} | MEDIUM |

  ### Animation Map
  | Component | Type | Library | Trigger | Exit? | Reduced? | GPU? |
  |-----------|------|---------|---------|-------|----------|------|
  | {name} | {type} | {lib} | {trigger} | {y/n} | {y/n} | {y/n} |

  ### Options
  1. Corrigir veto violations ({veto_count})
  2. Adicionar reduced-motion em todos ({missing_rm})
  3. Converter CSS transitions para springs ({css_count})
  4. So quero o inventario
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DM-MOTION-001
    condition: "Interactive element uses CSS transition instead of spring"
    action: "WARN — Feeds QG-AX-006. Convert to spring physics."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-DM-MOTION-002
    condition: "Animation found without prefers-reduced-motion handling"
    action: "WARN — Feeds QG-AX-005. Add reduced motion alternative."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

## Cache

```yaml
cache:
  location: ".aios/apex-context/motion-cache.yaml"
  ttl: "Until component files change"
  invalidate_on:
    - "Any .tsx/.jsx/.css file with animation patterns modified"
    - "framer-motion or animation library updated"
    - "User runs *discover-motion explicitly"
```

---

*Apex Squad — Discover Motion Task v1.0.0*
