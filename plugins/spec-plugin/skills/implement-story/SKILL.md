---
name: implement-story
description: "Execute a single story end-to-end. Reads the story file, plan architecture, and overall architecture, then implements the story with working code that meets all acceptance criteria. Use after /build-stories has created story files for a plan."
argument-hint: "[story file path, e.g. specs/plan-0-infrastructure/001-python-project-setup.md]"
---

Your task: execute ONE story end-to-end, producing working code that meets all acceptance criteria.

## Phase 1 — Load Context

1. Read the story file at the provided path
2. Determine the plan from the story path (e.g., `specs/plan-0-infrastructure/001-...` -> plan-0)
3. Read the plan architecture doc: `specs/<plan-name>/architecture.md`
4. Read the overall architecture: `specs/architecture.md`
5. Scan existing codebase for patterns, conventions, and what's already built
6. Check if the story file already has an `## Execution Log` section — if so, resume from where it left off
7. **Check prerequisites for design outputs** — if the story lists a prior `/interface-design` story as a prerequisite, read that story's execution log to find the files it produced. These are your starting point for UI work — build on them, don't redesign them

## Phase 2 — Plan Execution

Before writing any code:
1. List every file to create or modify
2. Define the order of operations
3. Identify any ambiguities or blockers
4. If the story is complex (5+ files, multiple layers), present the plan to the user

## Phase 3 — Implement

Write code following existing patterns. Key rules:

### General
- **Read before writing** — understand existing code in any file you'll modify
- **Follow established conventions** — naming, structure, imports, formatting
- **Don't over-engineer** — implement exactly what the story asks, nothing more
- **Write tests alongside code** — see the Testing section below
- **Run verification** after implementation (tests, linters, type checks)

### Integrating Interface-Design Output
When a story follows a `/interface-design` story:
- Read the design story's execution log to find produced files
- Read `.interface-design/system.md` for design tokens and patterns
- **Preserve the visual design** — don't restyle, restructure layouts, or change spacing
- Your job is to wire: data fetching, state management, API calls, routing, event handlers
- If the design output needs structural changes to integrate, make minimal adjustments and note them in the execution log

## Phase 3.5 — Write Tests

Write automated tests alongside the implementation. The goal is **pragmatic coverage** — not 100% unit testing, but confidence that key behaviors work.

### Testing Philosophy
- **Complex logic** (engines, validators, state machines, algorithms): thorough test suite — happy paths, edge cases, error conditions, boundary values
- **Key components** (database layers, providers, API routes): at least one test pass verifying primary behavior works end-to-end
- **Simple glue code** (factories, config loading, re-exports): tested implicitly through other tests, no dedicated tests needed
- **Integration points**: test that components work together correctly

### What to Check in the Story
1. Read the story's `## Testing Guidance` section (if present) for specific test expectations
2. Read the story's acceptance criteria — many can be expressed as test assertions
3. If the story has no testing guidance, use your judgment based on the complexity tiers above

### Run Tests
After writing tests, run them and ensure they all pass. Tests MUST pass before moving to Phase 4.

## Phase 4 — Verify

1. Check every acceptance criterion from the story file
2. Run all tests and verify they pass
3. Run any specified verification steps (builds, linters, type checks)
4. Verify that new code compiles/runs without errors
5. **Integration wiring check** — for components that wire to other layers, verify the wiring works end-to-end — not just that the component exists
6. Report what's done and what's passing

## Phase 5 — Update Story File

Append an `## Execution Log` section to the story file:

```markdown
## Execution Log

### Session: <date>

**Status**: completed | in-progress

**Completed:**
- What was done (with file paths)

**Decisions Made:**
- Any implementation decisions not in the original story

**Issues Encountered:**
- Problems hit and how they were resolved

**Struggled With:**
- Things that took multiple attempts
- Process difficulty that future agents should know about

**Pending:** (only if in-progress)
- What's left to do
```

Then update `specs/<plan-name>/stories.md` — mark the story as `completed` ONLY if ALL acceptance criteria pass. Otherwise mark as `in-progress`. After updating, **re-read stories.md** to verify the change was saved.

## Phase 6 — Document QA Requirements

After completing the story, ensure QA agents can test your work without guessing:

1. **Startup commands** — if the story adds or changes how services are started, update `docs/dev-environment.md` with the exact commands. If the file doesn't exist, create it.
2. **Setup prerequisites** — if new seed scripts, migrations, env vars, or config overrides are needed, document them in the story's execution log under a `**QA Setup**` subsection.
3. **Architecture updates** — if implementation diverged from the architecture doc, update `specs/<plan-name>/architecture.md` with the actual values.

QA agents will be told to refuse testing if setup isn't documented. Don't make them guess.
