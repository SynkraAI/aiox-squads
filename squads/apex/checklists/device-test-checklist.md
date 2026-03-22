# Device Testing Checklist — Apex Squad

> Reviewer: qa-xplatform
> Purpose: Validate functionality and rendering on specific device categories across the hardware spectrum.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Flagship Devices

- [ ] iPhone 15 Pro (iOS 17+) — rendering correct, performance smooth
- [ ] Samsung Galaxy S24 (Android 14+) — rendering correct, performance smooth
- [ ] Google Pixel 8 Pro (Android 14+) — rendering correct, performance smooth
- [ ] ProMotion/120Hz display — animations run at high refresh rate
- [ ] Dynamic Island / notch area handled correctly on iPhone
- [ ] Edge-to-edge display rendering correct on all flagship devices

---

## 2. Mid-Range Devices

- [ ] iPhone SE (3rd gen, iOS 16+) — layout fits small 4.7" screen
- [ ] Samsung Galaxy A54 (Android 13+) — performance acceptable, no jank
- [ ] Google Pixel 7a (Android 13+) — performance acceptable, no jank
- [ ] Reduced RAM devices — app does not crash under memory pressure
- [ ] Slower processors — animations degrade gracefully, no freezes
- [ ] Lower display density — content remains sharp and readable

---

## 3. Tablets

- [ ] iPad Air (10.9") — layout adapts to tablet width
- [ ] Samsung Galaxy Tab S9 (11") — layout adapts to tablet width
- [ ] Split-screen / multitasking mode — layout adapts to reduced width
- [ ] Keyboard attachment mode — input handling works correctly
- [ ] Stylus/Apple Pencil input does not break interactions
- [ ] Portrait and landscape orientations both functional

---

## 4. Desktop Displays

- [ ] 1080p (1920x1080) — standard desktop layout correct
- [ ] 1440p (2560x1440) — content scales appropriately
- [ ] 4K (3840x2160) — no blurry images, text crisp, layout not broken
- [ ] Ultrawide (3440x1440 / 21:9) — content centered, no excessive stretching
- [ ] Multi-monitor — window dragging between displays works correctly
- [ ] HiDPI / Retina — assets served at appropriate resolution

---

## 5. Special Conditions

- [ ] Low-end Android device (2GB RAM, older SoC) — app loads and is usable
- [ ] Older iOS device (iPhone 11 / iOS 16) — app loads and is usable
- [ ] Slow network (simulated 3G / 300kbps) — content loads progressively
- [ ] Offline mode — appropriate offline state shown, no crashes
- [ ] Battery saver mode — no excessive CPU/GPU usage
- [ ] Accessibility zoom enabled — layout adapts, no overflow

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Devices Tested | |
| Network Conditions | |
| Result | APPROVED / BLOCKED |
| Notes | |
