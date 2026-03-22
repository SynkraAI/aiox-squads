# Task: apex-design-flow

```yaml
id: apex-design-flow
version: "1.0.0"
title: "Apex Design Flow"
description: >
  Transform a feature description into a complete design specification with
  interaction patterns, design tokens, component API, and responsive variants.
  Produces the design artifact that is the required input for apex-build-flow.
elicit: true
owner: apex-lead
agents:
  primary: interaction-dsgn
  secondary: design-sys-eng
  reviewer: apex-lead
quality_gates:
  - QG-AX-001
  - QG-AX-002
outputs:
  - design-spec.md
  - token-map.yaml
  - component-api.ts
  - responsive-variants.md
```

---

## Inputs

Before starting this task, the following inputs must be available:

| Input | Required | Description |
|-------|----------|-------------|
| `feature_description` | Yes | Human-readable description of the feature to design |
| `target_platforms` | Yes | One or more of: `web`, `mobile`, `spatial` |
| `story_id` | No | AIOS story ID if this task is part of a story |
| `existing_components` | No | List of existing components that this feature can reuse |
| `figma_link` | No | Link to existing Figma designs if any are available |
| `acceptance_criteria` | No | Acceptance criteria from the story or PRD |

### Elicitation

If any required inputs are missing, elicit them from the user in this exact format:

```
Apex Design Flow — Input Required

1. Feature description:
   > {user input here}

2. Target platforms (web / mobile / spatial / all):
   > {user input here}

3. Any existing components or patterns to reference?
   > {user input here, or "none"}

Type your answers and press Enter to continue.
```

---

## Execution

### Step 1 — Interaction Design (@interaction-dsgn)

**Agent:** Ahmad (interaction-dsgn)
**Deliverable:** `design-spec.md`

Ahmad creates the full interaction specification. This document is the source of truth
for what the feature looks and behaves like before any code is written.

#### 1.1 — State Inventory

List every state the component or feature can be in:

```
States to document:
- Default (resting state)
- Hover (web only — pointer device)
- Focus (keyboard / screen reader navigation)
- Active / Pressed (during user interaction)
- Loading (async operation in progress)
- Empty (no data / first use)
- Error (operation failed or validation failed)
- Success (operation completed)
- Disabled (action not available)
- Selected / Checked (if applicable)
- Expanded / Collapsed (if applicable)
```

For each state, document:
- Visual appearance delta from default
- Cursor or touch feedback
- Screen reader announcement
- Transition into and out of this state

#### 1.2 — Interaction Pattern Definition

For each user interaction, document:

```yaml
interaction:
  trigger: "{user action}"
  platform: [web | mobile | spatial]
  immediate_feedback: "{visual/haptic response within 16ms}"
  animation_intent: "{what the animation communicates}"
  spring_preset: "{gentle | responsive | snappy | bouncy}"
  reduced_motion_fallback: "{instant state change or crossfade}"
  accessible_alternative: "{keyboard equivalent or screen reader announcement}"
```

Example for a button press:
```yaml
interaction:
  trigger: "pointer down / touch start"
  platform: [web, mobile]
  immediate_feedback: "scale 0.97 + shadow elevation decrease"
  animation_intent: "tactile confirmation that input was received"
  spring_preset: "snappy"
  reduced_motion_fallback: "background color change only"
  accessible_alternative: "focus ring visible on keyboard focus, Enter/Space activates"
```

#### 1.3 — Responsive Behavior

For each of the 6 breakpoints, document the layout behavior:

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| mobile-s | 320px | Minimal layout, single column, no decorative elements |
| mobile | 375px | Standard mobile layout |
| tablet | 768px | Two-column or expanded layout |
| desktop | 1024px | Full desktop layout |
| desktop-l | 1440px | Maximum content width, generous whitespace |
| 4k | 2560px | Scaled layout, no stretching |

Document for each breakpoint:
- Layout algorithm (Stack, Grid, Sidebar, Switcher)
- Content priority (what collapses or hides)
- Typography scale adjustments
- Spacing scale adjustments

#### 1.4 — Motion Intent Documentation

For each animated transition in the feature:

```yaml
animation:
  id: "{animation-id}"
  trigger: "{what causes this animation}"
  elements_involved: ["{element 1}", "{element 2}"]
  choreography: "{sequence description}"
  spring_config:
    preset: "{gentle | responsive | snappy | bouncy}"
    stiffness: {number}
    damping: {number}
    mass: {number}
  duration_hint: "{approximate duration for reference}"
  reduced_motion:
    strategy: "instant | crossfade | opacity-only"
    duration: "{0ms for instant, or crossfade duration}"
```

#### 1.5 — Empty, Loading, and Error States

These are not optional. For every async boundary:

**Loading state:**
- Skeleton layout (preferred) or spinner (when skeleton is not feasible)
- Skeleton dimensions must match the expected content dimensions
- Skeleton must pulse or shimmer (reduced-motion: static)

**Empty state:**
- Illustration or icon
- Heading (what is missing)
- Description (why it is missing)
- Call-to-action (what the user can do)
- Tone: encouraging, not apologetic

**Error state:**
- Clear error message (human-readable, not code)
- Recovery action (retry, go back, contact support)
- Never expose technical error details to the user

---

### Step 2 — Design System Engineering (@design-sys-eng)

**Agent:** Diana (design-sys-eng)
**Input:** `design-spec.md` from Step 1
**Deliverable:** `token-map.yaml` + `component-api.ts`

Diana extracts all design decisions from the spec and maps them to tokens, then defines
the component API surface.

#### 2.1 — Token Extraction

For every design value in the spec, identify the correct token:

```yaml
# token-map.yaml structure
component: "{ComponentName}"
tokens:
  color:
    background: "color.background.surface"
    border: "color.border.subtle"
    text: "color.text.primary"
    text_secondary: "color.text.secondary"
    interactive_hover: "color.background.hover"
    interactive_pressed: "color.background.pressed"
    focus_ring: "color.border.focus"
  spacing:
    padding_x: "spacing.4"     # 16px
    padding_y: "spacing.3"     # 12px
    gap: "spacing.2"           # 8px
    border_radius: "radius.md" # 8px
  typography:
    label: "text.sm.medium"    # 14px, weight 500
    description: "text.xs.regular"
  motion:
    enter: "motion.spring.gentle"
    press: "motion.spring.snappy"
    exit_duration: "motion.exit"  # 150ms
  elevation:
    default: "shadow.sm"
    hover: "shadow.md"
    pressed: "shadow.xs"
```

**Rules:**
- No hardcoded values in `token-map.yaml`
- Every token must exist in all three modes: light, dark, high-contrast
- If a required token does not exist, create it following naming conventions

#### 2.2 — Token Gap Analysis

Identify tokens referenced in the map that do not yet exist in `packages/tokens/`:

```yaml
# token-gaps.yaml
missing_tokens:
  - id: "color.background.pressed"
    light_value: "#F0F0F0"
    dark_value: "#2A2A2A"
    high_contrast_value: "#000000"
    rationale: "Needed for interactive press state — darker than hover"
    priority: high
```

New tokens must be created in `packages/tokens/` before implementation proceeds.

#### 2.3 — Component API Definition

Define the TypeScript component API surface:

```typescript
// component-api.ts — example structure
export interface {ComponentName}Props {
  // Content
  children?: React.ReactNode;
  label: string;

  // Behavior
  onAction?: () => void;
  isDisabled?: boolean;
  isLoading?: boolean;

  // Visual variants
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive';
  size?: 'sm' | 'md' | 'lg';

  // Platform adaptations
  hapticFeedback?: boolean; // Mobile only

  // Accessibility
  'aria-label'?: string;
  'aria-describedby'?: string;

  // Styling extension
  className?: string;
  style?: React.CSSProperties;
}

export interface {ComponentName}Ref {
  focus: () => void;
}
```

**API Rules:**
- No platform-specific props in the base API (platform variants use separate files)
- Boolean props use `is` prefix for state (`isDisabled`, `isLoading`)
- Event handler props use `on` prefix (`onAction`, `onChange`)
- Ref must be forwarded if the component is interactive
- All props must be documented with JSDoc comments

---

### Step 3 — Design Review (@apex-lead)

**Agent:** Emil (apex-lead)
**Input:** `design-spec.md`, `token-map.yaml`, `component-api.ts`
**Deliverable:** Review verdict + approval to proceed to build

Emil reviews the design spec and token map for:

#### 3.1 — Visual Authority Check

```
Review checklist:
[ ] Does the interaction feel inevitable? (not designed, but obvious)
[ ] Do the spring configs match the interaction energy?
[ ] Are all states designed with equal care?
[ ] Does the empty state communicate the right tone?
[ ] Is the motion language consistent with existing squad motion patterns?
[ ] Would this feel native on mobile (if mobile is a target platform)?
[ ] Is there anything that feels "designed" (effortful) vs "inevitable" (natural)?
```

#### 3.2 — Quality Gate: QG-AX-001 (Design Completeness)

```yaml
QG-AX-001:
  name: "Design Completeness"
  checks:
    - id: "001-a"
      description: "All states designed"
      required_states: [default, hover, focus, active, loading, empty, error, success, disabled]
    - id: "001-b"
      description: "Responsive variants for all 6 breakpoints"
      breakpoints: [320px, 375px, 768px, 1024px, 1440px, 2560px]
    - id: "001-c"
      description: "Motion intent documented for every animation"
    - id: "001-d"
      description: "Reduced-motion alternatives specified"
    - id: "001-e"
      description: "Figma spec complete (if Figma is in use)"
  verdict: "PASS | FAIL"
  blocker: true
```

If QG-AX-001 fails, return to Step 1 with specific gaps listed.

#### 3.3 — Quality Gate: QG-AX-002 (Token Compliance)

```yaml
QG-AX-002:
  name: "Token Compliance"
  checks:
    - id: "002-a"
      description: "No hardcoded values in token-map.yaml"
    - id: "002-b"
      description: "All tokens exist in light, dark, and high-contrast modes"
    - id: "002-c"
      description: "Token gaps documented and planned"
    - id: "002-d"
      description: "Component API fully typed with TypeScript"
    - id: "002-e"
      description: "Token naming follows squad convention"
  verdict: "PASS | FAIL"
  blocker: true
```

If QG-AX-002 fails, return to Step 2 with specific violations listed.

---

## Outputs

When both quality gates pass, the design flow produces the following artifacts:

### `design-spec.md`
Complete interaction specification including all states, responsive behavior,
motion intent, accessibility requirements, and platform-specific adaptations.

### `token-map.yaml`
Mapping of every design decision to a named design token. Includes token gap
analysis listing any new tokens that must be created before implementation.

### `component-api.ts`
TypeScript interface definition for the component's public API surface.
Includes JSDoc documentation for all props.

### `responsive-variants.md`
Detailed layout documentation for each of the 6 breakpoints, including
layout algorithm, content priority, and spacing/typography adjustments.

---

## Quality Gate Summary

| Gate | ID | Status | Owner |
|------|----|--------|-------|
| Design Completeness | QG-AX-001 | Must PASS | @interaction-dsgn |
| Token Compliance | QG-AX-002 | Must PASS | @design-sys-eng |

Both gates must pass before this task is complete. The output artifacts are the
required input for `apex-build-flow`.

---

## Handoff to Build Flow

When the design flow is complete and both gates have passed, produce a handoff artifact:

```yaml
# .aios/handoffs/design-to-build-{timestamp}.yaml
handoff:
  from_agent: "interaction-dsgn"
  to_agent: "frontend-arch"
  story_context:
    story_id: "{story_id}"
    feature: "{feature_description}"
    target_platforms: [{platforms}]
    gates_passed: ["QG-AX-001", "QG-AX-002"]
  artifacts:
    design_spec: "path/to/design-spec.md"
    token_map: "path/to/token-map.yaml"
    component_api: "path/to/component-api.ts"
    responsive_variants: "path/to/responsive-variants.md"
  decisions:
    - "Spring preset 'gentle' for modal enter/exit"
    - "Token gap: color.background.pressed — must be created before build"
    - "Component splits into Server wrapper + Client interactive island"
  next_action: "Run apex-build-flow with design artifacts as input"
```

---

*Apex Squad — Design Flow Task v1.0.0*
