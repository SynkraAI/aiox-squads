# Motion/Animation Review Checklist — Apex Squad

> Reviewer: motion-eng
> Purpose: Review animations for physics correctness, performance, accessibility, and choreography.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Physics

- [ ] Spring physics used instead of bezier/linear curves for natural motion
- [ ] Spring config (stiffness, damping, mass) matches the interaction intent
- [ ] Energy level appropriate — subtle interactions use low energy, emphasis uses high energy
- [ ] No overdamped springs where underdamped is expected (and vice versa)
- [ ] Duration-based animations justified (only for fixed-time transitions like progress bars)
- [ ] Velocity-aware springs continue motion from gesture release velocity

---

## 2. Reduced Motion

- [ ] `prefers-reduced-motion` fallback exists for every animation
- [ ] Essential motion preserved under reduced motion (functional feedback like success/error)
- [ ] Decorative motion fully removed under reduced motion
- [ ] Reduced motion alternative is not just `duration: 0` — uses instant opacity/state change
- [ ] Parallax, floating, and background animations disabled under reduced motion
- [ ] Implementation tested by toggling system accessibility preference

---

## 3. Performance

- [ ] 60fps maintained on target devices (profiled, not assumed)
- [ ] No layout thrashing — animated properties are `transform` and `opacity` only
- [ ] GPU composited where possible (elements promoted to compositor layer)
- [ ] `will-change` used sparingly and removed after animation completes
- [ ] No forced synchronous layouts during animation frames
- [ ] Animation cleanup on unmount — no orphaned requestAnimationFrame or timers
- [ ] Heavy animations tested on low-end devices

---

## 4. Choreography

- [ ] Stagger timing feels natural — not too fast, not too slow (20-40ms typical)
- [ ] Stagger direction follows reading order or visual hierarchy
- [ ] Exit animations are clean — elements leave without visual artifacts
- [ ] No orphaned animations (elements animating after they should have stopped)
- [ ] Enter and exit animations are complementary (exit reverses enter direction)
- [ ] Page transitions have coordinated element choreography
- [ ] Overlapping animations do not create visual chaos

---

## 5. Feedback

- [ ] Press/tap feedback responds in < 100ms
- [ ] State transitions are intentional and meaningful (not gratuitous)
- [ ] Loading states have appropriate animated indicators
- [ ] Success/error states have feedback animations
- [ ] Drag interactions provide continuous visual feedback
- [ ] Scroll-linked animations are smooth and directly mapped to scroll position
- [ ] Skeleton screens pulse or shimmer to indicate loading

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Target FPS | 60 |
| Devices Tested | |
| Result | APPROVED / BLOCKED |
| Notes | |
