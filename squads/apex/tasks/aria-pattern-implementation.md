# Task: aria-pattern-implementation

```yaml
id: aria-pattern-implementation
version: "1.0.0"
title: "ARIA Design Pattern Implementation"
description: >
  Implements a WAI-ARIA design pattern for a custom interactive
  widget. Maps roles, states, and properties from the ARIA
  authoring practices, implements the correct keyboard interaction
  model, adds aria-live regions where needed, tests with screen
  readers, and validates against the WAI-ARIA specification.
elicit: false
owner: a11y-eng
executor: a11y-eng
outputs:
  - WAI-ARIA pattern identification
  - Role, state, and property mapping
  - Keyboard interaction model
  - aria-live region configuration
  - Screen reader test results
  - WAI-ARIA authoring practices validation
```

---

## When This Task Runs

This task runs when:
- A custom interactive widget needs accessible markup (tabs, menus, combobox, dialog, accordion, etc.)
- An existing widget is not announced correctly by screen readers
- A developer needs guidance on which ARIA pattern to use
- The accessibility audit flagged ARIA issues that need fixing
- `*aria-pattern` or `*implement-aria` is invoked

This task does NOT run when:
- The element can be built with native HTML that already has the correct semantics (prefer `<button>` over `<div role="button">`)
- A full accessibility audit is needed (use `accessibility-audit`)
- Only focus management is needed (use `focus-management-design`)

---

## Execution Steps

### Step 1: Identify WAI-ARIA Pattern

Match the widget to the correct WAI-ARIA Authoring Practices pattern.

**Common patterns:**

| Widget | ARIA Pattern | Key Roles |
|--------|-------------|-----------|
| Tabs | Tabs | `tablist`, `tab`, `tabpanel` |
| Modal/Dialog | Dialog (Modal) | `dialog`, `alertdialog` |
| Dropdown menu | Menu | `menu`, `menuitem`, `menuitemcheckbox` |
| Combobox/Autocomplete | Combobox | `combobox`, `listbox`, `option` |
| Accordion | Accordion | `button` (headers), `region` (panels) |
| Tree view | Tree View | `tree`, `treeitem`, `group` |
| Carousel | Carousel | `group` or `region`, controls |
| Toolbar | Toolbar | `toolbar`, child buttons |
| Disclosure | Disclosure | `button` with `aria-expanded` |
| Alert | Alert | `alert` (live region) |
| Toast | Status | `status` (polite live region) |
| Breadcrumb | Breadcrumb | `navigation`, `list`, `listitem` |
| Feed | Feed | `feed`, `article` |
| Slider | Slider | `slider` with `aria-valuenow/min/max` |

**First rule of ARIA: Do not use ARIA if native HTML can do the job.**
- Use `<button>` instead of `<div role="button">`
- Use `<select>` instead of custom dropdown when possible
- Use `<details>/<summary>` instead of custom disclosure when possible
- Use `<dialog>` element with `showModal()` instead of custom modal when possible

**When custom ARIA IS needed:**
- Native element does not support the interaction pattern (combobox with autocomplete)
- Design requirements cannot be met with native styling (custom select)
- The widget is complex enough that no native element covers it (tree view, feed)

**Output:** Identified ARIA pattern with link to WAI-ARIA authoring practices reference.

### Step 2: Map Roles, States, and Properties

Define every ARIA attribute needed for the widget.

**Example: Tabs pattern**

```tsx
// TabList container
<div role="tablist" aria-label="Account settings">

  // Each Tab
  <button
    role="tab"
    aria-selected={isActive}          // true for active tab, false for others
    aria-controls={`panel-${id}`}     // links tab to its panel
    id={`tab-${id}`}                  // referenced by panel's aria-labelledby
    tabIndex={isActive ? 0 : -1}      // roving tabindex
  >
    {label}
  </button>

  // Each TabPanel
  <div
    role="tabpanel"
    id={`panel-${id}`}                // matches tab's aria-controls
    aria-labelledby={`tab-${id}`}     // links panel to its tab
    tabIndex={0}                       // panel is focusable
    hidden={!isActive}                 // hidden when not active
  >
    {content}
  </div>
</div>
```

For the target pattern, document:
| Element | Role | Required States/Properties | Optional States/Properties |
|---------|------|---------------------------|---------------------------|
| Container | `tablist` | `aria-label` or `aria-labelledby` | `aria-orientation` |
| Tab | `tab` | `aria-selected`, `aria-controls` | `aria-disabled` |
| Panel | `tabpanel` | `aria-labelledby` | `aria-hidden` |

**State update rules:**
- When must each state change?
- What triggers the state change?
- Are state changes reflected in the DOM immediately?

**Output:** Complete ARIA role/state/property mapping table.

### Step 3: Implement Keyboard Interaction Model

Implement the keyboard interaction pattern specified by WAI-ARIA Authoring Practices.

**Example: Tabs keyboard pattern**

| Key | Action |
|-----|--------|
| Tab | Moves focus into the tab list (to the active tab) |
| Arrow Right | Moves focus to the next tab, activates it |
| Arrow Left | Moves focus to the previous tab, activates it |
| Home | Moves focus to the first tab, activates it |
| End | Moves focus to the last tab, activates it |
| Tab (from tab) | Moves focus to the tab panel content |

**Implementation with roving tabindex:**
```tsx
function handleKeyDown(event: React.KeyboardEvent, currentIndex: number) {
  const tabCount = tabs.length;
  let newIndex = currentIndex;

  switch (event.key) {
    case 'ArrowRight':
      newIndex = (currentIndex + 1) % tabCount;
      break;
    case 'ArrowLeft':
      newIndex = (currentIndex - 1 + tabCount) % tabCount;
      break;
    case 'Home':
      newIndex = 0;
      break;
    case 'End':
      newIndex = tabCount - 1;
      break;
    default:
      return; // Do not prevent default for other keys
  }

  event.preventDefault();
  setActiveTab(newIndex);
  tabRefs[newIndex].current?.focus();
}
```

**Two focus management strategies:**

| Strategy | How It Works | When to Use |
|----------|-------------|-------------|
| Roving tabindex | Active item gets `tabIndex={0}`, others get `tabIndex={-1}` | Tabs, radio groups, toolbars |
| aria-activedescendant | Container stays focused, `aria-activedescendant` points to visual focus | Combobox, listbox, tree (many items) |

Choose roving tabindex for small sets (< 20 items) and aria-activedescendant for large or virtualized lists.

**Output:** Keyboard interaction implementation with key handlers.

### Step 4: Add aria-live Regions Where Needed

Configure live regions for dynamic content that changes without user interaction or should be announced.

**aria-live values:**

| Value | Behavior | Use When |
|-------|----------|----------|
| `polite` | Announced after current speech finishes | Status messages, search result counts |
| `assertive` | Interrupts current speech immediately | Error messages, critical alerts |
| `off` | Not announced | Frequently updating content (stock tickers) |

**Implementation patterns:**

```tsx
// Status message (polite)
<div role="status" aria-live="polite">
  {searchResults.length} results found
</div>

// Error alert (assertive)
<div role="alert" aria-live="assertive">
  {errorMessage}
</div>

// Loading state
<div aria-live="polite" aria-busy={isLoading}>
  {isLoading ? 'Loading...' : 'Content loaded'}
</div>
```

**aria-live rules:**
- The live region container MUST exist in the DOM BEFORE content changes (do not dynamically add `aria-live` — add the container on mount, change content later)
- Use `role="status"` as shorthand for `aria-live="polite"`
- Use `role="alert"` as shorthand for `aria-live="assertive"`
- Do NOT put `aria-live="assertive"` on frequently changing content (it will constantly interrupt)
- Use `aria-atomic="true"` when the entire region should be re-announced on any change
- Use `aria-relevant="additions text"` to control what changes trigger announcements

**Output:** aria-live region configuration for all dynamic content.

### Step 5: Test with Screen Readers

Verify the ARIA pattern works correctly with actual screen readers.

**Testing protocol per screen reader:**

1. **Navigate to the widget** using screen reader navigation (Tab or arrow keys)
2. **Verify role announcement** — does the screen reader announce the correct widget type?
3. **Verify state announcement** — are states (selected, expanded, checked) announced?
4. **Test keyboard interaction** — do arrow keys, Enter, Escape work as specified?
5. **Verify state changes** — when interacting, are new states announced?
6. **Verify live regions** — are dynamic updates announced at the right time?
7. **Test with forms mode and browse mode** — widget should work in both

**Screen reader testing matrix:**

| Screen Reader | Browser | Platform | Priority |
|--------------|---------|----------|----------|
| VoiceOver | Safari | macOS | High |
| NVDA | Chrome | Windows | High |
| VoiceOver | Safari | iOS | High |
| TalkBack | Chrome | Android | Medium |
| JAWS | Chrome | Windows | Medium |

**Document for each test:**
- What was announced (verbatim if possible)
- Was the announcement helpful and accurate?
- Were state changes communicated?
- Did keyboard navigation work as expected?

**Output:** Screen reader test results per screen reader.

### Step 6: Validate Against WAI-ARIA Authoring Practices

Final validation that the implementation matches the specification.

**Validation checklist:**
- [ ] All required roles are present
- [ ] All required states/properties are present and update correctly
- [ ] Keyboard pattern matches the specification exactly
- [ ] Focus management follows the specified strategy (roving tabindex or activedescendant)
- [ ] No prohibited ARIA attributes are used
- [ ] No roles have missing required children/parents
- [ ] Screen readers announce the widget type correctly
- [ ] Screen readers announce state changes correctly
- [ ] The widget is operable with keyboard only
- [ ] Live regions announce at appropriate times

**Automated validation:**
- Run axe-core to catch any programmatic ARIA errors
- Run aria-query or WAI-ARIA validator for role/property validation
- Check HTML validator for ARIA-related warnings

**Output:** Validation results with pass/fail per checklist item.

---

## Quality Criteria

- Native HTML must be preferred over ARIA where possible
- Every ARIA role must have all required states and properties
- Keyboard interaction must match WAI-ARIA Authoring Practices exactly
- aria-live regions must exist in DOM before content changes
- Widget must be tested with at least 2 screen readers
- No ARIA attribute should be used without understanding its effect on announcement

---

*Squad Apex — ARIA Pattern Implementation Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-aria-pattern-implementation
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "ARIA roles and states must conform to WAI-ARIA 1.2 specification"
    - "Keyboard interaction model must match the expected pattern (e.g., roving tabindex for tabs)"
    - "Screen reader tests must pass on at least one screen reader per platform"
    - "aria-live regions must be validated for dynamic content announcements"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@qa-visual` or `@apex-lead` |
| Artifact | ARIA pattern implementation with role/state mapping, keyboard model, and screen reader test results |
| Next action | Include in cross-browser validation or visual regression testing to verify ARIA states render correctly |
