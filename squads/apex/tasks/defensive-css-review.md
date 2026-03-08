# Task: defensive-css-review

```yaml
id: defensive-css-review
version: "1.0.0"
title: "Defensive CSS Review"
description: >
  Apply defensive CSS patterns to prevent common layout breakage. Scans
  for overflow issues, text truncation problems, image sizing gaps, flex
  and grid minimum width bugs, validates with extreme content, and adds
  protective patterns where missing.
elicit: false
owner: interaction-dsgn
executor: interaction-dsgn
outputs:
  - Defensive CSS audit report
  - List of applied defensive patterns
  - Before/after comparison for fixed issues
  - Extreme content test results
```

---

## When This Task Runs

This task runs when:
- A component or page has overflow or layout breakage bugs
- New components are being reviewed before production release
- Localization reveals layout issues with longer translated text
- QA reports visual breakage with unexpected content
- A defensive CSS audit is part of the component maturation process

This task does NOT run when:
- The issue is about design tokens or colors (route to `@design-sys-eng`)
- The issue is about animation or motion (route to `@motion-eng`)
- The issue requires a full layout rewrite (use `layout-strategy`)

---

## Defensive CSS Patterns

The following patterns should be applied where appropriate:

```yaml
patterns:
  overflow_protection:
    description: "Prevent content from breaking out of containers"
    priority: CRITICAL

  text_safety:
    description: "Handle text of any length gracefully"
    priority: CRITICAL

  image_resilience:
    description: "Images never break layout regardless of source"
    priority: HIGH

  flex_grid_guards:
    description: "Prevent flex/grid children from overflowing"
    priority: HIGH

  scroll_containment:
    description: "Prevent unintended scrollbars"
    priority: MEDIUM
```

---

## Execution Steps

### Step 1: Scan for Overflow Issues

Identify elements that can overflow their containers:

1. Search for containers without explicit overflow handling:
   - Missing `overflow: hidden`, `overflow: auto`, or `overflow: clip`
   - Elements with fixed width/height containing dynamic content
2. Check for horizontal scrollbar triggers:
   - Elements with `width: 100vw` (does not account for scrollbar)
   - Absolutely positioned elements extending beyond viewport
   - Tables without `table-layout: fixed` or `overflow-x: auto`
3. Inspect elements with `position: absolute` or `position: fixed`:
   - Verify they do not create unexpected overflow
   - Check for missing `overflow: hidden` on containing blocks
4. Test by resizing the browser to various widths and observing overflow
5. Document each overflow issue with the selector and fix

### Step 2: Check Text Truncation and Wrapping

Ensure text handles all lengths gracefully:

1. **Long words without spaces:**
   - Apply `overflow-wrap: break-word` on text containers
   - Use `word-break: break-word` as fallback for older browsers
   - Consider `hyphens: auto` for natural word breaking
2. **Single-line text that must truncate:**
   ```css
   .truncate {
     white-space: nowrap;
     overflow: hidden;
     text-overflow: ellipsis;
   }
   ```
3. **Multi-line truncation:**
   ```css
   .line-clamp {
     display: -webkit-box;
     -webkit-line-clamp: 3;
     -webkit-box-orient: vertical;
     overflow: hidden;
   }
   ```
4. **Dynamic text in fixed containers:**
   - Verify `min-width` and `max-width` are set appropriately
   - Check that text does not push siblings off-screen
5. Test with strings: "W" (narrow), "WWWWWWWWWWWWWWWW" (wide, no breaks), and a 200-character paragraph

### Step 3: Verify Image Aspect Ratio and Object Fit

Ensure images never break layout:

1. Check that all content images have:
   ```css
   img {
     max-width: 100%;
     height: auto;
   }
   ```
2. For images with a defined container:
   ```css
   .image-container {
     aspect-ratio: 16 / 9;
   }
   .image-container img {
     width: 100%;
     height: 100%;
     object-fit: cover;
   }
   ```
3. Verify fallback for broken images:
   - Does the layout still work if the image fails to load?
   - Is there an `alt` text and a styled fallback?
4. Check background images:
   - `background-size: cover` or `contain` as appropriate
   - Fallback background color defined
5. Test with images of extreme aspect ratios (1:10, 10:1) and missing `src`

### Step 4: Test Flex and Grid min-width: 0

Prevent flex and grid children from overflowing:

1. **Flex children:**
   - Check all flex containers for children that could overflow
   - Apply `min-width: 0` to flex children containing text or content
   - Verify `flex-shrink` is not `0` unless intentional
   ```css
   .flex-child {
     min-width: 0; /* allows shrinking below content size */
   }
   ```
2. **Grid children:**
   - Apply `min-width: 0` and `min-height: 0` to grid children
   - Use `minmax(0, 1fr)` instead of `1fr` for tracks with overflow risk
   ```css
   .grid {
     grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
   }
   ```
3. Check for flex items with `flex-basis: auto` containing long text
4. Verify no grid item pushes its track beyond the container

### Step 5: Validate with Extreme Content

Stress-test with content that real users might produce:

1. **Text extremes:**
   - Single character: "A"
   - Very long word: "Supercalifragilisticexpialidocious" or a URL
   - Very long paragraph: 500+ characters
   - Empty string: ""
   - Right-to-left text: Arabic or Hebrew characters
2. **Number extremes:**
   - "$0.01" vs "$1,000,000,000.00"
   - "1" vs "999,999"
3. **List extremes:**
   - 0 items, 1 item, 3 items, 50+ items
4. **Mixed content:**
   - Emoji in text: breaks line-height assumptions
   - Code snippets: monospace text with long lines
5. Document which components break and which defensive patterns fix them

### Step 6: Add Defensive Patterns

Apply fixes for all discovered issues:

1. Add the minimum defensive CSS to the global stylesheet:
   ```css
   /* Global defensive CSS */
   img, video, svg { max-width: 100%; height: auto; }
   * { min-width: 0; }
   ```
2. Apply component-specific fixes identified in Steps 1-5
3. Add CSS custom properties for defensive values when appropriate
4. Document each pattern added with its purpose
5. Verify no visual regressions were introduced by the defensive patterns

---

## Checklist

- [ ] No horizontal overflow at any viewport width
- [ ] Long text wraps or truncates gracefully
- [ ] Images maintain aspect ratio and do not stretch layout
- [ ] Flex/grid children have min-width: 0 where needed
- [ ] Components tested with extreme content
- [ ] Defensive patterns documented

---

*Apex Squad — Defensive CSS Review Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-defensive-css-review
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Components must be tested with extreme content (long text, empty, RTL)"
    - "Before/after comparison must be provided for each applied fix"
    - "No horizontal overflow at any tested viewport width"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@css-eng` or `@apex-lead` |
| Artifact | Defensive CSS audit report with applied patterns and before/after comparisons |
| Next action | Implement remaining defensive patterns in CSS or validate with `@qa-visual` for visual regression |
