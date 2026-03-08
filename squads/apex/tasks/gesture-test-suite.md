# Task: gesture-test-suite

```yaml
id: gesture-test-suite
version: "1.0.0"
title: "Gesture Interaction Test Suite"
description: >
  Creates a comprehensive test suite for gesture interactions across
  all platforms. Inventories all gesture interactions, writes tests
  for tap/click, swipe/scroll, pinch/zoom, and long-press
  interactions, and runs them on real devices for accurate
  touch behavior validation.
elicit: false
owner: qa-xplatform
executor: qa-xplatform
outputs:
  - Gesture interaction inventory
  - Tap/click test suite
  - Swipe/scroll test suite
  - Pinch/zoom test suite
  - Long-press test suite
  - Real device test results
```

---

## When This Task Runs

This task runs when:
- A feature with complex gestures needs E2E testing
- Gesture interactions are failing on specific devices
- The team needs confidence that gestures work across platforms
- A gesture-heavy component has been redesigned
- `*gesture-test` or `*test-gestures` is invoked

This task does NOT run when:
- Gesture design is needed first (delegate to `@mobile-eng` for `gesture-design`)
- Only visual regression testing is needed (delegate to `@qa-visual`)
- The gestures are web-only mouse interactions (standard Playwright tests suffice)

---

## Execution Steps

### Step 1: Inventory All Gesture Interactions

Catalog every gesture interaction in the feature under test.

**Inventory format:**
| # | Screen/Component | Gesture | Action | Platform | Priority |
|---|-----------------|---------|--------|----------|----------|
| 1 | Product list | Tap | Open product detail | Web + Native | Critical |
| 2 | Product card | Swipe left | Delete item | Native only | High |
| 3 | Image gallery | Pinch | Zoom image | Native only | Medium |
| 4 | Image gallery | Double tap | Toggle zoom | Web + Native | Medium |
| 5 | List item | Long press | Show context menu | Native only | High |
| 6 | Map | Pan | Move map | Web + Native | High |
| 7 | Carousel | Swipe horizontal | Navigate slides | Web + Native | Critical |
| 8 | Pull-to-refresh | Swipe down | Refresh content | Native only | High |

**For each gesture, document:**
- Expected visual feedback during gesture (opacity change, translation, scale)
- Expected result on completion (navigation, state change, animation)
- Expected behavior on cancellation (snap back, no state change)
- Platform availability (web, iOS, Android, or all)

**Output:** Complete gesture interaction inventory.

### Step 2: Write Tap/Click Tests

Create tests for all tap and click interactions.

**Detox (React Native):**
```typescript
describe('Tap Interactions', () => {
  it('should open product detail on tap', async () => {
    await element(by.id('product-card-1')).tap();
    await expect(element(by.id('product-detail-screen'))).toBeVisible();
  });

  it('should toggle favorite on tap', async () => {
    await element(by.id('favorite-button-1')).tap();
    await expect(element(by.id('favorite-button-1'))).toHaveToggleValue(true);
  });

  it('should double-tap to zoom image', async () => {
    await element(by.id('product-image')).multiTap(2);
    await expect(element(by.id('zoom-indicator'))).toBeVisible();
  });

  it('should ignore taps on disabled elements', async () => {
    await element(by.id('disabled-button')).tap();
    await expect(element(by.id('action-result'))).not.toBeVisible();
  });
});
```

**Playwright (Web):**
```typescript
test.describe('Click Interactions', () => {
  test('should open product detail on click', async ({ page }) => {
    await page.getByTestId('product-card-1').click();
    await expect(page.getByTestId('product-detail-screen')).toBeVisible();
  });

  test('should toggle favorite on click', async ({ page }) => {
    await page.getByTestId('favorite-button-1').click();
    await expect(page.getByTestId('favorite-button-1')).toHaveAttribute(
      'aria-pressed', 'true'
    );
  });

  test('should handle double-click to zoom', async ({ page }) => {
    await page.getByTestId('product-image').dblclick();
    await expect(page.getByTestId('zoom-indicator')).toBeVisible();
  });
});
```

**Edge cases to test:**
- Rapid successive taps (debounce protection)
- Tap during animation (should queue or ignore)
- Tap on overlapping elements (correct element receives tap)
- Tap near the edge of a touch target (hit slop verification)

**Output:** Tap/click test suite for all platforms.

### Step 3: Write Swipe/Scroll Tests

Create tests for swipe and scroll interactions.

**Detox (React Native):**
```typescript
describe('Swipe Interactions', () => {
  it('should swipe left to delete item', async () => {
    await element(by.id('list-item-1')).swipe('left', 'fast', 0.75);
    await expect(element(by.id('delete-action'))).toBeVisible();
    await element(by.id('delete-action')).tap();
    await expect(element(by.id('list-item-1'))).not.toBeVisible();
  });

  it('should swipe right to archive item', async () => {
    await element(by.id('list-item-2')).swipe('right', 'fast', 0.75);
    await expect(element(by.id('archive-action'))).toBeVisible();
  });

  it('should pull to refresh', async () => {
    await element(by.id('scroll-view')).swipe('down', 'slow', 0.5, 0.5, 0.1);
    await expect(element(by.id('refresh-indicator'))).toBeVisible();
    await waitFor(element(by.id('refresh-indicator'))).not.toBeVisible()
      .withTimeout(5000);
  });

  it('should scroll to load more items', async () => {
    await element(by.id('item-list')).scrollTo('bottom');
    await expect(element(by.id('loading-more'))).toBeVisible();
    await waitFor(element(by.id('item-20'))).toBeVisible().withTimeout(5000);
  });

  it('should navigate carousel with horizontal swipe', async () => {
    await expect(element(by.id('slide-1'))).toBeVisible();
    await element(by.id('carousel')).swipe('left', 'fast');
    await expect(element(by.id('slide-2'))).toBeVisible();
  });
});
```

**Playwright (Web):**
```typescript
test.describe('Swipe/Scroll Interactions', () => {
  test('should scroll to load more items', async ({ page }) => {
    await page.getByTestId('item-list').evaluate((el) => {
      el.scrollTo(0, el.scrollHeight);
    });
    await expect(page.getByTestId('loading-more')).toBeVisible();
  });

  test('should navigate carousel with swipe', async ({ page }) => {
    const carousel = page.getByTestId('carousel');
    const box = await carousel.boundingBox();
    await page.mouse.move(box!.x + box!.width / 2, box!.y + box!.height / 2);
    await page.mouse.down();
    await page.mouse.move(box!.x + 50, box!.y + box!.height / 2, { steps: 10 });
    await page.mouse.up();
    await expect(page.getByTestId('slide-2')).toBeVisible();
  });
});
```

**Edge cases:**
- Slow swipe (should not trigger action — distance threshold not met)
- Partial swipe and cancel (snap back to original position)
- Swipe during scroll (gesture disambiguation)
- Momentum scrolling overshooting content

**Output:** Swipe/scroll test suite for all platforms.

### Step 4: Write Pinch/Zoom Tests

Create tests for pinch-to-zoom and multi-touch interactions.

**Detox (React Native):**
```typescript
describe('Pinch/Zoom Interactions', () => {
  it('should pinch to zoom image', async () => {
    await element(by.id('zoomable-image')).pinch(1.5); // Zoom in 1.5x
    await expect(element(by.id('zoom-level'))).toHaveText('150%');
  });

  it('should pinch to zoom out', async () => {
    // First zoom in
    await element(by.id('zoomable-image')).pinch(2.0);
    // Then zoom out
    await element(by.id('zoomable-image')).pinch(0.5);
    await expect(element(by.id('zoom-level'))).toHaveText('100%');
  });

  it('should respect minimum zoom level', async () => {
    await element(by.id('zoomable-image')).pinch(0.1); // Try to zoom below minimum
    await expect(element(by.id('zoom-level'))).toHaveText('100%'); // Clamped
  });

  it('should respect maximum zoom level', async () => {
    await element(by.id('zoomable-image')).pinch(10.0); // Try to zoom beyond max
    await expect(element(by.id('zoom-level'))).toHaveText('400%'); // Clamped at max
  });
});
```

**Web pinch simulation (limited):**
```typescript
test.describe('Zoom Interactions (Web)', () => {
  test('should zoom with scroll wheel', async ({ page }) => {
    const image = page.getByTestId('zoomable-image');
    await image.hover();
    // Ctrl+scroll simulates pinch on trackpad
    await page.keyboard.down('Control');
    await page.mouse.wheel(0, -100); // Scroll up = zoom in
    await page.keyboard.up('Control');
    await expect(page.getByTestId('zoom-level')).toHaveText('150%');
  });

  test('should zoom with buttons as fallback', async ({ page }) => {
    await page.getByTestId('zoom-in-button').click();
    await expect(page.getByTestId('zoom-level')).toHaveText('150%');
  });
});
```

**Note:** True multi-touch pinch is difficult to simulate in automated tests. Use real device testing (Step 6) for accurate pinch gesture validation.

**Output:** Pinch/zoom test suite.

### Step 5: Write Long-Press Tests

Create tests for long-press and context menu interactions.

**Detox (React Native):**
```typescript
describe('Long Press Interactions', () => {
  it('should show context menu on long press', async () => {
    await element(by.id('list-item-1')).longPress();
    await expect(element(by.id('context-menu'))).toBeVisible();
    await expect(element(by.id('menu-edit'))).toBeVisible();
    await expect(element(by.id('menu-delete'))).toBeVisible();
    await expect(element(by.id('menu-share'))).toBeVisible();
  });

  it('should enable drag mode on long press', async () => {
    await element(by.id('draggable-item')).longPress();
    await expect(element(by.id('drag-indicator'))).toBeVisible();
    // Item should be in draggable state
    await expect(element(by.id('draggable-item'))).toHaveValue('dragging');
  });

  it('should dismiss context menu on tap outside', async () => {
    await element(by.id('list-item-1')).longPress();
    await expect(element(by.id('context-menu'))).toBeVisible();
    await element(by.id('background-overlay')).tap();
    await expect(element(by.id('context-menu'))).not.toBeVisible();
  });

  it('should select item on long press in selection mode', async () => {
    await element(by.id('list-item-1')).longPress();
    await expect(element(by.id('selection-toolbar'))).toBeVisible();
    await expect(element(by.id('selection-count'))).toHaveText('1 selected');
  });

  it('should provide haptic feedback on long press activation', async () => {
    // Note: Haptic feedback cannot be directly tested in E2E
    // Verify the visual feedback instead
    await element(by.id('list-item-1')).longPress(800); // Hold for 800ms
    await expect(element(by.id('list-item-1-highlight'))).toBeVisible();
  });
});
```

**Playwright (Web):**
```typescript
test.describe('Long Press / Right-Click (Web)', () => {
  test('should show context menu on right-click', async ({ page }) => {
    await page.getByTestId('list-item-1').click({ button: 'right' });
    await expect(page.getByTestId('context-menu')).toBeVisible();
  });

  // Touch device simulation
  test('should show context menu on long press (touch)', async ({ page }) => {
    const item = page.getByTestId('list-item-1');
    const box = await item.boundingBox();
    await page.touchscreen.tap(box!.x + box!.width / 2, box!.y + box!.height / 2);
    // Hold — simulate with custom delay
    await page.mouse.down();
    await page.waitForTimeout(800);
    await page.mouse.up();
    await expect(page.getByTestId('context-menu')).toBeVisible();
  });
});
```

**Edge cases:**
- Long press while scrolling (should not trigger — movement cancels long press)
- Long press with slight finger movement (should still trigger within tolerance)
- Long press timeout (ensure the correct duration triggers the action)
- Multiple items long-pressed in sequence (multi-select mode)

**Output:** Long-press test suite for all platforms.

### Step 6: Test on Real Devices

Execute the complete gesture test suite on real physical devices.

**Why real devices?**
- Simulators/emulators do not perfectly replicate touch physics
- Real device touch latency differs from simulators
- Haptic feedback can only be verified on real devices
- Edge gestures (swipe from screen edge) behave differently
- Thermal throttling affects gesture responsiveness on real devices

**Real device testing protocol:**
1. Run the full automated test suite on real devices (via USB or device farm)
2. Manually test gestures that are difficult to automate:
   - Multi-finger pinch with precise scale values
   - Rapid gesture switching (pinch → pan → tap)
   - Edge swipes near system gesture areas
   - Gesture behavior during keyboard presence
3. Test on devices representing each tier:
   - Flagship: Verify gestures feel responsive and premium
   - Mid-range: Verify gestures work correctly without jank
   - Budget: Verify gestures complete successfully (may be slower)

**Results format:**
| Test | Simulator | iPhone 15 Pro | Pixel 6a | Galaxy A14 |
|------|-----------|--------------|----------|-----------|
| Tap to open | PASS | PASS | PASS | PASS |
| Swipe to delete | PASS | PASS | PASS | PASS (slow) |
| Pinch to zoom | N/A | PASS | PASS | FAIL (jank) |
| Long press menu | PASS | PASS | PASS | PASS |
| Pull to refresh | PASS | PASS | PASS | PASS |

**Document device-specific issues:**
For any failures on real devices but not simulators, document the difference and the root cause.

**Output:** Real device test results across all tiers.

---

## Quality Criteria

- Every gesture in the inventory must have at least one automated test
- Swipe tests must verify both completion and cancellation behavior
- Pinch tests must be verified on real devices (not just simulators)
- Long-press tests must verify the correct timing threshold
- Tests must run on at least one flagship and one budget device
- Edge cases (rapid gestures, gesture disambiguation) must be covered

---

*Squad Apex — Gesture Interaction Test Suite Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-gesture-test-suite
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Every gesture in the inventory must have at least one automated test"
    - "Swipe tests must verify both completion and cancellation behavior"
    - "Pinch tests must be verified on real devices, not just simulators"
    - "Tests must run on at least one flagship and one budget device"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Gesture interaction inventory, tap/click test suite, swipe/scroll test suite, pinch/zoom test suite, long-press test suite, and real device test results |
| Next action | Integrate test suites into CI via `cross-platform-test-setup` and route gesture failures to `@mobile-eng` for fixes |
