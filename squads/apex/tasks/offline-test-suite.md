# Task: offline-test-suite

```yaml
id: offline-test-suite
version: "1.0.0"
title: "Offline Behavior Test Suite"
description: >
  Creates a comprehensive test suite for offline behavior including
  offline-capable feature identification, data persistence testing,
  offline-to-online transition testing, retry and sync mechanism
  verification, error state validation, and documentation of
  expected offline behavior.
elicit: false
owner: qa-xplatform
executor: qa-xplatform
outputs:
  - Offline-capable feature inventory
  - Data persistence test results
  - Offline-to-online transition tests
  - Retry/sync mechanism verification
  - Error state validation results
  - Expected offline behavior documentation
```

---

## When This Task Runs

This task runs when:
- The application has offline capabilities that need testing
- Users report data loss or sync issues after connectivity changes
- A new offline feature has been implemented
- The team wants to ensure reliability in poor connectivity conditions
- `*offline-test` or `*test-offline` is invoked

This task does NOT run when:
- The application has no offline capabilities (purely online)
- Only gesture testing is needed (use `gesture-test-suite`)
- Device matrix design is needed (use `device-matrix-design`)
- Only cross-platform infrastructure setup is needed (use `cross-platform-test-setup`)

---

## Execution Steps

### Step 1: Identify Offline-Capable Features

Catalog every feature in the application and classify its offline behavior.

**Feature classification:**

| Category | Behavior | Example |
|----------|----------|---------|
| **Full offline** | Works completely without network | Reading cached content, local settings |
| **Read-only offline** | Can view cached data but not modify | Browsing cached articles, viewing saved items |
| **Queue offline** | Actions queued for sync when online | Composing messages, creating drafts |
| **Degraded offline** | Partial functionality available | Search works on cached data only |
| **Online-only** | Does not work offline | Payment processing, real-time collaboration |

**Feature inventory:**
| # | Feature | Offline Category | Data Storage | Sync Strategy |
|---|---------|-----------------|-------------|---------------|
| 1 | Dashboard viewing | Read-only offline | IndexedDB | Background sync |
| 2 | Form submission | Queue offline | LocalStorage | Queue + retry |
| 3 | Settings editing | Full offline | AsyncStorage | Sync on reconnect |
| 4 | Search | Degraded offline | Cache API | Online-first |
| 5 | File upload | Queue offline | FileSystem | Resume upload |
| 6 | Chat messages | Queue offline | SQLite | Optimistic UI |
| 7 | Authentication | Online-only | — | Redirect to login |
| 8 | Payment | Online-only | — | Error message |

**For each offline feature, document:**
- What data is available offline?
- How is it stored? (IndexedDB, LocalStorage, AsyncStorage, SQLite, Cache API)
- When was it last synced?
- What happens when the user tries to modify data offline?
- How does sync work when reconnecting?

**Output:** Offline-capable feature inventory.

### Step 2: Test Data Persistence

Verify that data persists correctly when the application goes offline.

**Playwright (Web):**
```typescript
test.describe('Offline Data Persistence', () => {
  test('should display cached data when offline', async ({ page, context }) => {
    // Load page while online
    await page.goto('/dashboard');
    await expect(page.getByTestId('data-loaded')).toBeVisible();

    // Go offline
    await context.setOffline(true);

    // Reload page
    await page.reload();

    // Cached data should still be visible
    await expect(page.getByTestId('dashboard-content')).toBeVisible();
    await expect(page.getByTestId('offline-indicator')).toBeVisible();
  });

  test('should preserve form data when connection drops', async ({ page, context }) => {
    await page.goto('/form');
    await page.getByTestId('name-input').fill('John Doe');
    await page.getByTestId('email-input').fill('john@example.com');

    // Connection drops
    await context.setOffline(true);

    // Form data should persist
    await expect(page.getByTestId('name-input')).toHaveValue('John Doe');
    await expect(page.getByTestId('email-input')).toHaveValue('john@example.com');
  });

  test('should show stale indicator on cached data', async ({ page, context }) => {
    await page.goto('/dashboard');
    await context.setOffline(true);
    await page.reload();

    // Stale data indicator should be visible
    await expect(page.getByTestId('last-synced')).toBeVisible();
    await expect(page.getByTestId('stale-banner')).toContainText('offline');
  });
});
```

**Detox (React Native):**
```typescript
describe('Offline Data Persistence', () => {
  it('should display cached data when offline', async () => {
    // Load data while online
    await element(by.id('dashboard-screen')).tap();
    await waitFor(element(by.id('data-loaded'))).toBeVisible().withTimeout(5000);

    // Enable airplane mode
    await device.setAirplaneMode(true);

    // Navigate away and back
    await element(by.id('settings-tab')).tap();
    await element(by.id('dashboard-tab')).tap();

    // Cached data should be visible
    await expect(element(by.id('dashboard-content'))).toBeVisible();
    await expect(element(by.id('offline-indicator'))).toBeVisible();
  });

  afterEach(async () => {
    await device.setAirplaneMode(false); // Restore connectivity
  });
});
```

**Persistence checks:**
- [ ] Data loaded while online is accessible offline
- [ ] Data is correct (not corrupted or partial)
- [ ] Timestamps show when data was last synced
- [ ] Offline indicator is displayed to the user
- [ ] Large datasets persist correctly (not truncated)
- [ ] Images/media cached and displayed offline

**Output:** Data persistence test results.

### Step 3: Test Offline-to-Online Transitions

Verify behavior when the connection is restored after being offline.

**Transition scenarios:**

```typescript
test.describe('Offline to Online Transitions', () => {
  test('should sync queued actions when coming back online', async ({ page, context }) => {
    // Create action while offline
    await context.setOffline(true);
    await page.getByTestId('create-button').click();
    await page.getByTestId('title-input').fill('Offline Item');
    await page.getByTestId('save-button').click();

    // Verify queued indicator
    await expect(page.getByTestId('pending-sync')).toBeVisible();

    // Come back online
    await context.setOffline(false);

    // Wait for sync
    await expect(page.getByTestId('pending-sync')).not.toBeVisible({ timeout: 10000 });
    await expect(page.getByTestId('synced-indicator')).toBeVisible();
  });

  test('should refresh stale data on reconnection', async ({ page, context }) => {
    await page.goto('/dashboard');
    const initialValue = await page.getByTestId('metric-value').textContent();

    await context.setOffline(true);
    await page.waitForTimeout(2000); // Simulate time passing

    await context.setOffline(false);

    // Data should refresh automatically
    await page.waitForTimeout(3000);
    // Verify refresh happened (data may or may not change, but sync indicator should update)
    await expect(page.getByTestId('last-synced')).not.toContainText('offline');
  });

  test('should handle conflict resolution', async ({ page, context }) => {
    // Edit item while online
    await page.goto('/item/1');
    const originalTitle = await page.getByTestId('title').textContent();

    // Go offline and make changes
    await context.setOffline(true);
    await page.getByTestId('edit-button').click();
    await page.getByTestId('title-input').fill('Offline Edit');
    await page.getByTestId('save-button').click();

    // Come back online (server may have different version)
    await context.setOffline(false);

    // If conflict exists, conflict resolution UI should appear
    // OR: last-write-wins should apply silently
    // (depends on application's sync strategy)
  });
});
```

**Transition checks:**
- [ ] Queued actions sync successfully
- [ ] Sync order is maintained (FIFO)
- [ ] Stale data refreshes automatically
- [ ] Conflict resolution works (if applicable)
- [ ] No duplicate items created from queued actions
- [ ] UI updates to reflect synced state
- [ ] Network errors during sync are handled gracefully

**Output:** Offline-to-online transition test results.

### Step 4: Verify Retry and Sync Mechanisms

Test the reliability of retry logic and sync mechanisms.

```typescript
test.describe('Retry Mechanisms', () => {
  test('should retry failed requests with exponential backoff', async ({ page, context }) => {
    // Intercept API calls to simulate failures
    let attempts = 0;
    await page.route('**/api/sync', (route) => {
      attempts++;
      if (attempts <= 3) {
        route.fulfill({ status: 503 }); // Fail first 3 attempts
      } else {
        route.fulfill({ status: 200, body: JSON.stringify({ success: true }) });
      }
    });

    // Trigger sync
    await context.setOffline(true);
    await page.getByTestId('create-button').click();
    await page.getByTestId('save-button').click();
    await context.setOffline(false);

    // Should eventually succeed after retries
    await expect(page.getByTestId('synced-indicator')).toBeVisible({ timeout: 30000 });
    expect(attempts).toBeGreaterThan(1);
  });

  test('should preserve queue across app restarts', async ({ page, context }) => {
    // Queue an action offline
    await context.setOffline(true);
    await page.getByTestId('create-button').click();
    await page.getByTestId('save-button').click();

    // Close and reopen (simulated by reload)
    await page.reload();

    // Queue should still exist
    await expect(page.getByTestId('pending-sync')).toBeVisible();

    // Come online — queued action should sync
    await context.setOffline(false);
    await expect(page.getByTestId('synced-indicator')).toBeVisible({ timeout: 10000 });
  });

  test('should handle partial sync failures', async ({ page }) => {
    // Queue multiple actions
    // Some succeed, some fail
    // Verify: succeeded items are synced, failed items remain in queue
    // Verify: user can see which items are pending
  });
});
```

**Sync mechanism checks:**
- [ ] Failed requests are retried automatically
- [ ] Retry uses exponential backoff (not hammering the server)
- [ ] Maximum retry attempts are defined and respected
- [ ] Queue persists across app restarts and page reloads
- [ ] Partial sync is handled (some items sync, others retry)
- [ ] User can see sync status (pending, syncing, synced, failed)
- [ ] User can manually trigger a sync retry
- [ ] Sync does not block UI interactions

**Output:** Retry and sync mechanism test results.

### Step 5: Test Error States

Verify that appropriate error messages and states are shown during offline scenarios.

```typescript
test.describe('Offline Error States', () => {
  test('should show offline message when navigating to online-only feature', async ({ page, context }) => {
    await context.setOffline(true);
    await page.getByTestId('payment-button').click();

    await expect(page.getByTestId('offline-error')).toBeVisible();
    await expect(page.getByTestId('offline-error')).toContainText(
      'This feature requires an internet connection'
    );
  });

  test('should show retry option on failed request', async ({ page, context }) => {
    await context.setOffline(true);
    await page.getByTestId('refresh-button').click();

    await expect(page.getByTestId('error-message')).toBeVisible();
    await expect(page.getByTestId('retry-button')).toBeVisible();

    // Come online and retry
    await context.setOffline(false);
    await page.getByTestId('retry-button').click();
    await expect(page.getByTestId('data-loaded')).toBeVisible();
  });

  test('should show connection restored notification', async ({ page, context }) => {
    await context.setOffline(true);
    await expect(page.getByTestId('offline-banner')).toBeVisible();

    await context.setOffline(false);
    await expect(page.getByTestId('online-restored-toast')).toBeVisible();
    await expect(page.getByTestId('offline-banner')).not.toBeVisible();
  });

  test('should handle slow connection gracefully', async ({ page }) => {
    // Simulate slow 2G connection
    const client = await page.context().newCDPSession(page);
    await client.send('Network.emulateNetworkConditions', {
      offline: false,
      downloadThroughput: 50 * 1024 / 8, // 50 KB/s
      uploadThroughput: 20 * 1024 / 8,   // 20 KB/s
      latency: 2000,                       // 2s latency
    });

    await page.getByTestId('load-data-button').click();

    // Should show loading state, not error
    await expect(page.getByTestId('loading-indicator')).toBeVisible();

    // Should eventually load (with patience)
    await expect(page.getByTestId('data-loaded')).toBeVisible({ timeout: 30000 });
  });
});
```

**Error state checks:**
- [ ] Offline indicator is visible when connection is lost
- [ ] Online restored notification appears when connection returns
- [ ] Online-only features show helpful error messages offline
- [ ] Retry buttons are available for failed requests
- [ ] Error messages are user-friendly (not technical error codes)
- [ ] Slow connections show loading states, not timeouts (reasonable timeout values)
- [ ] The app does not crash during connectivity changes

**Output:** Error state test results.

### Step 6: Document Expected Offline Behavior

Create definitive documentation of what the user should expect in offline scenarios.

**Documentation format:**
```markdown
## Offline Behavior Specification

### Connection States
| State | Indicator | User Impact |
|-------|-----------|-------------|
| Online | Green dot / no indicator | Full functionality |
| Offline | "Offline" banner | Read cached, queue writes |
| Reconnecting | "Syncing..." spinner | Brief, automatic |
| Slow connection | "Slow connection" warning | Longer load times |

### Per-Feature Offline Behavior
| Feature | Offline Behavior | Data Staleness | Sync Strategy |
|---------|-----------------|---------------|---------------|
| Dashboard | Read cached data | Shows "Last updated: {time}" | Auto-refresh on reconnect |
| Create item | Queued locally | Pending indicator | Auto-sync on reconnect |
| Search | Searches cached data only | May miss recent items | Full refresh on reconnect |
| Settings | Full offline editing | — | Sync on save + connect |
| Payment | Blocked | Error message | Must be online |

### Sync Order
1. Settings sync first (user preferences)
2. Created items sync in creation order
3. Edits sync in edit order
4. Deletes sync last (prevent conflicts)

### Conflict Resolution
- Strategy: Last-write-wins with timestamp
- User notified of conflicts in activity log
- Manual merge available for document edits
```

**Output:** Expected offline behavior documentation.

---

## Quality Criteria

- Every offline-capable feature must have at least one offline test
- Data persistence must be verified after going offline and reloading
- Offline-to-online transitions must sync all queued actions
- Retry mechanisms must use exponential backoff
- Error messages must be user-friendly and offer retry options
- The offline behavior specification must cover every feature

---

*Squad Apex — Offline Behavior Test Suite Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-offline-test-suite
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Every offline-capable feature must have at least one offline test"
    - "Data persistence must be verified after going offline and reloading"
    - "Offline-to-online transitions must sync all queued actions without duplicates"
    - "Retry mechanisms must use exponential backoff with documented max attempts"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Offline-capable feature inventory, data persistence tests, offline-to-online transition tests, retry/sync verification, error state validation, and expected offline behavior documentation |
| Next action | Integrate offline tests into CI and route sync failures to `@react-eng` or `@mobile-eng` for fixes |
