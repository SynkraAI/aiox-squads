# Task: figma-sync-setup

```yaml
id: figma-sync-setup
version: "1.0.0"
title: "Figma Sync Setup"
description: >
  Set up the pipeline for syncing design tokens from Figma Variables to
  code. Configures the export method (REST API or Tokens Studio), sets
  up Style Dictionary transforms, creates a CI build step, and configures
  drift detection to catch token mismatches between Figma and code.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Figma Variables export configuration
  - Style Dictionary configuration file
  - CI pipeline step for token generation
  - Drift detection script and report format
```

---

## When This Task Runs

This task runs when:
- The design system is being initialized and needs a Figma-to-code pipeline
- The current sync process is manual and needs automation
- A new collection of Figma Variables is added (e.g., a new mode or category)
- The token architecture changes and the pipeline needs updating
- Drift between Figma and code tokens is detected

This task does NOT run when:
- The task is about token naming conventions (use `naming-convention`)
- The task is about token values or mode definitions (use `token-architecture`)
- The task is about CI/CD pipeline infrastructure (route to `@devops`)

---

## Pipeline Overview

```
Figma Variables → Export (API/Plugin) → Transform (Style Dictionary) → Code Artifacts → CI Validation
```

---

## Execution Steps

### Step 1: Define Tokens in Figma Variables

Ensure Figma Variables are structured correctly for export:

1. Organize variables into collections by category:
   - **Primitives** — raw color scales, spacing values, type scale
   - **Semantic** — purpose-driven tokens (bg, text, border, status)
   - **Component** — component-scoped tokens (button, input, card)
2. Set up modes in each collection:
   - Light mode (default)
   - Dark mode
   - High-contrast mode
   - Dark high-contrast mode
3. Naming conventions in Figma:
   - Use `/` as separator: `color/bg/default`, `color/text/muted`
   - Match the code naming convention (converted to `.` or `-` during export)
4. Verify all variables have values for ALL modes (no unset mode values)
5. Document the Figma file URL and collection structure

### Step 2: Configure Export Method

Set up the export mechanism from Figma:

**Option A: Figma REST API (recommended for automation)**
1. Generate a Figma Personal Access Token
2. Use the Variables API endpoint:
   ```
   GET /v1/files/{file_key}/variables/local
   ```
3. Create a script to fetch and normalize the API response
4. Map Figma variable structure to Style Dictionary format
5. Store the script in `tools/figma-sync/fetch-tokens.ts`

**Option B: Tokens Studio Plugin**
1. Install Tokens Studio in the Figma file
2. Configure the sync target (GitHub repository, JSON file)
3. Set up the token format to match Style Dictionary input
4. Configure push/pull behavior (manual vs auto-sync)
5. Document the plugin configuration settings

**Output format** (normalized JSON for Style Dictionary):
```json
{
  "color": {
    "bg": {
      "default": {
        "$value": "#ffffff",
        "$type": "color",
        "$description": "Default background color"
      }
    }
  }
}
```

### Step 3: Set Up Style Dictionary Transforms

Configure Style Dictionary to transform tokens into code:

1. Create Style Dictionary config (`tokens/config.js`):
   ```javascript
   module.exports = {
     source: ['tokens/input/**/*.json'],
     platforms: {
       css: {
         transformGroup: 'css',
         buildPath: 'tokens/output/css/',
         files: [{
           destination: 'variables.css',
           format: 'css/variables',
           options: { outputReferences: true }
         }]
       },
       ts: {
         transformGroup: 'js',
         buildPath: 'tokens/output/ts/',
         files: [{
           destination: 'tokens.ts',
           format: 'javascript/es6'
         }]
       }
     }
   };
   ```
2. Configure custom transforms if needed:
   - Name transform: `/` to `-` for CSS, `/` to `.` for JS
   - Value transform: resolve references, convert units
   - Mode transform: generate per-mode files or data-attribute selectors
3. Add a build script: `npm run tokens:build`
4. Verify output matches expected format from `token-architecture` task
5. Test the full transform pipeline with sample token data

### Step 4: Create CI Build Step

Add token generation to the CI/CD pipeline:

1. Create a CI step that runs on token file changes:
   ```yaml
   # In CI config
   tokens:
     runs-on: ubuntu-latest
     steps:
       - name: Fetch tokens from Figma
         run: npm run tokens:fetch
       - name: Build token artifacts
         run: npm run tokens:build
       - name: Check for drift
         run: npm run tokens:drift-check
   ```
2. Trigger conditions:
   - On push: when files in `tokens/` change
   - On schedule: daily drift check against Figma
   - On manual dispatch: when designer requests sync
3. Failure handling:
   - Build failure: block the PR merge
   - Drift detected: create an issue or comment on PR
4. Document the CI step in the project's CI/CD documentation
5. Coordinate with `@devops` for pipeline integration

### Step 5: Configure Drift Detection

Set up automated detection of Figma-code token mismatches:

1. Create a drift detection script (`tools/figma-sync/drift-check.ts`):
   - Fetch current tokens from Figma API
   - Compare against committed token JSON files
   - Detect differences:
     - **Added** — token exists in Figma but not in code
     - **Removed** — token exists in code but not in Figma
     - **Changed** — token value differs between Figma and code
     - **Missing mode** — token has a mode value in Figma but not in code
2. Generate a drift report:

```markdown
# Token Drift Report

**Date:** {YYYY-MM-DD}
**Figma file:** {URL}

## Drift Summary
- Added: {N} tokens
- Removed: {N} tokens
- Changed: {N} tokens
- Missing modes: {N} tokens

## Details
| Token | Type | Figma Value | Code Value |
|-------|------|-------------|------------|
| color.bg.accent | CHANGED | #6366F1 | #3B82F6 |
| color.status.warning | ADDED | #F59E0B | (missing) |
```

3. Configure alerting:
   - CI comment on PR if drift is detected
   - Weekly digest if drift accumulates
4. Set acceptable drift threshold:
   - 0 drift for semantic and component tokens (strict)
   - Allowed drift for primitive tokens during active design iteration

---

## Maintenance

Once the pipeline is set up:

- Designers update Figma Variables and notify the team
- CI fetches, transforms, and commits updated token files
- Drift detection runs daily to catch manual code changes that bypass Figma
- `@design-sys-eng` reviews and resolves any drift reports

---

*Apex Squad — Figma Sync Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-figma-sync-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Figma export configuration must successfully fetch tokens from the Figma file"
    - "Style Dictionary must transform tokens into valid CSS and/or TypeScript output"
    - "CI pipeline step must run without errors and produce token artifacts"
    - "Drift detection script must detect at least added, removed, and changed tokens"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Complete Figma-to-code sync pipeline with export config, Style Dictionary transforms, CI step, and drift detection |
| Next action | Coordinate with `@devops` for CI integration and notify `@design-sys-eng` for ongoing token maintenance |
