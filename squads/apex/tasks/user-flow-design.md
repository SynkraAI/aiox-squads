# Task: user-flow-design

```yaml
id: user-flow-design
version: "1.0.0"
title: "User Flow Design"
description: >
  Design a complete user interaction flow with visual annotations. Maps
  the user journey step by step, defines state transitions between screens
  or views, annotates interaction points, specifies motion and animation
  per transition, defines error and edge case flows, and produces a visual
  flow diagram.
elicit: false
owner: interaction-dsgn
executor: interaction-dsgn
outputs:
  - User flow diagram (visual)
  - State transition map
  - Interaction annotation document
  - Motion specification per transition
  - Error and edge case flow definitions
```

---

## When This Task Runs

This task runs when:
- A new multi-step feature needs its user journey designed
- An existing flow has usability issues and needs redesign
- A story requires understanding the full user path before implementation
- The team needs to align on how a user moves through a feature
- A flow spans multiple pages, modals, or views

This task does NOT run when:
- The task is about a single component's design (use `design-component`)
- The flow is a technical/system flow, not user-facing (route to `@architect`)
- The flow is about data pipeline or backend processing (route to `@data-engineer`)

---

## Execution Steps

### Step 1: Map User Journey Steps

Identify every step the user takes through the flow:

1. Define the entry point(s):
   - How does the user arrive at this flow? (navigation, deep link, notification, CTA)
   - What context do they bring? (authenticated, first-time, returning)
2. List each step sequentially:
   - **Step name** — short descriptive label
   - **Screen/view** — which page, modal, or panel is shown
   - **User goal** — what the user is trying to accomplish at this step
   - **Required input** — what the user must provide (if any)
   - **System response** — what happens after the user acts
3. Define the exit point(s):
   - Success completion — where does the user land after the flow?
   - Abandonment — what happens if the user leaves mid-flow?
   - Alternative exits — back button, close, cancel
4. Identify optional and conditional steps (steps that only appear for certain users)

### Step 2: Define State Transitions

Map how the system transitions between steps:

1. For each step transition, define:
   - **Trigger** — user action that causes the transition (click, submit, swipe)
   - **Guard condition** — validation that must pass (form valid, auth checked)
   - **Side effect** — system action during transition (API call, save draft)
   - **Loading state** — what the user sees during async operations
   - **Target state** — which step the user arrives at
2. Identify branching points:
   - Conditional paths based on user input or system state
   - A/B test variations if applicable
3. Document backward navigation:
   - Can the user go back to a previous step?
   - Is state preserved when going back?
   - Are there steps that cannot be undone?

### Step 3: Annotate Interaction Points

Mark every point where the user interacts with the interface:

1. **Primary actions** (the main path forward):
   - Button clicks, form submissions, confirmations
   - Mark with a distinct visual indicator in the flow diagram
2. **Secondary actions** (alternatives):
   - Skip, dismiss, "do this later", "learn more"
   - Mark differently from primary actions
3. **Passive interactions:**
   - Scrolling to reveal content
   - Hover to preview
   - Auto-advancing timers
4. **Decision points:**
   - Where the user must choose between options
   - Include the options and their consequences
5. For each interaction point, note:
   - Interaction type (tap, click, swipe, long press, keyboard shortcut)
   - Feedback provided (visual, haptic, audio)
   - Time sensitivity (immediate response vs loading state)

### Step 4: Specify Motion per Transition

Define animation for each step transition:

1. **Page-to-page transitions:**
   - Direction (slide left/right, fade, push)
   - Shared element transitions (morphing header, persistent sidebar)
   - Duration (300-500ms for page transitions)
2. **Modal/overlay transitions:**
   - Entry (fade in + scale from 0.95 to 1, slide up from bottom)
   - Exit (reverse of entry)
   - Background dimming animation
3. **In-page transitions:**
   - Content swap (crossfade, slide)
   - Progress indicator animation (step bar, progress ring)
   - Form field validation feedback
4. **Reduced motion alternatives:**
   - Replace slide/scale with opacity-only transitions
   - Reduce durations to minimum
   - Preserve functional motion cues
5. Document with handoff notes for `@motion-eng`

### Step 5: Define Error and Edge Case Flows

Handle every way the flow can fail or deviate:

1. **Validation errors:**
   - Inline validation (per field, on blur or on change)
   - Form-level validation (on submit)
   - How errors are displayed and cleared
2. **Network errors:**
   - Timeout — show retry option with preserved state
   - Server error — show friendly message with support link
   - Offline — queue action and sync when online (if applicable)
3. **Permission errors:**
   - Unauthorized — redirect to login with return URL
   - Forbidden — show explanation and alternative path
4. **Edge cases:**
   - Empty state — no data to display (first-time user)
   - Maximum limits — user reaches a quota or cap
   - Concurrent edits — another user modified the same data
   - Session expiry — mid-flow timeout
5. For each error/edge case, document:
   - How the user is informed
   - What recovery options are available
   - Where the user returns to after recovery

### Step 6: Create Visual Flow Diagram

Produce the final flow diagram:

1. Use a consistent visual language:
   - **Rectangles** — screens/views
   - **Diamonds** — decision points
   - **Rounded rectangles** — actions
   - **Circles** — start/end points
   - **Dashed lines** — error/alternative paths
2. Annotate with:
   - Step numbers
   - Transition labels (triggers and conditions)
   - Motion type indicators
   - Error flow branches
3. Include a legend explaining the visual symbols
4. Provide the diagram in a format that can be maintained:
   - Mermaid diagram code (preferred for version control)
   - Figma/FigJam link (for collaborative editing)

---

## Output Format

```markdown
# User Flow: {Flow Name}

**Designer:** @interaction-dsgn
**Date:** {YYYY-MM-DD}
**Status:** Draft | Reviewed | Approved

## Journey Map
{Step listing from Step 1}

## State Transitions
{Transition table from Step 2}

## Interaction Annotations
{From Step 3}

## Motion Specification
{From Step 4}

## Error & Edge Cases
{From Step 5}

## Flow Diagram
{From Step 6}
```

---

*Apex Squad — User Flow Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-user-flow-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Every step must have defined entry/exit points and triggers"
    - "State transitions must include guard conditions and loading states"
    - "Error and edge case flows must be documented for validation, network, and permission errors"
    - "Visual flow diagram must be provided in a maintainable format (Mermaid or Figma)"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@react-eng` or `@motion-eng` |
| Artifact | User flow diagram, state transition map, interaction annotations, motion specification per transition, and error/edge case flow definitions |
| Next action | Route to `@react-eng` for implementation or to `@motion-eng` for transition animation design |
