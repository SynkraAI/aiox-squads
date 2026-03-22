# Task: monorepo-structure

```yaml
id: monorepo-structure
version: "1.0.0"
title: "Monorepo Structure Validation"
description: >
  Validate or define the monorepo package structure. Audits import rules,
  validates package boundaries, checks for circular dependencies, verifies
  RSC compatibility of shared packages, and documents all structural decisions.
elicit: false
owner: frontend-arch
executor: frontend-arch
outputs:
  - Monorepo structure audit report
  - Circular dependency analysis
  - Import rule violation list
  - Structure decision documentation
```

---

## When This Task Runs

This task runs when:
- A new package or app is being added to the monorepo
- Package boundaries may have been violated (cross-app imports detected)
- Circular dependency warnings appear during build
- The monorepo structure needs to be documented or reviewed
- A refactoring involves moving code between packages

This task does NOT run when:
- The change is within a single package with no boundary implications
- The question is about a specific component's API (route to `@design-sys-eng`)
- The concern is about deployment configuration (route to `@devops`)

---

## Monorepo Rules

The following structural rules are enforced:

```yaml
import_rules:
  apps_isolation: "apps/ packages NEVER import from other apps/"
  packages_shared: "packages/ can import from other packages/ (respecting dependency graph)"
  internal_convention: "Internal modules use barrel exports (index.ts)"
  no_relative_cross_package: "Cross-package imports MUST use package names, never relative paths"

package_types:
  apps: "Deployable applications (Next.js, Expo, etc.)"
  packages: "Shared libraries consumed by apps and other packages"
  tooling: "Build tools, configs, and scripts (not deployed)"
```

---

## Execution Steps

### Step 1: Audit Import Rules

Scan the codebase for import rule violations:

1. Scan all `import` and `require` statements in `apps/` directories
2. Flag any import that references another `apps/` package directly
3. Check that cross-package imports use the package name (not relative `../../packages/`)
4. Verify barrel exports exist for all public APIs in `packages/`
5. Check for path alias consistency across `tsconfig.json` files
6. Produce a violation list with file, line, and the offending import

### Step 2: Validate Package Boundaries

Ensure each package has a well-defined boundary:

1. Verify each package has a `package.json` with correct `name`, `main`, and `exports`
2. Check that `exports` field restricts access to the public API only
3. Verify internal modules are not directly importable from outside
4. Ensure each package has its own `tsconfig.json` extending the base
5. Validate that package dependencies are declared (no phantom dependencies)
6. Check that devDependencies are not used at runtime

### Step 3: Check for Circular Dependencies

Detect and resolve circular dependency chains:

1. Run dependency graph analysis across all packages
2. Identify direct circular dependencies (A imports B, B imports A)
3. Identify transitive circular dependencies (A → B → C → A)
4. For each cycle, determine the root cause:
   - Shared types that should be in a separate package
   - Utility functions that should be extracted
   - Tight coupling that needs an interface boundary
5. Propose resolution for each cycle with specific refactoring steps

### Step 4: Verify RSC Compatibility

Ensure shared packages work with React Server Components:

1. Check each `packages/` entry for `'use client'` directive usage
2. Identify packages that are server-only (no client dependencies)
3. Identify packages that are client-only (require browser APIs)
4. Verify universal packages work in both contexts
5. Check for packages that inadvertently pull in client-side code:
   - `useState`, `useEffect` without `'use client'`
   - Browser globals (`window`, `document`) without guards
   - Third-party libraries that are client-only
6. Recommend `'use client'` boundary placement for each package

### Step 5: Document Structure Decisions

Create or update the monorepo structure documentation:

1. Generate a package dependency graph (visual or ASCII)
2. Document each package's purpose, type, and RSC compatibility
3. List all enforced import rules with examples
4. Document any exceptions and their justification
5. Update `docs/architecture/monorepo-structure.md`

---

## Output Format

```markdown
# Monorepo Structure Audit

**Date:** {YYYY-MM-DD}
**Auditor:** @frontend-arch

## Package Map

| Package | Type | RSC Compatible | Dependencies |
|---------|------|---------------|-------------|
| apps/web | App | N/A | packages/ui, packages/utils |
| packages/ui | Shared | Partial | packages/tokens |
| ... | ... | ... | ... |

## Import Rule Violations
{List from Step 1 — or "No violations found"}

## Boundary Issues
{Findings from Step 2}

## Circular Dependencies
{Findings from Step 3 — or "No circular dependencies"}

## RSC Compatibility
{Findings from Step 4}

## Recommendations
{Structural improvements proposed}

## Verdict: {HEALTHY | NEEDS ATTENTION | STRUCTURAL ISSUES}
```

---

*Apex Squad — Monorepo Structure Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-monorepo-structure
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Report must contain at least one actionable finding or explicit all-clear"
    - "Circular dependency analysis must cover all packages in the monorepo"
    - "Import rule violations must reference specific files and offending imports"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Monorepo structure audit report with circular dependency analysis and import violation list |
| Next action | Route structural fixes to `@cross-plat-eng` for `monorepo-setup` or approve structure as healthy |
