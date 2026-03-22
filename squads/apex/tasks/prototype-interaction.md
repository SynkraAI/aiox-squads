# Task: prototype-interaction

```yaml
id: prototype-interaction
version: "1.0.0"
title: "Prototype Interaction"
description: >
  Create an interactive CSS-first prototype for a user interaction.
  Builds the HTML structure, implements CSS-first interactivity where
  possible, adds progressive enhancement with JavaScript, tests across
  viewports, and documents the interaction specification.
elicit: false
owner: interaction-dsgn
executor: interaction-dsgn
outputs:
  - Interactive prototype (HTML + CSS + minimal JS)
  - Interaction state documentation
  - Viewport test results
  - Progressive enhancement notes
```

---

## When This Task Runs

This task runs when:
- A new interaction pattern needs to be explored and validated
- A design concept needs a working prototype before committing to implementation
- Stakeholders need to experience an interaction before approving
- The team needs to test different interaction approaches side by side
- A complex interaction needs CSS-first feasibility validation

This task does NOT run when:
- The interaction is already well-defined and ready for production code (route to `@react-eng`)
- The prototype needs native mobile interactions (route to `@mobile-eng`)
- The focus is on production animation tuning (route to `@motion-eng`)

---

## Execution Steps

### Step 1: Define Interaction States

Map all possible states of the interaction:

1. Identify the component's states:
   - **Default** — resting state, no user interaction
   - **Hover** — cursor over the element (desktop)
   - **Focus** — keyboard focus on the element
   - **Active** — element being pressed/clicked
   - **Disabled** — element not interactive
   - **Loading** — async operation in progress
   - **Error** — something went wrong
   - **Success** — operation completed
   - **Expanded/Collapsed** — toggle states
2. Map transitions between states:
   - Which states can transition to which other states?
   - What triggers each transition (user action, async event, timer)?
3. Define entry and exit behavior for each state
4. Document the state machine as a transition table

### Step 2: Build HTML Structure

Create the semantic HTML foundation:

1. Choose the correct semantic elements:
   - `<button>` for actions, `<a>` for navigation
   - `<details>/<summary>` for disclosure
   - `<dialog>` for modals
   - `<input>` with appropriate types for form controls
2. Structure the DOM to support CSS-only state management:
   - Use `:checked`, `:focus-within`, `:target` for state
   - Use adjacent sibling selectors for related elements
   - Use `<details>` for expandable content
3. Add ARIA attributes for states CSS cannot express
4. Ensure the HTML is functional without CSS or JS (progressive baseline)

### Step 3: Implement CSS-First Approach

Build interactivity with CSS before adding JavaScript:

1. **CSS-only states:**
   - `:hover`, `:focus`, `:focus-visible`, `:active` for pointer/keyboard
   - `:checked` + label for toggle interactions
   - `<details>` for disclosure without JS
   - `:target` for in-page navigation states
   - `:has()` for parent state based on child state
2. **CSS transitions:**
   - `transition` for smooth state changes (150-300ms)
   - Use `transition-behavior: allow-discrete` for display toggling
   - Respect `prefers-reduced-motion` with a media query override
3. **CSS animations:**
   - `@keyframes` for entrance/exit animations
   - `animation-play-state` controlled by state classes
4. Document which states are achieved with pure CSS vs need JS

### Step 4: Add Progressive Enhancement

Layer JavaScript for interactions CSS cannot achieve:

1. Identify gaps in the CSS-only prototype:
   - Complex state machines (multi-step flows)
   - Async operations (API calls, timers)
   - Drag and drop
   - Focus management across multiple elements
   - Touch gestures beyond basic tap
2. Add minimal JavaScript to fill the gaps:
   - Use event delegation where possible
   - Prefer `data-*` attributes for state over class toggling
   - Keep JS focused on state management, let CSS handle visuals
3. Ensure the prototype degrades gracefully:
   - Without JS: basic functionality still works via CSS
   - Without CSS: content is accessible via semantic HTML
4. Document the enhancement layers

### Step 5: Test Across Viewports

Validate the prototype at various sizes and input modes:

1. **Touch devices (320px-428px):**
   - Touch targets are at least 44x44px
   - No hover-dependent interactions without touch alternatives
   - Swipe gestures work if applicable
2. **Tablet (768px-1024px):**
   - Layout adapts to medium container
   - Both touch and pointer input work
3. **Desktop (1280px+):**
   - Hover states provide useful feedback
   - Keyboard navigation is complete
   - Focus indicators are visible
4. **Zoom (200%, 400%):**
   - Layout does not break at high zoom
   - Text remains readable
   - Interactive elements remain accessible

### Step 6: Document Interactions

Create the interaction specification for handoff:

1. **State diagram** — visual map of all states and transitions
2. **Interaction table:**

| Trigger | From State | To State | Animation | Duration |
|---------|-----------|----------|-----------|----------|
| Click | Default | Expanded | Slide down | 200ms |
| Escape | Expanded | Default | Slide up | 150ms |

3. **CSS-only vs JS-enhanced** — what works without JS
4. **Accessibility** — keyboard navigation map, screen reader behavior
5. **Known limitations** — what the prototype does not cover
6. Link to the working prototype file

---

*Apex Squad — Prototype Interaction Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-prototype-interaction
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Prototype must be functional as HTML+CSS without JavaScript (CSS-first baseline)"
    - "Interaction states must be documented in a transition table"
    - "Prototype must be tested at mobile (320px), tablet (768px), and desktop (1280px+)"
    - "Progressive enhancement notes must document what works without JS vs with JS"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@react-eng` or `@motion-eng` |
| Artifact | Interactive prototype with interaction state documentation, viewport test results, and progressive enhancement notes |
| Next action | Implement production component based on the validated prototype interaction pattern |
