# Task: screen-reader-testing

```yaml
id: screen-reader-testing
version: "1.0.0"
title: "Screen Reader Testing"
description: >
  Comprehensive screen reader testing of a component or page across
  multiple platforms. Tests with VoiceOver (macOS/iOS), NVDA (Windows),
  and TalkBack (Android). Verifies heading hierarchy, link/button
  announcements, form label associations, and overall navigability.
  Documents findings with specific screen reader output.
elicit: false
owner: a11y-eng
executor: a11y-eng
outputs:
  - VoiceOver (macOS/iOS) test results
  - NVDA (Windows) test results
  - TalkBack (Android) test results
  - Heading hierarchy validation
  - Link and button announcement check
  - Form label association verification
  - Findings document with remediation guidance
```

---

## When This Task Runs

This task runs when:
- A component or page needs screen reader verification before release
- The accessibility audit identified screen reader issues that need detailed testing
- A complex widget has been implemented and needs screen reader validation
- The team wants to understand how their content reads in a screen reader
- `*screen-reader-test` or `*test-screen-reader` is invoked

This task does NOT run when:
- A full accessibility audit is needed (use `accessibility-audit`)
- ARIA patterns need to be implemented first (use `aria-pattern-implementation`)
- Only keyboard navigation needs testing (covered in `focus-management-design`)

---

## Execution Steps

### Step 1: Test with VoiceOver (macOS/iOS)

Test the audited scope with Apple VoiceOver, the most widely used screen reader on macOS and iOS.

**macOS VoiceOver setup:**
- Enable: Cmd+F5 (or System Settings → Accessibility → VoiceOver)
- VoiceOver key (VO): Ctrl+Option
- Navigate: VO+Right Arrow (next element), VO+Left Arrow (previous)
- Activate: VO+Space
- Read all: VO+A
- Rotor: VO+U (access headings, links, landmarks)

**Testing protocol:**
1. Enable VoiceOver
2. Navigate to the page under test
3. Use VO+Right Arrow to read through all content sequentially
4. Use the Rotor (VO+U) to navigate by:
   - Headings (H key in web rotor)
   - Links
   - Form controls
   - Landmarks (regions)
5. Interact with every interactive element
6. Test form submission flow
7. Test modal/dialog opening and closing
8. Test dynamic content updates (live regions)

**Record for each element:**
| Element | Expected Announcement | Actual Announcement | Pass/Fail |
|---------|----------------------|---------------------|-----------|
| Main heading | "Welcome to Dashboard, heading level 1" | | |
| Search input | "Search, search text field" | | |
| Submit button | "Submit, button" | | |

**iOS VoiceOver testing:**
- Enable: Triple-click side button (or Settings → Accessibility → VoiceOver)
- Navigate: Swipe right (next), swipe left (previous)
- Activate: Double-tap
- Test touch exploration (drag finger across screen)
- Test Magic Tap (two-finger double-tap for primary action)

**Output:** VoiceOver test results for macOS and iOS.

### Step 2: Test with NVDA (Windows)

Test with NVDA (NonVisual Desktop Access), the most popular free screen reader on Windows.

**NVDA setup:**
- Download from nvaccess.org
- Browse mode (default): Arrow keys read through content
- Focus mode: Tab between interactive elements
- Toggle: NVDA+Space
- Element list: NVDA+F7 (headings, links, landmarks, form fields)
- Read all: NVDA+Down Arrow

**Testing protocol:**
1. Start NVDA
2. Open the page in Chrome (NVDA+Chrome is the most common combination)
3. Read through all content with Down Arrow (browse mode)
4. Navigate by headings: H key
5. Navigate by landmarks: D key
6. Navigate by links: K key
7. Navigate by form fields: F key
8. Switch to focus mode (NVDA+Space) and Tab through forms
9. Interact with all interactive elements
10. Test dynamic content announcements

**NVDA-specific checks:**
- Browse mode reads all content (including decorative elements — are they hidden with `aria-hidden`?)
- Forms mode activation is correct (NVDA auto-switches for form fields)
- Element list (NVDA+F7) shows all expected headings, links, landmarks
- Speech output matches expected announcements

**Common NVDA vs VoiceOver differences:**
| Scenario | VoiceOver Behavior | NVDA Behavior |
|----------|-------------------|---------------|
| `role="status"` | May not announce | Announces as "status" |
| `aria-live="polite"` | Announces after current | Announces after current (timing may differ) |
| Group labels | Announces group label on enter | May announce on each item |
| Table navigation | Ctrl+Option+Arrow | Ctrl+Alt+Arrow |

**Output:** NVDA test results with comparison to VoiceOver behavior.

### Step 3: Test with TalkBack (Android)

Test with TalkBack, the screen reader built into Android.

**TalkBack setup:**
- Enable: Settings → Accessibility → TalkBack
- Navigate: Swipe right (next), swipe left (previous)
- Activate: Double-tap
- Read from current: Three-finger tap then swipe right
- Headings: Swipe up/down to change navigation granularity, then swipe right

**Testing protocol:**
1. Enable TalkBack
2. Open the page in Chrome for Android
3. Explore by touch (drag finger to hear elements)
4. Swipe through all content
5. Change navigation granularity to headings, links, controls
6. Interact with forms and buttons
7. Test gestures (if applicable to the app)

**Android-specific considerations:**
- Touch exploration: TalkBack reads what is under the finger
- Gesture navigation may conflict with app gestures
- Custom views need `contentDescription` for native apps
- Web content in WebView may behave differently than Chrome

**Output:** TalkBack test results.

### Step 4: Verify Heading Hierarchy

Check that the heading structure creates a logical document outline.

**Heading rules:**
- Page must have exactly one `<h1>` (the page title)
- Headings must not skip levels (h1 → h3 without h2 is wrong)
- Headings must reflect content hierarchy, not visual size
- Use CSS to style heading appearance, not heading level

**Check heading structure:**
```
h1: Dashboard
  h2: Revenue Overview
    h3: Monthly Revenue
    h3: Annual Revenue
  h2: Recent Activity
    h3: Today
    h3: This Week
  h2: Settings
```

**Testing method:**
- VoiceOver Rotor → Headings → review the list
- NVDA → NVDA+F7 → Headings tab → review hierarchy
- HTML5 Outliner browser extension

**Common heading issues:**
- No `<h1>` on the page
- Multiple `<h1>` elements (acceptable in some patterns, but usually wrong)
- Heading levels skipped (h2 → h4)
- Headings used for visual styling instead of document structure
- Important sections without headings (screen reader users cannot jump to them)
- Hidden headings that create confusing outline

**Output:** Heading hierarchy audit with corrections needed.

### Step 5: Check Link and Button Announcements

Verify that every link and button announces its purpose clearly.

**Link announcement rules:**
- Link text must describe the destination ("Read our pricing" not "Click here")
- If link text is generic ("Read more"), use `aria-label` or `aria-labelledby` to provide context
- Links that open in a new window should indicate this (visually and to screen readers)
- Adjacent links to the same destination should be combined

**Button announcement rules:**
- Button text must describe the action ("Submit form" not just "Submit" if ambiguous)
- Icon-only buttons MUST have `aria-label` ("Close", "Delete", "Menu")
- Toggle buttons must announce their state (`aria-pressed="true/false"`)

**Testing each link:**
| Link | Announced Text | Destination Clear? | Pass/Fail |
|------|---------------|-------------------|-----------|
| "Read more" | "Read more, link" | No — more about what? | FAIL |
| "View pricing details" | "View pricing details, link" | Yes | PASS |

**Testing each button:**
| Button | Announced Text | Action Clear? | Pass/Fail |
|--------|---------------|--------------|-----------|
| [X] icon | "button" (no label!) | No — no name | FAIL |
| [X] icon with aria-label | "Close dialog, button" | Yes | PASS |
| Toggle | "Dark mode, toggle button, pressed" | Yes, with state | PASS |

**Output:** Link and button announcement audit.

### Step 6: Verify Form Label Associations

Check that every form input is properly associated with its label.

**Label association methods (in order of preference):**
1. `<label for="inputId">` — explicit association
2. `<label>` wrapping the input — implicit association
3. `aria-labelledby="labelId"` — ARIA association
4. `aria-label="Label text"` — hidden label (last resort)

**Testing each form field:**
```
For each input:
1. Focus the input with Tab
2. Screen reader should announce: "[Label], [input type]"
3. If it only announces "[input type]" without a label, the association is broken
```

| Field | HTML | Announced | Associated? |
|-------|------|-----------|-------------|
| Email | `<input id="email">` (no label) | "edit text" | NO — missing label |
| Email | `<label for="email">Email</label> <input id="email">` | "Email, edit text" | YES |
| Search | `<input aria-label="Search products">` | "Search products, search text field" | YES |

**Additional form checks:**
- Required fields announce "required" (`aria-required="true"` or `required` attribute)
- Error messages are associated with their field (`aria-describedby="error-id"`)
- Help text/instructions are associated (`aria-describedby`)
- Field groups use `<fieldset>` and `<legend>` (or `role="group"` with `aria-labelledby`)
- Autocomplete attributes are present for common fields (`autocomplete="email"`)

**Output:** Form label association audit results.

### Step 7: Document Findings

Compile all testing results into a findings document with remediation guidance.

```markdown
## Screen Reader Testing Report — [Scope]

### Testing Matrix
| Screen Reader | Version | Browser | Platform | Tested |
|--------------|---------|---------|----------|--------|
| VoiceOver | macOS 14 | Safari 17 | macOS | Yes |
| NVDA | 2024.1 | Chrome 120 | Windows | Yes |
| TalkBack | 14.0 | Chrome | Android 14 | Yes |

### Summary
- Total elements tested: {N}
- Elements passing all screen readers: {N}
- Elements with issues: {N}

### Findings
| # | Issue | Screen Readers Affected | Severity | Fix |
|---|-------|------------------------|----------|-----|
| 1 | Search button has no accessible name | All | Critical | Add aria-label="Search" |
| 2 | Heading hierarchy skips h3 | All | Serious | Change h4 to h3 |

### Heading Structure
[From Step 4]

### Form Associations
[From Step 6]

### Recommendations
1. ...
2. ...
```

**Output:** Complete screen reader testing report.

---

## Quality Criteria

- Testing must include at least VoiceOver and one other screen reader
- Every interactive element must have a meaningful accessible name
- Heading hierarchy must be logical with no skipped levels
- All form inputs must be properly labeled
- Link text must describe the destination, not just "click here"
- Findings must include specific fix recommendations

---

*Squad Apex — Screen Reader Testing Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-screen-reader-testing
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Testing must include at least VoiceOver and one other screen reader (NVDA or TalkBack)"
    - "Every interactive element must have a verified meaningful accessible name"
    - "Heading hierarchy must be validated with no skipped levels"
    - "All form inputs must be verified for proper label association"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Screen reader testing report with VoiceOver, NVDA, and TalkBack results, heading hierarchy validation, link/button announcements, form label associations, and remediation guidance |
| Next action | Route remediation items to `@a11y-eng` for `aria-pattern-implementation` or to `@react-eng` for component fixes |
