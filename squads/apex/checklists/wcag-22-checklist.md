# WCAG 2.2 Compliance Checklist — Apex Squad

> Reviewer: a11y-eng
> Purpose: Validate compliance with WCAG 2.2 guidelines across all four principles.
> Usage: Check every item. A single unchecked item blocks approval.

> **Scope:** Comprehensive WCAG 2.2 AA criterion-by-criterion checklist. Each item references a specific **WCAG success criterion** (e.g., 1.1.1, 2.4.7, 2.5.8). Used for **formal compliance verification**.
> **Use when:** Certifying WCAG 2.2 AA compliance for regulatory or formal audit purposes.
> **Related:** `a11y-review-checklist.md` (practical hands-on accessibility testing checklist).

---

## 1. Perceivable

- [ ] **1.1 Text Alternatives:** All non-text content has text alternatives (alt text, aria-label)
- [ ] **1.2 Time-Based Media:** Captions provided for video, transcripts for audio
- [ ] **1.3.1 Info and Relationships:** Semantic markup conveys structure (headings, lists, tables)
- [ ] **1.3.2 Meaningful Sequence:** DOM order matches visual order
- [ ] **1.3.3 Sensory Characteristics:** Instructions do not rely solely on shape, size, or location
- [ ] **1.3.4 Orientation:** Content works in both portrait and landscape
- [ ] **1.3.5 Identify Input Purpose:** Input fields have appropriate `autocomplete` attributes
- [ ] **1.4.1 Use of Color:** Color is not the only way to convey information
- [ ] **1.4.3 Contrast (Minimum):** Text contrast ratio >= 4.5:1 (AA)
- [ ] **1.4.4 Resize Text:** Text can be resized to 200% without loss of content
- [ ] **1.4.10 Reflow:** Content reflows at 320px width without horizontal scrolling
- [ ] **1.4.11 Non-Text Contrast:** UI components and graphics meet 3:1 contrast
- [ ] **1.4.12 Text Spacing:** Content adapts to increased text spacing
- [ ] **1.4.13 Content on Hover/Focus:** Tooltip/popover content is dismissable, hoverable, persistent

---

## 2. Operable

- [ ] **2.1.1 Keyboard:** All functionality available via keyboard
- [ ] **2.1.2 No Keyboard Trap:** Focus can be moved away from any component
- [ ] **2.4.1 Bypass Blocks:** Skip navigation link available
- [ ] **2.4.2 Page Titled:** Each page has a descriptive title
- [ ] **2.4.3 Focus Order:** Focus order is logical and intuitive
- [ ] **2.4.6 Headings and Labels:** Headings and labels describe topic or purpose
- [ ] **2.4.7 Focus Visible:** Focus indicator is clearly visible
- [ ] **2.4.11 Focus Not Obscured (Minimum):** Focused element is not fully hidden by other content
- [ ] **2.4.12 Focus Not Obscured (Enhanced):** Focused element is fully visible (not partially hidden)
- [ ] **2.4.13 Focus Appearance:** Focus indicator is >= 2px thick, 3:1 contrast (WCAG 2.2 new)
- [ ] **2.5.1 Pointer Gestures:** Multi-point gestures have single-pointer alternative
- [ ] **2.5.2 Pointer Cancellation:** Down-event does not trigger action (up-event or abort)
- [ ] **2.5.7 Dragging Movements:** Drag operations have non-dragging alternative (WCAG 2.2 new)
- [ ] **2.5.8 Target Size (Minimum):** Touch targets are at least 24x24px (WCAG 2.2 new)

---

## 3. Understandable

- [ ] **3.1.1 Language of Page:** `lang` attribute set on `<html>` element
- [ ] **3.1.2 Language of Parts:** `lang` attribute set on content in different language
- [ ] **3.2.1 On Focus:** Focus does not trigger unexpected context change
- [ ] **3.2.2 On Input:** Input does not trigger unexpected context change
- [ ] **3.2.6 Consistent Help:** Help mechanisms appear in same relative location (WCAG 2.2 new)
- [ ] **3.3.1 Error Identification:** Errors are clearly identified and described in text
- [ ] **3.3.2 Labels or Instructions:** Form fields have visible labels
- [ ] **3.3.3 Error Suggestion:** Error messages suggest correction
- [ ] **3.3.7 Redundant Entry:** Previously entered info is auto-populated or selectable (WCAG 2.2 new)
- [ ] **3.3.8 Accessible Authentication (Minimum):** No cognitive test for auth unless alternative provided (WCAG 2.2 new)

---

## 4. Robust

- [ ] **4.1.2 Name, Role, Value:** Custom components expose correct name, role, and value
- [ ] **4.1.3 Status Messages:** Status messages use `aria-live` or role="status" (no focus move required)
- [ ] ARIA attributes are valid (`aria-*` values match expected types)
- [ ] ARIA roles are used correctly (not conflicting with native semantics)
- [ ] No duplicate IDs in the DOM
- [ ] Custom widgets follow WAI-ARIA Authoring Practices

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| WCAG Level | AA / AAA |
| Tools Used | axe / Lighthouse / WAVE / manual |
| Result | APPROVED / BLOCKED |
| Notes | |
