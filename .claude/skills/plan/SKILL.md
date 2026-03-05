---
name: plan
description: "Break a product specification into multiple execution plans (plan-N-name.md) and a roadmap. Each plan is a self-contained phase with clear inputs, outputs, and validation gate. Produces files like specs/plan-1-extraction.md and specs/roadmap.md. Use after /ideate and /architect have produced the product spec and architecture."
argument-hint: "[project name, e.g. corpus-graph-builder]"
---

Your task: decompose a product specification into ordered, self-contained execution plans with a roadmap that ties them together.

## Phase 1 — Load Context

1. Read the product spec: `specs/<project-name>.md`
2. Read the architecture: `specs/architecture.md`
3. Check if any `specs/plan-*.md` files already exist
4. If plans exist, ask the user whether to redo or extend

## Phase 2 — Identify Plan Boundaries

Analyze the product spec to find natural plan boundaries. Look for:

- **Pipeline phases** — each phase or group of tightly coupled phases is a candidate plan
- **Dependency chains** — what must exist before something else can start
- **Parallel tracks** — work that can proceed independently (e.g., data processing vs. UI)
- **Validation gates** — natural checkpoints where you can verify correctness before proceeding

### Principles for Plan Decomposition

- **Each plan is self-contained**: clear inputs, clear outputs, independently validatable
- **Plans build on each other**: Plan N's output is Plan N+1's input
- **Infrastructure first**: foundational setup (project scaffolding, providers, database schema, pipeline engine) is always Plan 0
- **Separate tracks when possible**: data processing and UI/platform work can be interleaved as separate tracks (e.g., Plan 1 data, Plan 1.5 UI for Plan 1's data)
- **Don't over-split**: a plan should be substantial enough to deliver value, not just a single component
- **Don't under-split**: a plan that would take weeks of AI agent work should be broken further

### Plan Numbering Convention

- Integer plans (0, 1, 2, 3, 4) for the primary track (usually data/processing)
- Half-integer plans (1.5, 3.5) for secondary tracks (usually UI/platform) that depend on a primary plan's output
- Plan 0 is always infrastructure/scaffolding

## Phase 3 — Consult User

Present the proposed plan breakdown to the user via AskUserQuestion:

- Show the plan sequence as an ASCII diagram (like a roadmap's plan sequence)
- For each plan: name, which spec phases it covers, key inputs/outputs
- Identify the tracks (data vs. platform, or whatever tracks emerge)
- Highlight any judgment calls: "Should X be in Plan 2 or Plan 3?"

Iterate until the user approves the plan structure.

## Phase 4 — Write Plan Specs

For each plan, write `specs/plan-N-name.md` with this structure:

```markdown
# Plan N: Plan Title

> Phase(s) X of the <Project Name>.
> Prerequisite: [Plan N-1 — Title](plan-N-1-name.md).
> Feeds into: [Plan N+1 — Title](plan-N+1-name.md).

## Goal

What the system has at the end of this plan that it didn't have before.
2-3 paragraphs maximum. Be specific about artifacts produced.

## Input

What this plan operates on. List the concrete artifacts, databases,
or services that must exist before this plan starts.

## Process

### Step 1: Step Title

What happens, why, and what it produces. Include enough detail that
an architect can make technology choices and an engineer can implement it.

### Step 2: Step Title

(repeat for each step)

## Output

| Artifact | Location | Description |
|----------|----------|-------------|
| ... | ... | ... |

## Boundaries

**This plan does NOT:**
- (explicit list of what's out of scope — reference which plan handles it)

**This plan DOES:**
- (explicit list of what's in scope)

## Open Questions

- Unresolved decisions for this plan's architecture phase
```

### Writing Principles

- **Each plan must be readable standalone.** A reader shouldn't need to read 3 other plans to understand what this one does.
- **Boundaries are critical.** Explicitly state what this plan does NOT do and which plan handles it. This prevents scope creep during implementation.
- **Steps describe WHAT and WHY, not HOW.** Technology choices belong in the architecture doc, not the plan spec.
- **Open questions are per-plan.** They should be answerable during that plan's architecture phase.

## Phase 5 — Write Roadmap

Write `specs/roadmap.md` with:

1. **Overview** — How the project is organized, what the tracks are
2. **Plan Sequence** — ASCII diagram showing all plans with inputs/outputs
3. **How Plans Connect** — For each plan transition, explain what Plan N produces that Plan N+1 needs. Be specific about artifacts and interfaces.
4. **Validation Gates** — Table with one row per plan, describing what must be true before moving to the next plan
5. **File Organization** — Show the `specs/` directory structure

## Phase 6 — Final Review

Present a summary to the user:
- Total number of plans, organized by track
- The dependency graph between plans
- Any plans that feel risky or uncertain
- Suggested next step: "Run `/orchestrate <plan-name>` to execute each plan in order. The orchestrator will handle per-plan architecture, story breakdown, implementation, and QA."
