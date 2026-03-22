# React Native Performance Checklist — Apex Squad

> Reviewer: mobile-eng
> Purpose: Ensure React Native components and screens meet performance budgets on mobile devices.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Rendering

- [ ] `FlatList` or `FlashList` used for lists longer than 20 items
- [ ] `React.memo` applied to expensive list item components
- [ ] `InteractionManager.runAfterInteractions` used for heavy work after navigation
- [ ] `getItemLayout` provided for lists with fixed-height items
- [ ] `keyExtractor` returns stable unique keys
- [ ] No inline style objects in render (moved to `StyleSheet.create`)
- [ ] `removeClippedSubviews` enabled for off-screen optimization where appropriate

---

## 2. Animation

- [ ] Reanimated 3 worklets used for gesture-driven animations (not Animated API)
- [ ] No JS thread animations — all animations run on UI thread
- [ ] 60fps verified on target devices (profiled with Flipper or React DevTools)
- [ ] `useAnimatedStyle` used instead of inline animated values
- [ ] Shared values (`useSharedValue`) used instead of `useState` for animation state
- [ ] Gesture handlers use `react-native-gesture-handler` (not `PanResponder`)
- [ ] Layout animations use `LayoutAnimation` or Reanimated layout transitions

---

## 3. Memory

- [ ] No memory leaks in effects — cleanup functions properly implemented
- [ ] Event listeners and subscriptions cleaned up on unmount
- [ ] Images optimized for mobile (compressed, correct resolution, not oversized)
- [ ] Large lists virtualized — not rendering all items in memory
- [ ] Cached data has eviction strategy (not unbounded growth)
- [ ] No circular references in state or closures
- [ ] Memory profiled on low-end device — no OOM crashes

---

## 4. Startup

- [ ] Cold start time < 1 second on mid-range devices
- [ ] Lazy loading used for secondary/non-critical screens
- [ ] Minimal synchronous work on mount (heavy work deferred)
- [ ] Splash screen covers initialization period smoothly
- [ ] Bundle size monitored — no unnecessary dependencies
- [ ] Hermes engine enabled and optimized bytecode generated
- [ ] No synchronous storage reads on startup (use async with fallback)

---

## 5. Platform

- [ ] Tested on iOS (iPhone, iPad if applicable)
- [ ] Tested on Android (multiple screen densities)
- [ ] Platform-specific optimizations applied where needed (`Platform.select`)
- [ ] Native modules have both iOS and Android implementations
- [ ] Shadow rendering uses platform-appropriate API (elevation on Android, shadow props on iOS)
- [ ] Status bar and safe area handled correctly on both platforms
- [ ] Keyboard handling works on both platforms (KeyboardAvoidingView configured)

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Devices Tested | |
| Result | APPROVED / BLOCKED |
| Notes | |
