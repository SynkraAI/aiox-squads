# Task: testing-strategy

```yaml
id: testing-strategy
version: "1.0.0"
title: "Testing Strategy with Testing Library"
description: >
  Plans the testing approach for a component, feature, or page using
  Testing Library methodology. Focuses on testing user behaviors rather
  than implementation details. Defines query strategies, integration
  test plans, edge case coverage, and ensures all assertions
  reflect what the user sees and does.
elicit: false
owner: react-eng
executor: react-eng
outputs:
  - User behavior inventory
  - Query strategy document
  - Integration test plan for main flows
  - Edge case and error state catalog
  - Test outlines ready for implementation
```

---

## When This Task Runs

This task runs when:
- A new component or feature needs a test plan before implementation
- Existing tests are brittle and need to be rewritten with better patterns
- A story requires comprehensive test coverage
- The team wants to improve test quality across a module
- `*test-strategy` or `*plan-tests` is invoked

This task does NOT run when:
- Tests are already written and passing (unless a rewrite is requested)
- The scope is visual regression testing (delegate to `@qa-visual`)
- The scope is cross-platform device testing (delegate to `@qa-xplatform`)
- The scope is performance testing (delegate to `@perf-eng`)

---

## Execution Steps

### Step 1: Identify User Behaviors to Test

List every meaningful interaction a user can have with the component or feature. Think from the user's perspective, not the developer's.

For each behavior, write a description in this format:
```
"The user can {action} by {interaction}, which results in {outcome}"
```

Examples:
- "The user can submit the form by clicking the Submit button, which results in a success message"
- "The user can filter results by typing in the search field, which results in the list updating"
- "The user can navigate between tabs by pressing Arrow keys, which results in focus moving to the next tab"

Categorize behaviors:
- **Critical path:** Core functionality that MUST work (highest priority)
- **Secondary:** Important but not blocking (medium priority)
- **Edge case:** Unusual but possible interactions (lower priority, still tested)

Do NOT list implementation details like "useState updates correctly" or "useEffect fires on mount."

**Output:** Prioritized list of user behaviors to test.

### Step 2: Define Query Strategy

For each element that tests need to interact with, define the query approach following the Testing Library priority.

**Query priority (most preferred to least):**

1. **`getByRole`** — Accessible roles (button, textbox, heading, dialog, tab, etc.)
   - Best for: buttons, links, inputs, headings, navigation landmarks
   - Example: `getByRole('button', { name: 'Submit' })`

2. **`getByLabelText`** — Form labels
   - Best for: form inputs associated with labels
   - Example: `getByLabelText('Email address')`

3. **`getByPlaceholderText`** — Placeholder text
   - Best for: inputs without visible labels (not ideal, but sometimes necessary)

4. **`getByText`** — Visible text content
   - Best for: paragraphs, spans, status messages
   - Example: `getByText('No results found')`

5. **`getByDisplayValue`** — Current input value
   - Best for: asserting current state of form inputs

6. **`getByAltText`** — Image alt text
   - Best for: images, icons with alt text

7. **`getByTitle`** — Title attribute
   - Best for: elements with title tooltips

8. **`getByTestId`** — Data test IDs (LAST RESORT)
   - Only when no accessible query works
   - Must justify why no semantic query is possible

For each element in the test plan, document which query will be used and why. If `getByTestId` is chosen, flag it for review — there may be an accessibility gap.

**Output:** Query strategy table mapping each test target to its query method.

### Step 3: Plan Integration Tests for Main Flows

Design integration tests that exercise the component with its real children, real context providers, and realistic data.

For each critical path behavior:
- Define the test setup (what providers are needed, what data to seed)
- Write the user interaction sequence (render → find → interact → assert)
- Define the expected outcome from the user's perspective
- Include both the "happy path" and the first-failure scenario

```typescript
// Integration test outline
test('user can complete checkout by filling form and clicking pay', async () => {
  // Setup: render with CartProvider containing 2 items
  // Act: fill shipping form → click Continue → fill payment → click Pay
  // Assert: success message is visible, cart is empty
});
```

Integration tests should:
- Use `render()` with all necessary providers
- Use `userEvent` for interactions (not `fireEvent` — userEvent simulates real browser behavior)
- Avoid mocking child components (test the real tree)
- Mock only external boundaries (API calls, browser APIs)

**Output:** Integration test outlines for all critical path flows.

### Step 4: Identify Edge Cases and Error States

Catalog every edge case and error state that could occur.

**Categories:**
- **Empty states:** No data, empty list, no search results
- **Loading states:** Skeleton, spinner, progressive loading
- **Error states:** Network error, validation error, server error, timeout
- **Boundary values:** Maximum length input, minimum/maximum numbers, special characters
- **Accessibility edge cases:** Focus management after delete, announcements on dynamic content
- **Concurrency:** Rapid clicking, typing ahead of debounce, stale closures

For each edge case:
- Describe the scenario
- Define the expected behavior from the user's perspective
- Note any screen reader announcements that should occur

**Output:** Edge case catalog with expected behaviors.

### Step 5: Write Test Outlines

Create the actual test file structure with `describe` blocks, `test` descriptions, and inline comments indicating what to implement.

```typescript
describe('SearchComponent', () => {
  describe('searching', () => {
    test('displays results when user types a query', async () => {
      // render with mocked API
      // type "react" into search input (getByRole('searchbox'))
      // wait for results to appear
      // assert result items are visible (getByRole('listitem'))
    });

    test('displays "no results" when query matches nothing', async () => {
      // render with mocked API returning empty
      // type "xyznonexistent" into search input
      // assert "No results found" message is visible (getByText)
    });
  });

  describe('error handling', () => {
    test('displays error message when API fails', async () => {
      // render with mocked API that rejects
      // type query
      // assert error message is visible
      // assert retry button is available (getByRole('button', { name: 'Retry' }))
    });
  });

  describe('keyboard navigation', () => {
    test('user can navigate results with arrow keys', async () => {
      // render with results
      // press ArrowDown
      // assert focus moves to first result
    });
  });
});
```

**Output:** Test file outlines ready for implementation.

### Step 6: Validate No Implementation Details in Assertions

Review all test outlines and flag any assertion that tests implementation details rather than user-visible behavior.

**Red flags (NEVER assert on these):**
- Internal state values (`expect(state.count).toBe(5)`)
- Number of re-renders (`expect(renderCount).toBe(2)`)
- CSS class names (`expect(element).toHaveClass('active')`)
- DOM structure (`expect(container.querySelector('.inner')).toBeTruthy()`)
- Hook call order or arguments
- Internal function calls (`expect(handleClick).toHaveBeenCalled()` — unless it is a callback prop)

**Green flags (GOOD assertions):**
- Visible text content (`expect(screen.getByText('Success')).toBeInTheDocument()`)
- Element visibility (`expect(dialog).toBeVisible()`)
- Accessible state (`expect(button).toBeDisabled()`, `expect(checkbox).toBeChecked()`)
- User-visible attributes (`expect(input).toHaveValue('hello')`)
- Focus state (`expect(button).toHaveFocus()`)

**Output:** Validated test outlines with implementation detail assertions removed.

---

## Quality Criteria

- Every test must describe a user behavior, not an implementation detail
- `getByTestId` usage must be justified and flagged for accessibility review
- Integration tests must use `userEvent`, not `fireEvent`
- Edge cases must cover empty, loading, and error states at minimum
- All test outlines must be implementable without further design decisions

---

*Squad Apex — Testing Strategy Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-testing-strategy
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Every test must describe a user behavior, not an implementation detail"
    - "getByTestId usage must be justified and flagged for accessibility review"
    - "Integration tests must use userEvent, not fireEvent"
    - "Edge cases must cover empty, loading, and error states at minimum"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@a11y-eng` or `@apex-lead` |
| Artifact | User behavior inventory, query strategy document, integration test plan, edge case catalog, and test outlines ready for implementation |
| Next action | Implement tests following the outlines or route accessibility gaps flagged by getByTestId usage to `@a11y-eng` |
