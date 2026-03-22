# Task: apex-fix

```yaml
id: apex-fix
version: "1.0.0"
title: "Apex Quick Fix"
description: >
  Lightweight single-agent command for targeted fixes that don't need the full
  pipeline. Routes to the best specialist, executes directly, runs minimal
  quality checks, done. No design phase, no architecture docs, no polish cycle.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-route-request.md
  - data/veto-conditions.yaml
outputs:
  - Fixed code committed locally (not pushed)
  - Typecheck + lint passing
```

---

## Command

### `*apex-fix {description}`

Single-agent fix for targeted, scoped changes. Bypasses the full pipeline when the fix is clearly within one agent's domain.

---

## When to Use

- CSS bug fix (layout broken, spacing wrong, responsive issue)
- Component state bug (loading not showing, wrong conditional)
- Animation tweak (spring too bouncy, entrance too slow)
- Accessibility fix (missing aria-label, contrast issue)
- Performance fix (unnecessary re-render, missing lazy load)
- Single-file or 2-3 file changes within one domain

## When NOT to Use (redirect to pipeline)

- New component from scratch → `*apex-go` or `*apex-quick`
- Cross-domain change (CSS + React + animation) → `*apex-quick`
- New feature with multiple user flows → `*apex-go`
- Changes touching shared packages → `*apex-go`

---

## Execution Steps

### Step 1: Route

```
apex-lead analyzes the request using apex-route-request.md routing table.

IF scope == "single-agent":
  Proceed with *apex-fix
ELIF scope == "multi-agent" AND agents.count <= 2:
  Proceed with *apex-fix, chain agents sequentially
ELSE:
  Suggest *apex-quick or *apex-go instead
  Ask user: "This looks bigger than a quick fix. Want to use *apex-quick instead?"
```

**Output:** Target agent identified, scope confirmed.

**HANDOFF:** Follow `apex-handoff-protocol.md` — Emil announces delegation:
```
Emil: Isso e {domain} — delegando para {icon} {name} (@{id}).
      {one-line reason}
```

### Step 2: Execute

```
Specialist introduces themselves (1 line) then executes:

{icon} {name} aqui. {one-line assessment}
[reads files, understands code, applies fix]
```

Agent follows existing patterns in the codebase.
No design spec, no architecture docs — just fix the code.

**Rules:**
- Follow existing code patterns (don't refactor surrounding code)
- Don't add features beyond what was requested
- Don't create new files unless absolutely necessary
- Keep the change minimal and focused

### Step 3: Verify

Run minimal quality checks:

```bash
# Always run (profile-independent):
npm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null
npm run lint 2>/dev/null || true

# If test script exists:
npm test 2>/dev/null || true
```

**Gate:** QG-AX-FIX-001
- Zero new TypeScript errors (pre-existing errors are OK)
- Zero new lint errors (pre-existing errors are OK)
- No test regressions

If verification fails:
1. Agent fixes the issues (max 2 attempts)
2. If still failing after 2 attempts, present the issue to the user

### Step 4: Report

```
*apex-fix complete.

Agent: @{agent-id} ({agent-name})
Fix: {one-line summary}
Files modified:
  - {file1}
  - {file2}
Checks: typecheck PASS | lint PASS | tests PASS

Ready to commit? (describe any additional changes if needed)
```

**IMPORTANT:** Do NOT commit automatically. Always ask the user first.

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-FIX-001
    condition: "Fix scope exceeds 5 files"
    action: "WARN — suggest *apex-quick instead"
    blocking: false  # Warning only, user can override

  - id: VC-FIX-002
    condition: "Fix creates a new user-facing component"
    action: "BLOCK — new components require *apex-quick or *apex-go"
    blocking: true

  - id: VC-FIX-003
    condition: "Fix modifies shared packages (packages/*)"
    action: "BLOCK — shared package changes require full pipeline"
    blocking: true
```

---

## Examples

**Example 1 — CSS fix:**
```
User: *apex-fix "the header icons overlap on iPhone SE"
Emil: Routing to @css-eng (Josh) — CSS responsive issue, single-agent scope.
Josh: [reads Header.tsx, identifies min-width issue, fixes responsive breakpoint]
Emil: Fix complete. 1 file modified. typecheck PASS. Ready to commit?
```

**Example 2 — Animation tweak:**
```
User: *apex-fix "modal entrance animation is too bouncy"
Emil: Routing to @motion-eng (Matt) — spring config adjustment, single-agent scope.
Matt: [reads modal component, adjusts damping from 15 to 22, tests reduced-motion]
Emil: Fix complete. 1 file modified. typecheck PASS. Ready to commit?
```

**Example 3 — Scope upgrade:**
```
User: *apex-fix "add a notification badge to the header with animation"
Emil: This looks bigger than a quick fix — it's a new visual element with motion.
      Want to use *apex-quick instead? (3 phases: specify → implement → ship)
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | User (fix applied locally) |
| Next action | User decides to commit, or requests additional changes |

---

*Apex Squad — Quick Fix Task v1.0.0*
