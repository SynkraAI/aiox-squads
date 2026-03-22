# Edge Runtime Compatibility Checklist — Apex Squad

> Reviewer: frontend-arch
> Purpose: Verify that code targeting edge runtime is fully compatible and performant.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. API Compatibility

- [ ] No Node.js-only APIs used (`fs`, `path`, `child_process`, `crypto` full module)
- [ ] No `Buffer` usage — use `Uint8Array` or `TextEncoder`/`TextDecoder` instead
- [ ] `fetch` API used for all HTTP requests (no `http`/`https` modules)
- [ ] Web Crypto API used instead of Node.js `crypto` module
- [ ] No `process.cwd()` or `__dirname` / `__filename` usage
- [ ] No dynamic `require()` calls — only static ESM imports
- [ ] `URL` and `URLSearchParams` from Web API used consistently

---

## 2. Dependencies

- [ ] All imported dependencies are edge-compatible (no native C++ addons)
- [ ] No native modules (`bcrypt`, `sharp`, etc.) — use edge alternatives (`bcryptjs`, etc.)
- [ ] No `process.env` accessed at runtime beyond values inlined at build time
- [ ] Environment variables accessed only through the framework's env system
- [ ] Dependency bundle size checked — edge has stricter size limits
- [ ] No polyfills needed for target edge runtime (Vercel Edge, Cloudflare Workers)
- [ ] Verified with `edge-runtime` or equivalent local testing tool

---

## 3. Performance

- [ ] TTFB < 200ms on edge (measured or estimated)
- [ ] Response streaming works correctly — no buffering entire response
- [ ] No cold start issues — initialization code is minimal
- [ ] No heavy computation at request time — offloaded to serverless or background
- [ ] Cache-Control headers set appropriately for edge caching
- [ ] Edge-side includes or partial rendering used where beneficial
- [ ] Response size is reasonable — no sending large payloads from edge

---

## 4. Error Handling

- [ ] Errors are caught and return proper HTTP responses (not unhandled rejections)
- [ ] Timeout handling implemented for external service calls
- [ ] Fallback behavior defined for when upstream services are unavailable
- [ ] Error logging compatible with edge runtime (no `console.error` with objects that fail serialization)

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
