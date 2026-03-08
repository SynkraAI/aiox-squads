# Cross-Platform QA Checklist — Apex Squad

> Reviewer: qa-xplatform
> Purpose: Validate functionality and appearance across all target browsers, devices, and platforms.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Web Browsers

- [ ] Chrome 120+ tested — rendering and functionality correct
- [ ] Safari 17+ tested — rendering and functionality correct
- [ ] Firefox 121+ tested — rendering and functionality correct
- [ ] Edge (latest Chromium) tested — rendering and functionality correct
- [ ] No browser-specific CSS hacks — features degrade gracefully
- [ ] JavaScript APIs used are supported across all target browsers (checked on caniuse.com)
- [ ] Form behavior consistent across browsers (validation, autocomplete, date pickers)

---

## 2. Mobile

- [ ] iOS 16+ tested on physical device or high-fidelity simulator
- [ ] Android 13+ tested on physical device or emulator
- [ ] Portrait orientation tested and functional
- [ ] Landscape orientation tested and functional
- [ ] System font size scaling respected (Dynamic Type on iOS, font scale on Android)
- [ ] Safe area insets handled correctly (notch, home indicator, status bar)
- [ ] Keyboard interaction does not obscure input fields

---

## 3. Interactions

- [ ] Touch targets minimum 44x44px on mobile
- [ ] Gestures work on mobile (swipe, pinch, long press where applicable)
- [ ] Hover states functional on desktop (no hover-dependent functionality on mobile)
- [ ] Keyboard navigation works on web (Tab, Enter, Escape, Arrow keys)
- [ ] Right-click/long-press context menus do not interfere with custom interactions
- [ ] Scroll behavior smooth and consistent across platforms
- [ ] Form submission works via Enter key on desktop and Go/Done on mobile

---

## 4. Performance

- [ ] 60fps maintained during animations on all target platforms
- [ ] Startup time acceptable on mobile (< 2s to interactive)
- [ ] No memory leaks detected during extended use session
- [ ] App does not crash on low-memory devices
- [ ] Network transitions (WiFi to cellular) handled gracefully
- [ ] Large data sets do not freeze the UI (virtualization, pagination)

---

## 5. Platform-Specific Edge Cases

- [ ] iOS rubber-band scrolling does not break fixed elements
- [ ] Android back button behavior correct (navigation, modal dismiss)
- [ ] iOS swipe-back gesture does not conflict with app gestures
- [ ] Clipboard operations (copy/paste) work on all platforms
- [ ] File upload works on all platforms (camera, file picker)
- [ ] Deep links resolve correctly on mobile

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Browsers Tested | |
| Devices Tested | |
| Result | APPROVED / BLOCKED |
| Notes | |
