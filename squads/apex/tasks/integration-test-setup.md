# Task: integration-test-setup

```yaml
id: integration-test-setup
version: "1.0.0"
title: "Integration Test Setup"
description: >
  Creates integration test suites for composite component interactions.
  Tests how components work TOGETHER (modal + form + toast, nav + drawer + content),
  not just in isolation. Covers user flows that span multiple components.
elicit: true
owner: qa-visual
executor: react-eng
dependencies:
  - tasks/testing-strategy.md
  - tasks/apex-discover-components.md
  - checklists/component-quality-checklist.md
outputs:
  - Integration test files for specified flows
  - Test utilities for composite component rendering
  - CI configuration for integration test runs
```

---

## Command

### `*apex-integration-test {flow|component-group}`

Creates integration tests for composite interactions.

---

## How It Works

### Step 1: Identify Integration Points

```yaml
detection:
  auto_detect:
    - Components that import 3+ other components
    - Pages/layouts that compose multiple interactive elements
    - User flows that span form → validation → submit → feedback
    - Modal/drawer/toast chains triggered by actions

  common_patterns:
    - form_flow: "Input → Validation → Submit → Loading → Success/Error toast"
    - navigation_flow: "Click nav → Route change → Page render → Scroll position"
    - modal_flow: "Trigger → Modal open → Form inside → Submit → Modal close → Feedback"
    - filter_flow: "Select filter → List update → Pagination reset → URL sync"
    - auth_flow: "Login form → API call → Redirect → Session state"
```

### Step 2: Generate Test Suite

```yaml
test_structure:
  framework_detection:
    - if: "vitest in package.json"
      use: "vitest + @testing-library/react"
    - if: "jest in package.json"
      use: "jest + @testing-library/react"
    - if: "playwright in package.json"
      use: "playwright for E2E integration"

  test_patterns:
    render_composite: "Render parent with all children, verify interactions"
    user_flow: "Simulate complete user journey with userEvent"
    state_propagation: "Verify state changes propagate across components"
    error_cascade: "Trigger error in child, verify parent handles gracefully"
    keyboard_flow: "Tab through composite, verify focus management"
    async_coordination: "Multiple async operations, verify loading states"

  output_per_flow:
    - Test file: "{flow-name}.integration.test.tsx"
    - Test utility: "render-{flow-name}.tsx (custom render with providers)"
    - Fixtures: "mock data for the flow"
```

### Step 3: Options

```yaml
options:
  1_generate:
    label: "Gerar testes para {flow}"
    action: "Create test files"

  2_all_flows:
    label: "Detectar e gerar para todos os flows"
    action: "Auto-detect all integration points, generate tests"

  3_add_ci:
    label: "Configurar CI para integration tests"
    action: "Add test:integration script to package.json"
```

---

*Apex Squad — Integration Test Setup Task v1.0.0*
