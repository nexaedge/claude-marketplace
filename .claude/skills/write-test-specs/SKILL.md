---
name: write-test-specs
description: "Create end-to-end test specifications for a plan. Reads the plan spec, stories, architecture, and validation gate to produce test spec files that describe what to verify from the outside of the system. Use after /build-stories has created story files, or in parallel with /implement-story to have specs ready when code is done."
argument-hint: "[plan name, e.g. plan-0-infrastructure]"
---

Your task: produce test spec files that describe what to verify from the *outside* of the system. These specs are written before or during engineering — they don't depend on implementation details.

## Phase 1 — Load Context

1. Read the plan spec: `specs/<plan-name>.md`
2. Read the plan architecture: `specs/<plan-name>/architecture.md`
3. Read the stories index: `specs/<plan-name>/stories.md`
4. Read each story file to understand acceptance criteria and deliverables
5. Read the overall architecture: `specs/architecture.md` (for API contracts, data models)
6. Read the validation gate from `specs/roadmap.md` for this plan

## Phase 2 — Design Test Specs

Think about what a user or operator would verify:

- **API tests**: Can I hit each endpoint and get correct responses? Error cases?
- **Integration tests**: Do the components work together end-to-end?
- **Service health**: Do all services start? Health endpoints work?
- **Data integrity**: Does data flow correctly through the system?
- **UI tests**: Do pages load? Navigation works? Components render with correct data?
- **Edge cases**: What happens with invalid input? Missing services? Network errors?
- **Validation gate**: Every criterion from the roadmap's validation gate must have at least one test

Group tests into logical spec files by functional area.

## Phase 3 — Write Test Spec Files

Create test specs at `specs/<plan-name>/qa/NNN-spec-name.md`:

```markdown
# QA Spec NNN: Spec Title

**Area**: API | Integration | UI | Health | Data Integrity
**Prerequisites**: What must be running (services, databases, seed data)

## Setup
Steps to prepare the environment before running tests.

## Test Cases

### TC-001: Test case title
**Steps**:
1. Concrete action (e.g., "POST /api/workflows with body: {...}")
2. Next action
3. Verify response

**Expected**: What should happen (status code, response body, side effect)
**Severity**: critical | major | minor

### TC-002: ...
```

Write a spec index at `specs/<plan-name>/qa/specs.md`:

```markdown
# QA Specs — <Plan Name>

| # | Spec | Area | Test Cases | Status |
|---|------|------|-----------|--------|
| 010 | Service Health | Health | 5 | pending |
| 020 | Workflow API | API | 8 | pending |
```

### Principles for Spec Mode
- **Test behavior, not implementation** — don't test internal function calls, test what the user sees
- **Concrete, not vague** — every test case has exact inputs and expected outputs
- **Include the validation gate** — every criterion from the roadmap must map to a test case
- **Severity matters** — critical = blocks release, major = degraded experience, minor = cosmetic
- **Use AskUserQuestion** when scope is unclear — what should be tested vs. out of scope?
