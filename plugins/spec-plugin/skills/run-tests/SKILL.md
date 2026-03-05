---
name: run-tests
description: "Execute test specifications against the running application. Starts services, hits APIs, checks browser behavior, verifies end-to-end flows, and reports pass/fail for each test case. Use after /implement-story has completed stories and /write-test-specs has created spec files."
argument-hint: "[spec file path, e.g. specs/plan-0-infrastructure/qa/010-service-health.md]"
---

Your task: execute a single test spec against the running application. Start services, hit APIs, check browser behavior, verify end-to-end flows. Report pass/fail for each test case.

## Phase 1 — Load Context

1. Read the test spec file at the provided path
2. Read the plan architecture for service details (ports, URLs, auth)
3. Check what's currently running (`lsof`, `curl health endpoints`)

## Phase 2 — Environment Setup

### Mandatory Pre-Flight Check (Fail-Fast)

Before running ANY test case, verify ALL required services are up and reachable. Check each service listed in the spec's prerequisites and the plan architecture.

**If ANY required service is down or misconfigured, STOP IMMEDIATELY.** Do not run partial tests — they produce confusing results. Report the environment failure to the team lead via SendMessage with:
- Which service(s) are down
- The exact error (connection refused, auth failed, wrong database, etc.)
- What needs to be fixed before QA can proceed

The orchestrator will spawn an engineer to fix the environment before re-running QA.

### Documentation Check

**Pre-check: is setup documented?** Before starting any services, verify that startup commands and prerequisites are documented. Check these sources in order:
1. `docs/dev-environment.md` — should list exact startup commands for all services
2. The plan's architecture doc (`specs/<plan-name>/architecture.md`) — should list ports, URLs, config
3. Story execution logs — should have `**QA Setup**` subsections with prerequisites

**If startup commands or prerequisites are missing or unclear, STOP.** Do not guess or figure it out yourself. Mark the spec as BLOCKED in the results section with a clear description of what's missing. This sends the issue back to engineering to fix their documentation.

### Start Services

Once documentation is verified and services are confirmed reachable:
1. Start required services if not running (follow documented startup commands)
2. Verify health endpoints respond
3. Seed test data if needed
4. Wait for services to be ready

## Phase 3 — Execute Test Cases

For each test case in the spec:

1. **Execute the steps** exactly as written:
   - API tests: use `curl` or `httpie` via Bash
   - Browser tests: use the Chrome DevTools MCP tools (navigate_page, take_snapshot, click, fill, etc.)
   - CLI tests: run commands via Bash
   - Data verification: query databases directly

2. **Compare actual vs expected**:
   - Record the actual result
   - Determine PASS or FAIL
   - For FAIL: log a clear description of what went wrong

3. **Don't stop on failure** — execute ALL test cases, even if early ones fail

## Phase 4 — Report Results

Append a `## Run Results` section to the spec file:

```markdown
## Run Results

### Run: <date>

| TC | Title | Result | Notes |
|----|-------|--------|-------|
| TC-001 | Test title | PASS | |
| TC-002 | Test title | FAIL | Expected 200, got 500. Error: "connection refused" |
| TC-003 | Test title | SKIP | Prerequisite TC-002 failed |

**Summary**: X passed, Y failed, Z skipped
**Blocking issues**:
- [CRITICAL] TC-002: Service not accessible
- [MAJOR] TC-005: Events delayed >5s
```

## Phase 5 — Document Setup & DX Findings

During test execution, you will encounter configuration issues, missing setup steps, environment requirements, and service quirks. **Document all of these.**

Append a `## Setup & DX Findings` section to the spec file:

```markdown
## Setup & DX Findings

### Environment Issues Encountered
- What didn't work out of the box and what you had to do to fix it

### Missing Setup Steps
- Steps a developer would need that aren't documented

### Recommendations
- What should be automated in a setup script
- What should be documented in a developer getting-started guide
```

## Phase 6 — Document Struggles & Patterns

Append a `## Struggles & Patterns` section to the spec file:

```markdown
## Struggles & Patterns

### Struggles
- Things that took multiple attempts to get working

### Patterns Observed
- Recurring failure types across test cases
- Common root causes
- Areas of the codebase that consistently break
```

### Principles for Run Mode
- **Execute everything** — don't stop at first failure, run all test cases
- **Log failures clearly** — include actual vs expected, error messages, relevant logs
- **Use real services** — this is E2E testing, not mocking
- **Use AskUserQuestion** when blocked — if a service won't start, ask the user for help
- **Be patient with services** — allow startup time, retry health checks
- **Browser testing**: use Chrome DevTools MCP tools for UI verification
