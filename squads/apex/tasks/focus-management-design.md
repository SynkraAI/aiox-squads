# Task: focus-management-design

```yaml
id: focus-management-design
version: "1.0.0"
title: "Focus Management Design"
description: >
  Designs focus management strategy for complex interactions
  including logical tab order, focus trapping for modals and
  dialogs, focus restoration on close, focus-visible styling,
  and verification through keyboard-only and screen reader testing.
elicit: false
owner: a11y-eng
executor: a11y-eng
outputs:
  - Focus order map (logical tab sequence)
  - Focus trap implementation for modals/dialogs
  - Focus restoration plan
  - Focus-visible style specifications
  - Keyboard-only test results
  - Screen reader verification
```

---

## When This Task Runs

This task runs when:
- A modal, dialog, drawer, or overlay component needs focus management
- A complex widget needs defined tab order (tab interface, accordion, menu)
- Focus is being lost during dynamic interactions (SPA navigation, item deletion)
- Custom focus indicators need to be designed
- `*focus-management` or `*design-focus` is invoked

This task does NOT run when:
- A full accessibility audit is needed (use `accessibility-audit`)
- A specific ARIA pattern needs implementation (use `aria-pattern-implementation`)
- The issue is about color contrast or screen reader announcements specifically

---

## Execution Steps

### Step 1: Map Focus Order

Define the logical tab sequence for all interactive elements in the scope.

**Mapping method:**
1. List every focusable element in the component/page
2. Number them in the order a keyboard user should encounter them
3. Verify this order matches the visual layout (left-to-right, top-to-bottom for LTR languages)

```
Login Page Focus Order:
1. Skip to content link
2. Logo (link to home)
3. Email input
4. Password input
5. "Forgot password?" link
6. "Log in" button
7. "Sign up" link
8. Footer links
```

**Focus order rules:**
- DOM order should match visual order — avoid using `tabIndex > 0` to force order
- Only use `tabIndex="0"` to make non-interactive elements focusable (custom widgets)
- Use `tabIndex="-1"` for elements that should be programmatically focusable but not in the tab order
- NEVER use positive `tabIndex` values (1, 2, 3, etc.) — they create maintenance nightmares

**Composite widget internal navigation:**
- Tab INTO the widget (first press focuses the widget)
- Arrow keys navigate WITHIN the widget
- Tab OUT of the widget (to the next element in the page)

Example: Tab list
```
[Tab 1] [Tab 2] [Tab 3]    ← Arrow keys navigate between tabs
[Tab panel content]          ← Tab key moves focus here
```

**Output:** Numbered focus order map for all interactive elements.

### Step 2: Design Focus Trapping

Implement focus trapping for modal dialogs, drawers, and other overlay components.

**Focus trap requirements:**
- When a modal opens, focus moves to the first focusable element inside
- Pressing Tab at the last focusable element cycles to the first
- Pressing Shift+Tab at the first focusable element cycles to the last
- Focus NEVER escapes the modal while it is open
- Pressing Escape closes the modal

**Implementation approach:**

```tsx
function useFocusTrap(ref: RefObject<HTMLElement>) {
  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const focusableElements = element.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), ' +
      'select:not([disabled]), textarea:not([disabled]), ' +
      '[tabindex]:not([tabindex="-1"])'
    );

    const firstFocusable = focusableElements[0] as HTMLElement;
    const lastFocusable = focusableElements[focusableElements.length - 1] as HTMLElement;

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key !== 'Tab') return;

      if (e.shiftKey) {
        if (document.activeElement === firstFocusable) {
          e.preventDefault();
          lastFocusable.focus();
        }
      } else {
        if (document.activeElement === lastFocusable) {
          e.preventDefault();
          firstFocusable.focus();
        }
      }
    }

    element.addEventListener('keydown', handleKeyDown);
    firstFocusable?.focus();

    return () => element.removeEventListener('keydown', handleKeyDown);
  }, [ref]);
}
```

**Edge cases:**
- Modal with no focusable elements — focus the modal container itself (`tabIndex="-1"`)
- Modal with dynamically loaded content — re-calculate focusable elements when content changes
- Nested modals — inner modal traps focus, outer modal is inert
- Modal with form — first focusable might be an input, not the close button (that is correct)

**Output:** Focus trap implementation specification.

### Step 3: Plan Focus Restoration

Design focus restoration for when an overlay closes or content is removed.

**Focus restoration principle:** When a modal/dialog closes, focus MUST return to the element that triggered it. The user should never be disoriented about where they are on the page.

```tsx
function useModalFocusRestore() {
  const triggerRef = useRef<HTMLElement | null>(null);

  const open = useCallback(() => {
    triggerRef.current = document.activeElement as HTMLElement;
    // Open modal...
  }, []);

  const close = useCallback(() => {
    // Close modal...
    // Restore focus after close animation completes
    requestAnimationFrame(() => {
      triggerRef.current?.focus();
      triggerRef.current = null;
    });
  }, []);

  return { open, close };
}
```

**Focus restoration scenarios:**

| Scenario | Restore Focus To |
|----------|-----------------|
| Modal closed | Element that opened the modal |
| Dropdown closed | The dropdown trigger button |
| Item deleted from list | Next item in the list (or previous if last) |
| Toast dismissed | Do NOT move focus (toast is non-modal) |
| SPA page navigation | New page heading (h1) or skip link |
| Tab closed | Adjacent tab |
| Popover closed | Popover trigger |

**When the trigger no longer exists:**
- If the triggering element was deleted (e.g., delete button that deletes its own row), focus should move to the nearest logical neighbor
- Never let focus fall to `<body>` — this is a focus loss and disorients screen reader users

**Output:** Focus restoration plan per interaction.

### Step 4: Implement Focus-Visible Styles

Design visible focus indicators that meet accessibility requirements while maintaining visual design quality.

**Requirements:**
- Focus indicator must be visible on all backgrounds (light AND dark)
- Focus indicator must have at least 3:1 contrast ratio against adjacent colors
- Focus indicator must be at least 2px thick
- Focus indicator should NOT appear on mouse click (use `:focus-visible`, not `:focus`)

**Recommended implementation:**
```css
/* Remove default outline */
:focus {
  outline: none;
}

/* Show custom focus indicator only for keyboard navigation */
:focus-visible {
  outline: 2px solid var(--color-focus);
  outline-offset: 2px;
  border-radius: var(--radius-sm);
}

/* High contrast mode support */
@media (forced-colors: active) {
  :focus-visible {
    outline: 2px solid Highlight;
  }
}
```

**Focus indicator design patterns:**

| Pattern | When to Use | Example |
|---------|-------------|---------|
| Outline | Default for most elements | `outline: 2px solid blue; outline-offset: 2px` |
| Ring | Rounded elements (buttons, badges) | `box-shadow: 0 0 0 3px var(--focus-ring)` |
| Underline | Text links within content | `text-decoration: underline 2px` |
| Background | Dark backgrounds where outlines are hard to see | `background-color: var(--focus-bg)` |

**Per-component focus styles:**
- Buttons: outline ring, 2px offset
- Text inputs: border color change + outline ring
- Links: underline + color change
- Cards: outline ring around entire card
- Checkboxes/radios: outline ring around the control

**Output:** Focus-visible CSS specifications per component type.

### Step 5: Test with Keyboard-Only

Navigate the complete scope using ONLY the keyboard to verify focus management works.

**Test procedure:**
1. Unplug or disable mouse/trackpad
2. Start from the browser address bar
3. Press Tab to enter the page
4. Navigate through every interactive element

**Verification checklist:**
- [ ] Every interactive element is reachable via Tab
- [ ] Focus order matches visual layout
- [ ] Focus indicator is visible on every element
- [ ] Modals trap focus correctly
- [ ] Modal close restores focus to trigger
- [ ] Escape closes modals and popovers
- [ ] Arrow keys work within composite widgets
- [ ] No focus is lost during any interaction
- [ ] Skip link is present and works
- [ ] Disabled elements are skipped in tab order

**Document failures:**
For each failure, record:
- Element affected
- Expected behavior
- Actual behavior
- Severity (critical if user is blocked, serious if confused, moderate if inconvenient)

**Output:** Keyboard-only test results with pass/fail per checkpoint.

### Step 6: Verify with Screen Reader

Test focus management with a screen reader to verify announcements accompany focus changes.

**Screen reader checks:**
- When focus moves to a modal, screen reader announces the modal title/role
- When focus moves to a new element, its name and role are announced
- When focus returns after modal close, the trigger element is announced
- When focus moves to an error field, the error message is announced
- Live regions announce dynamic content without moving focus

**Focus + announcement pairing:**
| Focus Event | Expected Announcement |
|------------|----------------------|
| Modal opens, focus moves to heading | "Dialog, [modal title]" |
| Tab to submit button | "Submit, button" |
| Focus moves to error field | "[field label], invalid, [error message]" |
| Modal closes, focus returns | "[trigger label], button" |
| Item deleted, focus moves to next | "[next item label]" |

**Output:** Screen reader focus management verification results.

---

## Quality Criteria

- Focus must never be lost to `<body>` during any interaction
- All modals must trap focus and restore focus on close
- Focus indicators must have at least 3:1 contrast on all backgrounds
- `:focus-visible` must be used instead of `:focus` for styling
- Keyboard-only navigation must reach every interactive element
- Screen reader must announce context when focus moves programmatically

---

*Squad Apex — Focus Management Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-focus-management-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Focus must never be lost to <body> during any tested interaction"
    - "All modals must trap focus and restore focus on close"
    - "Focus indicators must have at least 3:1 contrast ratio verified"
    - "Keyboard-only navigation must reach every interactive element"
    - "Screen reader must announce context when focus moves programmatically"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@qa-visual` or `@apex-lead` |
| Artifact | Focus management design with focus order map, trap implementation, restoration plan, and test results |
| Next action | Validate focus indicators in cross-browser testing or integrate into `screen-reader-testing` task |
