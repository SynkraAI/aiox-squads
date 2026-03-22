# Apex Squad — Tech Stack Reference

> Version: 1.0
> Maintained by: apex-lead
> Scope: Authoritative list of approved technologies, versions, and usage rules.

---

## 1. Runtime and Framework

### Next.js 15+
- **Router:** App Router (Pages Router is legacy — no new code)
- **Rendering:** RSC by default; Client Components only when required
- **Edge Runtime:** Used for latency-sensitive API routes and middleware
- **Build:** Turbopack in development; Webpack in production (until Turbopack stable)
- **Config:** `next.config.ts` (TypeScript config, not JS)
- **Key features in use:** Partial Prerendering (PPR), Server Actions, streaming, parallel routes

### React 19+
- **Compiler:** React Compiler enabled (no manual `useMemo`/`useCallback` for performance)
- **Patterns:** `use()` hook for async data in RSC; `useOptimistic` for optimistic UI; `useActionState` for form state
- **Server Components:** Default for all page-level and data-fetching components
- **Client Components:** Marked with `'use client'` — justified by interactivity or browser API usage only
- **Strict Mode:** Enabled in development

### TypeScript 5.x — Strict Mode
- **Config:** `tsconfig.json` extends base with `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true`
- **No `any`:** Lint rule enforced (`@typescript-eslint/no-explicit-any: error`)
- **Path aliases:** `@/*` maps to `src/*`; `@packages/*` maps to `packages/*/src`
- **Declaration files:** Generated for all shared packages

### Edge Runtime
- Used for: middleware, auth checks, geolocation, A/B routing
- Constraints: No Node.js APIs — Web APIs only (`fetch`, `Request`, `Response`, `crypto`)
- File indicator: `export const runtime = 'edge'` at top of route

### Turbopack (Development)
- Replaces Webpack in `next dev`
- Faster HMR — do not add Webpack-specific plugins without checking Turbopack compat
- Production build still uses Webpack until Turbopack production is declared stable

---

## 2. Styling

### Tailwind CSS 4
- **Config:** `tailwind.config.ts` — extends design token values
- **No arbitrary values:** `w-[347px]` is a defect. Use token-aligned classes or add a token.
- **Dark mode:** `class` strategy — `.dark` class on `<html>`
- **Responsive:** Mobile-first (`sm:`, `md:`, `lg:`, `xl:`, `2xl:`)
- **Custom plugins:** None — extend via `theme.extend` only
- **Purge:** Automatic in build — no unused CSS ships

### Radix UI / Ark UI
- **Radix UI:** Unstyled, accessible primitives — used for Dialog, Dropdown, Tooltip, Select, Slider, etc.
- **Ark UI:** State-machine-driven primitives — used for Date Picker, Combobox, Carousel, and complex composite widgets
- **Rule:** Never build from scratch what Radix/Ark provides. Compose, do not reinvent.
- **Styling:** Tailwind classes applied to Radix/Ark slot components via `asChild` or className props

### CVA (Class Variance Authority)
- Used for all component variant definitions
- `cva()` defines the base class and all variant combinations
- `VariantProps<typeof componentVariants>` types the component props
- Compound variants handle multi-prop visual logic

### Design Tokens
- Source: `packages/design-tokens/src/tokens/`
- Build: Style Dictionary generates CSS custom properties, JS, and React Native values
- CSS variables: `:root` scope for light mode; `.dark` scope for dark mode
- JS consumption: `import { tokens } from '@packages/design-tokens'`
- Mobile consumption: `import { theme } from '@packages/design-tokens/native'`

### Style Dictionary
- Transform pipeline: JSON token source → platform-specific outputs
- Platforms: `css`, `js`, `react-native`, `figma` (via Tokens Studio plugin)
- Custom transforms registered for squircle radius and spring token formats

---

## 3. Motion and 3D

### Framer Motion
- **Version:** Latest stable (v11+)
- **Usage:** Page transitions, component enter/exit, layout animations, drag
- **API preference:** `motion.*` components over `animate()` imperative API where declarative is possible
- **AnimatePresence:** Always wraps conditionally rendered animated elements
- **Layout animations:** `layout` prop for smooth element repositioning
- **Reduced motion:** `useReducedMotion()` hook — conditionally disable or substitute animations
- **Variants:** Defined in `motion.variants.ts` files alongside components

### GSAP (GreenSock)
- **Usage:** Complex scroll-driven animations, SVG path animations, timeline-based choreography
- **Plugins in use:** ScrollTrigger, DrawSVG, MorphSVG
- **Registration:** Plugins registered once at app root
- **Cleanup:** All GSAP contexts killed in `useEffect` cleanup
- **Rule:** Do not use GSAP for simple enter/exit — use Framer Motion. GSAP for scroll and complex sequences only.

### Rive
- **Usage:** Interactive animations with state machines (onboarding, character animation, complex loaders)
- **Runtime:** `@rive-app/react-canvas` (canvas-based, GPU accelerated)
- **Assets:** `.riv` files in `public/rive/` — loaded lazily
- **State machines:** Controlled via Rive's `useRive` and `useStateMachineInput` hooks

### Three.js + React Three Fiber (R3F)
- **Three.js:** Core 3D rendering engine
- **R3F:** React renderer for Three.js — use R3F, not direct Three.js DOM manipulation
- **Drei:** `@react-three/drei` helpers — use `<Environment>`, `<OrbitControls>`, `<Text>`, etc.
- **Postprocessing:** `@react-three/postprocessing` for visual effects
- **Performance:** `<Canvas>` uses `frameloop="demand"` by default — only render when state changes
- **Rule:** 3D canvases are lazy-loaded — never block page render on 3D initialization

### WebGPU
- **Status:** Progressive enhancement — WebGPU used when available, fallback to WebGL 2
- **Detection:** `navigator.gpu` check before initializing WebGPU path
- **Usage scope:** High-fidelity 3D scenes and GPU compute tasks only

---

## 4. AI-Native UI

### Vercel AI SDK
- **Version:** Latest stable (`ai` package)
- **Streaming UI:** `useChat`, `useCompletion`, `streamUI` for streaming responses
- **Server Actions:** AI calls wrapped in Server Actions with streaming support
- **Tools:** `generateObject` with Zod schemas for structured AI output
- **Error handling:** All AI calls have timeout, retry, and fallback UI states

### Streaming UI Patterns
- Skeleton → streaming content → final state
- `<Suspense>` boundaries wrap AI-generated content
- Partial rendering shown progressively (character-by-character or chunk-by-chunk)
- Abort controller for cancellation support

---

## 5. Mobile

### React Native 0.80+ — New Architecture
- **Architecture:** New Architecture (JSI, Fabric, TurboModules) — legacy bridge is off
- **Navigation:** Expo Router (file-based routing, same pattern as Next.js App Router)
- **State:** Same state management as web where possible (Zustand, React Query)
- **Styling:** React Native StyleSheet + design token values from `@packages/design-tokens/native`
- **Rule:** No third-party native modules without @architect approval and New Architecture compat check

### Expo 52+
- **Workflow:** Managed workflow with EAS Build for native builds
- **EAS:** EAS Build for CI/CD, EAS Submit for store submission, EAS Update for OTA
- **Modules:** Expo modules preferred over bare React Native APIs (`expo-camera`, `expo-haptics`, etc.)

### Reanimated 4
- **Usage:** All gesture-driven and performance-critical animations on mobile
- **Shared Values:** `useSharedValue` for animated state
- **Worklets:** Animation logic runs on UI thread (never JS thread)
- **Gestures:** `react-native-gesture-handler` (RNGH v2) — required companion
- **Rule:** Do not use `Animated` API from React Native core — Reanimated only

---

## 6. Quality Tools

### Vitest
- **Usage:** Unit and integration tests for components, hooks, and utilities
- **Config:** `vitest.config.ts` — JSDOM environment for component tests
- **Coverage:** V8 provider — minimum 80% coverage enforced in CI
- **Setup:** `src/test/setup.ts` — jest-dom matchers, MSW server setup
- **Convention:** `{ComponentName}.test.tsx` co-located with component

### Playwright
- **Usage:** End-to-end tests for critical user flows
- **Config:** `playwright.config.ts` — runs against local dev server
- **Browsers:** Chromium, Firefox, WebKit (all three run in CI)
- **Visual:** Playwright snapshots for full-page visual regression (supplementary to Chromatic)
- **Convention:** `tests/e2e/{flow-name}.spec.ts`

### Chromatic
- **Usage:** Component-level visual regression (Storybook-based)
- **CI:** Chromatic runs on every PR — blocks merge on unexpected visual changes
- **Baseline:** Baselines updated only by apex-lead
- **Viewports tested:** 375px (mobile), 768px (tablet), 1440px (desktop)
- **Modes:** Light and dark mode snapshots for every story

### Lighthouse CI
- **Usage:** Automated performance and accessibility scoring on every PR
- **Config:** `lighthouserc.js` — assertions defined for all Core Web Vitals budgets
- **Budgets:** LCP <= 2.5s, INP <= 200ms, CLS <= 0.1, Score >= 90 (mobile)
- **CI step:** Runs against Vercel preview URL after deployment

### axe-core
- **Usage:** Automated accessibility testing — zero violations required
- **Integration:** `@axe-core/playwright` in E2E tests; `@axe-core/react` in Storybook
- **Rule set:** WCAG 2.2 AA rules enabled
- **CI:** Runs as part of Playwright E2E suite — blocks merge on any violation

### Storybook 8
- **Usage:** Component development, documentation, and visual regression source
- **Addons in use:** `@storybook/addon-a11y`, `@storybook/addon-interactions`, `@storybook/addon-docs`, `@chromatic-com/storybook`
- **Autodocs:** Enabled — prop tables generated automatically from TypeScript interfaces
- **MSW addon:** API mocking in stories via `msw-storybook-addon`
- **Deploy:** Storybook deployed to Chromatic on every PR

---

## 7. Tooling and Infrastructure

### Biome
- **Usage:** Linting and formatting (replaces ESLint + Prettier)
- **Config:** `biome.json` at repo root
- **Rules:** Strict — no `any`, no unused variables, consistent import order
- **Format on save:** Enabled in VS Code workspace settings
- **CI:** `biome check --apply-unsafe` fails build on any violation

### Turborepo
- **Usage:** Monorepo task orchestration and build caching
- **Config:** `turbo.json` defines task pipeline and output caching
- **Remote cache:** Vercel Remote Cache enabled in CI
- **Tasks:** `build`, `test`, `lint`, `typecheck` — all parallelized across packages

### pnpm
- **Version:** pnpm 9+
- **Workspaces:** `pnpm-workspace.yaml` defines package locations
- **Rule:** `npm` and `yarn` are blocked — `pnpm` only
- **Lockfile:** `pnpm-lock.yaml` committed — never deleted or regenerated without cause

### GitHub Actions
- **CI pipeline:** `.github/workflows/ci.yml`
- **Steps:** Install → Typecheck → Lint → Test → Build → Lighthouse CI → Chromatic
- **PR checks:** All steps required to pass before merge
- **Cache:** pnpm store cached between runs via `actions/cache`
- **Secrets:** Managed in GitHub repository secrets — never in code

### Vercel Preview Deployments
- **Trigger:** Every PR gets an automatic preview deployment
- **URL pattern:** `https://{project}-{branch}-{org}.vercel.app`
- **Used for:** Lighthouse CI, manual QA, stakeholder review
- **Production:** Main branch auto-deploys to production after CI passes and @devops approves

---

## 8. Version Policy

| Tool | Minimum Version | Update Cadence |
|------|----------------|----------------|
| Next.js | 15.0 | Minor on release, major quarterly |
| React | 19.0 | Minor on release |
| TypeScript | 5.0 | Minor on release |
| Tailwind CSS | 4.0 | Minor on release |
| Framer Motion | 11.0 | Minor on release |
| React Native | 0.80 | Minor quarterly |
| Expo | 52 | SDK cycle (every ~6 months) |
| Storybook | 8.0 | Minor on release |
| Node.js | 20 LTS | LTS releases only |
| pnpm | 9.0 | Minor on release |

> **Dependency upgrades:** Proposed as a dedicated story. apex-lead + @architect approve major version bumps.
