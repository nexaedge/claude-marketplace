---
name: fix-bugs
description: "Fix QA-reported failures with test-first discipline. Reads QA spec files for failure details, writes failing tests first, then fixes bugs. Use when QA reports failures that need engineering fixes."
argument-hint: "[QA spec file path, e.g. specs/plan-0-infrastructure/qa/010-service-health.md]"
---

# Fix Bugs — QA Failure Resolution

Your task: fix bugs reported in QA spec files using test-first discipline.

## Phase 1 — Load Context

1. Read the QA spec file(s) at the provided path(s)
2. Find the `## Run Results` section — identify all CRITICAL and MAJOR failures
3. Read the relevant source code for each failure
4. Determine the plan from the spec path (e.g., `specs/plan-0-infrastructure/qa/...` -> plan-0)
5. Read the plan architecture doc: `specs/<plan-name>/architecture.md`

## Phase 2 — Reproduce & Fix (Test-First)

For EACH bug, in order of severity (CRITICAL first):

1. **Write a failing test** — before changing any application code, write a unit or integration test that reproduces the failure. The test MUST fail, proving the bug exists.
2. **Fix the bug** — make the minimal code change to fix the issue.
3. **Verify the test passes** — run the test to confirm the fix works.
4. **Run the full suite** — ensure no regressions.

If a failure description is ambiguous, use AskUserQuestion to clarify expected behavior before writing the test.

## Phase 3 — Verify All Fixes

1. Run the complete test suite
2. For each fixed bug, verify the original QA test case would now pass (re-run the curl/API call if possible)
3. List all fixes applied with file paths

## Phase 4 — Report

Append a `## Fix Log` section to each QA spec file that had failures:

```markdown
## Fix Log

### Fix session: <date>

**Fixed:**
- TC-NNN: <what was wrong and how it was fixed> (test: tests/path/to/test.py)

**Not fixed:**
- TC-NNN: <reason — needs architectural change, unclear requirement, etc.>
```

Commit all changes with message: `fix: resolve QA failures from <spec-name>`
