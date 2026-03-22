# Task: cross-browser-validation

```yaml
id: cross-browser-validation
version: "1.0.0"
title: "Cross-Browser Validation"
description: >
  Validates visual and functional consistency across the target
  browser matrix. Tests layout, CSS feature support, animation
  behavior, and form interactions in Chrome, Safari, Firefox,
  and Edge. Documents browser-specific issues with workarounds.
elicit: false
owner: qa-visual
executor: qa-visual
outputs:
  - Browser matrix definition
  - Layout consistency test results
  - CSS feature support analysis
  - Animation behavior verification
  - Form interaction test results
  - Browser-specific issue documentation
```

---

## When This Task Runs

This task runs when:
- A new feature uses CSS features that may not be universally supported
- Before a production release to verify cross-browser compatibility
- After a CSS refactoring or framework upgrade
- Users report browser-specific rendering issues
- `*cross-browser` or `*browser-validation` is invoked

This task does NOT run when:
- Only visual regression testing is needed within a single browser (use `visual-regression-audit`)
- The task is about theme-specific visual testing (use `theme-visual-testing`)
- The task is about device/platform testing (delegate to `@qa-xplatform`)

---

## Execution Steps

### Step 1: Define Browser Matrix

Establish the browser and version matrix for testing.

**Target browser matrix:**

| Browser | Engine | Versions | Priority | Platform |
|---------|--------|----------|----------|----------|
| Chrome | Blink | Latest, Latest-1 | High | Windows, macOS, Linux |
| Safari | WebKit | Latest, Latest-1 | High | macOS, iOS |
| Firefox | Gecko | Latest, Latest-1 | Medium | Windows, macOS |
| Edge | Blink (Chromium) | Latest | Medium | Windows |
| Samsung Internet | Blink | Latest | Low | Android |

**Mobile browser matrix:**

| Browser | Platform | Priority |
|---------|----------|----------|
| Safari | iOS 16+, iOS 17+ | High |
| Chrome | Android 12+, Android 13+ | High |
| Samsung Internet | Android | Low |

**Decision criteria for matrix scope:**
- Check analytics data for actual user browser distribution
- Prioritize browsers that represent > 5% of traffic
- Always include Safari (most likely to have rendering differences from Chrome)
- Always include Firefox (independent rendering engine)

**Output:** Browser testing matrix with priorities.

### Step 2: Test Layout Consistency

Verify that page layouts render correctly across all target browsers.

**Layout features to test:**

| Feature | Potential Issues |
|---------|-----------------|
| Flexbox | `gap` not supported in older Safari (< 14.1) |
| CSS Grid | `subgrid` not supported in Chrome < 117 |
| Container Queries | Not supported in older browsers |
| `:has()` selector | Not supported in Firefox < 121 |
| `dvh` / `svh` / `lvh` | Inconsistent in older browsers |
| `overflow: clip` | Not supported in Safari < 16 |
| Scroll Snap | Behavior differences between browsers |
| `aspect-ratio` | Not supported in Safari < 15 |

**Testing process:**
1. Open the application in each browser
2. Navigate through all key pages
3. Compare layouts at each viewport size (mobile, tablet, desktop)
4. Check for:
   - Alignment differences
   - Spacing inconsistencies
   - Overflow/clipping differences
   - Text wrapping differences
   - Scrollbar appearance differences

**Automated layout testing with Playwright:**
```typescript
const browsers = ['chromium', 'firefox', 'webkit'];

for (const browserType of browsers) {
  test(`layout: ${browserType}`, async ({ browser }) => {
    const page = await browser.newPage();
    await page.goto('/');
    await expect(page).toHaveScreenshot(`home-${browserType}.png`);
  });
}
```

**Output:** Layout consistency results per browser with screenshots.

### Step 3: Check CSS Feature Support

Audit CSS features used in the project against browser support data.

**How to check:**
1. Identify all CSS features used in the codebase
2. Cross-reference each with caniuse.com support data
3. Flag features that are not supported in any target browser

**Critical CSS features to verify:**

```css
/* Check each feature in target browsers */
@layer base, components, utilities;  /* Cascade Layers */
color: oklch(0.7 0.15 200);         /* OKLCH color space */
container-type: inline-size;          /* Container Queries */
:has(.active)                         /* :has() selector */
text-wrap: balance;                   /* Text Wrap Balance */
view-transition-name: hero;           /* View Transitions */
@property --custom                    /* @property */
overscroll-behavior: contain;         /* Overscroll Behavior */
scrollbar-gutter: stable;             /* Scrollbar Gutter */
```

**Feature detection strategy:**
```css
/* Progressive enhancement with @supports */
.container {
  display: flex;  /* Fallback */
  flex-wrap: wrap;
}

@supports (display: grid) {
  .container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
}
```

**Polyfill decisions:**
| Feature | Polyfill Available? | Recommendation |
|---------|-------------------|----------------|
| Container Queries | Yes (polyfill.io) | Polyfill for Safari < 16 |
| `:has()` | No viable polyfill | Use fallback selector |
| `oklch()` colors | Yes (PostCSS plugin) | Build-time conversion |
| View Transitions | No | Progressive enhancement |

**Output:** CSS feature support matrix with fallback strategy.

### Step 4: Verify Animation Behavior

Test that animations render consistently across browsers.

**Known browser animation differences:**

| Issue | Browsers | Solution |
|-------|----------|----------|
| Spring animation timing | All (minor) | Test visually, springs are inherently cross-browser |
| `will-change` performance | Safari (aggressive) | Limit `will-change` usage |
| Transform-origin rendering | Safari (sub-pixel) | Use round pixel values |
| CSS transitions on `auto` | Firefox (no support) | Use explicit values or FLIP |
| `backdrop-filter` | Firefox (may need flag) | Feature detect, provide fallback |
| Scroll-driven animations | Safari (partial) | Progressive enhancement |
| View Transitions API | Safari (no support) | Progressive enhancement |

**Testing process:**
1. Trigger each animation in each browser
2. Observe visual smoothness (frame rate)
3. Check that animations start and end at the correct state
4. Verify animation interruption behavior (start new animation mid-current)
5. Test reduced-motion preference in each browser

**Playwright animation testing:**
```typescript
// Disable animations for consistent screenshots
await page.emulateMedia({ reducedMotion: 'reduce' });
await expect(page).toHaveScreenshot('page-no-motion.png');

// Test with animations enabled (manual review)
await page.emulateMedia({ reducedMotion: 'no-preference' });
// Record video for manual review
```

**Output:** Animation behavior test results per browser.

### Step 5: Test Form Interactions

Verify that form elements behave consistently across browsers.

**Form features to test:**

| Feature | Chrome | Safari | Firefox | Edge |
|---------|--------|--------|---------|------|
| `<input type="date">` | Native picker | Native picker (different UI) | Native picker | Native picker |
| `<input type="color">` | Native picker | Partial | Native picker | Native picker |
| `<details>/<summary>` | Full support | Full support | Full support | Full support |
| `<dialog>` | Full support | Full support (Safari 15.4+) | Full support | Full support |
| `autocomplete` | Good | Varies | Good | Good |
| Form validation UI | Browser-specific | Browser-specific | Browser-specific | Browser-specific |
| `inputmode` | Full support | Full support | Full support | Full support |

**Test each form:**
1. Tab through all form fields (keyboard accessibility)
2. Submit form with valid data
3. Submit form with invalid data (check validation messages)
4. Test autofill behavior
5. Test on mobile (virtual keyboard, autocomplete)
6. Check `<select>` dropdown rendering
7. Check file upload behavior

**Common form issues:**
- Safari autofill styles override custom CSS (`-webkit-autofill`)
- Firefox shows validation tooltips differently
- iOS Safari zoom on inputs with `font-size < 16px`
- Android Chrome form navigation with "Next" button

**Fix for iOS Safari zoom:**
```css
/* Prevent zoom on focus for iOS Safari */
input, select, textarea {
  font-size: 16px; /* Minimum to prevent zoom */
}
```

**Output:** Form interaction test results per browser.

### Step 6: Document Browser-Specific Issues

Compile all browser-specific issues with workarounds.

**Issue documentation format:**
| # | Issue | Browsers | Severity | Workaround | Status |
|---|-------|----------|----------|-----------|--------|
| 1 | Flex gap not rendering | Safari < 14.1 | High | Use margin instead | Applied |
| 2 | Dialog backdrop blur | Firefox < 120 | Medium | Fallback solid overlay | Applied |
| 3 | Date picker styling | All (varies) | Low | Accept native UI differences | Accepted |

**Per-issue documentation:**
```markdown
### Issue: [description]
**Browsers:** [affected browsers and versions]
**Severity:** Critical / High / Medium / Low
**Reproduction:** [steps to reproduce]
**Expected:** [what should happen]
**Actual:** [what happens in affected browsers]
**Workaround:** [CSS/JS fix or fallback]
**Can Use When:** [when the workaround can be removed — browser version reaches EOL]
```

**Output:** Browser-specific issue documentation with workarounds.

---

## Quality Criteria

- All browsers in the matrix must be tested (no skipped browsers)
- Layout must be visually consistent at all defined viewport sizes
- CSS features without full support must have documented fallbacks
- Form interactions must work in all target browsers
- All browser-specific issues must have documented workarounds
- Results must include specific browser versions tested

---

*Squad Apex — Cross-Browser Validation Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-cross-browser-validation
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "All browsers in the defined matrix must be tested (no skipped browsers)"
    - "CSS features without full support must have documented fallbacks or polyfills"
    - "Browser-specific issues must include workaround and severity classification"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Cross-browser validation report with issue documentation and workarounds |
| Next action | Route browser-specific fixes to `@css-eng` or `@react-eng`, or approve for release |
