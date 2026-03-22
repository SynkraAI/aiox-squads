# Task: apex-route-request

```yaml
id: apex-route-request
version: "1.0.0"
title: "Apex Route Request"
description: >
  Intelligently routes an incoming request to the correct specialist agent
  based on the request type, domain, and complexity. The orchestrator
  (apex-lead) executes this task when a request does not clearly map to
  a specific flow (*design, *build, *ship) or when the user is unsure
  which specialist they need.
elicit: false
owner: apex-lead
executor: apex-lead
outputs:
  - Routing decision with target agent(s)
  - Briefing for the target agent
  - Estimated scope (single-agent | multi-agent | full-pipeline)
```

---

## When This Task Runs

This task runs when:
- The user types a request that does not start with a flow command (`*design`, `*build`, `*ship`)
- The user explicitly asks `*route {request}`
- The request is ambiguous and could apply to multiple specialists
- The user asks "who should I talk to about X?"

This task does NOT run when:
- A specific flow is already selected (`*design`, `*build`, `*ship`, `*component`)
- A specific agent is already active and the request is within their domain
- The request is a squad management command (`*status`, `*gates`, `*agents`)

---

## Routing Logic

The orchestrator analyzes the incoming request against the following routing table.
When multiple domains match, the orchestrator coordinates rather than routing to
a single agent.

### Primary Routing Table

| Request Type | Keywords / Signals | Target Agent | Tier |
|---|---|---|---|
| Architecture decision | "architecture", "monorepo", "RSC", "server component", "tech stack", "package structure", "bundle", "edge", "turbopack" | `@frontend-arch` | T1 |
| Design / UX pattern | "design", "interaction pattern", "user flow", "states", "how should it look", "UX" | `@interaction-dsgn` | T2 |
| Design system / tokens | "token", "design system", "component library", "Figma sync", "dark mode", "theming", "color variable" | `@design-sys-eng` | T2 |
| CSS layout / styling | "CSS", "layout", "flexbox", "grid", "spacing", "stacking context", "z-index", "overflow", "typography", "responsive" | `@css-eng` | T3 |
| React / Next.js | "React", "component", "hook", "state", "server action", "data fetching", "RSC", "Next.js", "Suspense" | `@react-eng` | T3 |
| React Native / mobile | "React Native", "mobile", "iOS", "Android", "Expo", "native", "haptic", "gesture", "worklet" | `@mobile-eng` | T3 |
| Cross-platform parity | "web and native", "universal component", "Solito", "shared package", "cross-platform", "platform parity" | `@cross-plat-eng` | T3 |
| 3D / spatial / XR | "3D", "Three.js", "R3F", "WebXR", "VisionOS", "spatial", "shader", "scene", "immersive" | `@spatial-eng` | T3 |
| Animation / motion | "animation", "transition", "spring", "motion", "Framer Motion", "Reanimated", "gesture", "scroll animation", "choreography" | `@motion-eng` | T4 |
| Accessibility | "accessibility", "a11y", "WCAG", "screen reader", "keyboard navigation", "focus", "ARIA", "contrast", "VoiceOver" | `@a11y-eng` | T4 |
| Performance | "performance", "slow", "LCP", "INP", "CLS", "bundle size", "Core Web Vitals", "loading time", "lighthouse", "profiling" | `@perf-eng` | T4 |
| Visual QA | "visual regression", "pixel comparison", "screenshot test", "Chromatic", "design fidelity", "looks wrong visually" | `@qa-visual` | T5 |
| Device / platform QA | "device test", "cross-browser", "iPhone", "Pixel", "real device", "Detox", "E2E mobile" | `@qa-xplatform` | T5 |
| Visual Analysis | "analisa esse print", "screenshot", "olha esse app", "quero assim", "faz igual", image attached, "compara", "referencia", "inspiracao" | `@apex-lead` (orchestrates multi-agent analysis) | T0 |
| Visual Compare | "compara com", "lado a lado", "antes e depois", 2 images attached | `@apex-lead` (orchestrates comparison) | T0 |
| Consistency Audit | 3+ images attached, "consistencia", "todas as paginas", "cross-page" | `@apex-lead` (orchestrates consistency) | T0 |

### Complexity Routing Rules

```yaml
routing_rules:
  single_agent:
    condition: "Request clearly maps to one domain, no cross-tier dependencies"
    action: "Route directly to target agent with full context"
    example: "Fix the CSS flexbox layout issue in the header"

  multi_agent_sequential:
    condition: "Request spans 2-3 tiers but has clear handoff order"
    action: "Route to first agent, define handoff points"
    example: "Add animation to the existing button component"
    sequence: "@motion-eng → @a11y-eng (check reduced-motion) → @perf-eng (60fps check)"

  scope_threshold:
    condition: "Request touches 3+ files across different agent domains, OR creates a new user-facing component, OR modifies shared packages"
    action: "MUST use full pipeline (apex-design-flow → apex-build-flow → apex-ship-flow)"
    example: "Add a notification badge to the header across web and mobile"
    detection:
      - "New component mentioned → full_pipeline"
      - "Cross-platform mentioned → full_pipeline"
      - "Shared package change → full_pipeline"
      - "Single file CSS fix → single_agent"
      - "Bug in one component → single_agent or multi_agent"
    override: "apex-lead can override this threshold with written justification"

  full_pipeline:
    condition: "New feature or component from scratch"
    action: "Start with apex-design-flow, follow full SDC"
    example: "Build a notification system"
    trigger_flow: "apex-design-flow → apex-build-flow → apex-ship-flow"

  orchestrator_coordinates:
    condition: "Request spans 4+ tiers or involves cross-platform architecture"
    action: "apex-lead orchestrates, calls agents sequentially"
    example: "Redesign the checkout flow across web and mobile"
```

---

## Routing Decision Output

When the orchestrator makes a routing decision, it outputs in this format:

```
Routing Analysis

Request: "{user's request}"

Domain(s) detected: {comma-separated domains}
Scope: {single-agent | multi-agent | full-pipeline}

Routing to: @{agent-id}
Reason: {one sentence explaining why this agent}

{If multi-agent:}
Sequence:
1. @{agent-1} — {what they will do}
2. @{agent-2} — {what they will do}
3. @{agent-3} — {what they will do}

Activating @{first-agent} now...
```

### Example Routing Outputs

**Example 1 — Single agent, clear domain:**
```
Routing Analysis

Request: "The modal animation feels mechanical and slow"

Domain: Animation / Motion
Scope: single-agent

Routing to: @motion-eng
Reason: Animation quality issues are Matt's domain — he will audit the spring
        configs and replace any bezier-based transitions with physics-based springs.

Activating @motion-eng now...
```

**Example 2 — Multi-agent, sequential:**
```
Routing Analysis

Request: "Make the dashboard accessible for keyboard users"

Domain: Accessibility (primary), React/behavior (secondary)
Scope: multi-agent

Sequence:
1. @a11y-eng — Audit current keyboard navigation, identify all gaps
2. @react-eng — Implement focus management fixes and ARIA patterns
3. @a11y-eng — Re-audit after fixes

Activating @a11y-eng now...
```

**Example 3 — Full pipeline:**
```
Routing Analysis

Request: "We need a new search component with autocomplete"

Domain: New feature — all tiers required
Scope: full-pipeline

This is a new component build. Routing through the full Apex pipeline:

Design Flow  → @interaction-dsgn defines interaction pattern and states
             → @design-sys-eng maps tokens and component API
             → @apex-lead design review

Build Flow   → @frontend-arch defines RSC architecture
             → @react-eng + @css-eng implement web
             → @mobile-eng implements native
             → @motion-eng adds search suggestions animation
             → @a11y-eng audits (autocomplete is a complex ARIA pattern)
             → @perf-eng validates (autocomplete can impact INP)

Ship Flow    → @qa-visual visual regression
             → @qa-xplatform device tests
             → @apex-lead final review

Starting with: *design "search component with autocomplete"
```

---

## Ambiguity Resolution

When the request is genuinely ambiguous and routing is unclear:

```
I need a bit more context to route this correctly.

Your request: "{request}"

This could be:
1. {Option A} — would route to @{agent-A}
2. {Option B} — would route to @{agent-B}
3. {Option C} — would start the full design → build → ship pipeline

Which fits best? (type 1, 2, or 3)
```

Do not ask for clarification if one routing is clearly more likely. Only ask when
two or more options are equally plausible.

---

## Default Fallback Route

When the request does not match ANY domain in the routing table:

```yaml
default_route:
  condition: "No domain match found in routing table"
  action: "Route to apex-lead for manual triage"
  message: |
    This request doesn't match a specific specialist domain.

    Request: "{request}"

    Routing to: @apex-lead (orchestrator)
    Reason: No specialist domain detected. apex-lead will analyze
            the request and either handle it directly or assign to
            the appropriate specialist.

    Activating @apex-lead now...
  never_silently_ignore: true
  log: "All unmatched requests logged for routing table improvement"
```

**Rule:** A request must NEVER be silently dropped. If no domain matches,
apex-lead ALWAYS receives it. This is a physical block against lost requests.

### apex-lead Cannot Route — Final Escalation

When apex-lead receives a request via the default fallback and STILL cannot determine
the correct specialist:

```yaml
apex_lead_escalation:
  condition: "apex-lead cannot determine correct agent after analyzing request"
  action: "Escalate to @aios-master for framework-level triage"
  message: |
    Request cannot be routed within Squad Apex.

    Request: "{request}"
    Attempted analysis: {apex-lead's analysis}
    Reason for escalation: {why no agent fits}

    Escalating to @aios-master for cross-squad routing or new capability assessment.
  log: "Unroutable requests logged for squad capability gap analysis"
```

---

## Domain Conflict Resolution

When two agents have overlapping domains on the same request:

| Conflict | Resolution |
|----------|------------|
| CSS layout vs React component structure | @css-eng for pure styling, @react-eng if behavior is also involved |
| Motion (Framer Motion) vs React state | @motion-eng leads, @react-eng supports for state-driven animation triggers |
| Accessibility vs React implementation | @a11y-eng defines what is needed, @react-eng implements it |
| Performance vs Architecture | @perf-eng measures, @frontend-arch decides structural changes |
| Mobile vs Cross-platform | @mobile-eng for platform-specific native work, @cross-plat-eng for shared code |
| Visual QA vs Final Review | @qa-visual runs automated regression, @apex-lead does subjective visual review |

### Generic Conflict Resolution Algorithm

When a conflict arises between two agents NOT listed in the table above, apply this resolution algorithm:

**Rule 1 — Tier Priority:** The higher-tier agent (lower number) LEADS the request.
- Tier 0 (apex-lead) > Tier 1 (frontend-arch) > Tier 2 (interaction-dsgn, design-sys-eng) > Tier 3 > Tier 4 > Tier 5
- Example: spatial-eng (T3) vs motion-eng (T4) → spatial-eng leads, motion-eng supports

**Rule 2 — Same Tier, Domain Specificity:** The agent with the more SPECIFIC domain for the request leads.
- Example: css-eng (T3) vs cross-plat-eng (T3) on a CSS variable question → css-eng leads (more specific)
- Example: react-eng (T3) vs mobile-eng (T3) on a React Native hook → mobile-eng leads (more specific to native)

**Rule 3 — Define vs Implement:** The agent that DEFINES requirements leads; the agent that IMPLEMENTS follows.
- Pattern: {definer} defines what is needed → {implementer} builds it
- Example: a11y-eng (T4) defines a11y requirements → react-eng (T3) implements ARIA patterns
- Example: perf-eng (T4) identifies bottleneck → css-eng (T3) optimizes CSS

**Rule 4 — Audit vs Build:** Audit/QA agents (T4-T5) NEVER lead implementation. They define requirements that T1-T3 agents implement.
- Exception: Within their own domain (e.g., motion-eng implementing spring configs)

**Rule 5 — Unresolvable Conflict:** If rules 1-4 don't clearly resolve, apex-lead orchestrates directly.
- apex-lead calls both agents sequentially, integrates their outputs
- This is logged for routing table improvement

---

## Routing Boundaries

Requests that must NOT be routed to Squad Apex agents:

| Request Type | Correct Delegate |
|---|---|
| Git push, force push | `@devops` (Gage) — EXCLUSIVE |
| PR creation, PR merge | `@devops` (Gage) — EXCLUSIVE |
| CI/CD pipeline changes | `@devops` (Gage) — EXCLUSIVE |
| Backend API implementation | `@dev` (Dex) — AIOS core agent |
| Database schema changes | `@data-engineer` (Dara) — AIOS core agent |
| Product requirements | `@pm` (Morgan) — AIOS core agent |
| Story creation | `@sm` (River) — AIOS core agent |
| Epic management | `@pm` (Morgan) — AIOS core agent |

When a request belongs outside Squad Apex, the orchestrator redirects:

```
This request is outside Squad Apex's domain.

Request: "{request}"
Correct agent: @{agent-id} ({name})
Reason: {one sentence}

Redirecting you to @{agent-id}...
```

---

## Tier Escalation

When a Tier 3-5 specialist encounters something outside their authority:

```yaml
escalation_triggers:
  - trigger: "Architectural decision needed (monorepo, RSC boundaries, tech stack)"
    escalate_to: "@frontend-arch"

  - trigger: "New design tokens need to be created"
    escalate_to: "@design-sys-eng"

  - trigger: "Cross-platform parity decision needed"
    escalate_to: "@cross-plat-eng"

  - trigger: "Git push or PR creation needed"
    escalate_to: "@devops"

  - trigger: "Quality gate cannot be decided by specialist alone"
    escalate_to: "@apex-lead"

  - trigger: "Constitutional violation or framework governance issue"
    escalate_to: "@aios-master"
```

---

*Apex Squad — Route Request Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-apex-route-request
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Routing decision must identify at least one target agent"
    - "Briefing for target agent must contain enough context to begin work without re-asking the user"
    - "Estimated scope must be classified as single-agent, multi-agent, or full-pipeline"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Target specialist agent identified in routing decision |
| Artifact | Routing decision with agent briefing and scope estimate |
| Next action | Target agent begins execution of the appropriate task or flow |
