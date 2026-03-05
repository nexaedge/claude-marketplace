---
name: architect-plan
description: "Deep-dive architecture for a single plan. Reads the plan spec, overall architecture, roadmap, and related plans, then produces a comprehensive architecture document with specific implementation choices. Use when you need to architect a specific plan before breaking it into stories."
argument-hint: "[plan name, e.g. plan-0-infrastructure]"
---

Your task: produce a comprehensive architecture document for the given plan that makes every important technical decision explicit, with rationale.

## Phase 1 — Load Context

1. Read the target plan spec at `specs/<plan-name>.md`
2. Read the overall architecture: `specs/architecture.md`
3. Read the roadmap: `specs/roadmap.md`
4. Read the product spec (find the main spec in `specs/` that isn't a plan, architecture, or roadmap file)
5. Skim other plan specs (use Glob `specs/plan-*.md`) to understand dependencies and interfaces with the target plan
6. Check if the plan folder already has files: `specs/<plan-name>/`

## Phase 2 — Analyze

Identify all key decisions needed for this plan:
- Technology choices (libraries, frameworks, tools)
- Data flow and data models
- API contracts (endpoints, request/response shapes)
- Component boundaries and responsibilities
- Integration points with other plans
- Error handling strategies
- State management approach
- Performance considerations

For each decision, evaluate trade-offs against the constraints stated in `specs/architecture.md`.

## Phase 3 — Consult User

Use AskUserQuestion for every significant decision point. Present:
- The decision to make
- 2-4 concrete options with trade-offs
- Your recommendation and why

Limit to 2-3 decisions per question round to avoid overwhelming the user. Iterate until all major decisions are resolved.

## Phase 4 — Write Architecture Doc

Write `specs/<plan-name>/architecture.md` with these sections:

### Document Structure
1. **Overview** — What this plan delivers, scope boundaries
2. **Key Decisions** — Each decision with chosen option and rationale
3. **Data Model** — Specific schemas, types, database tables/collections
4. **API Contracts** — Endpoints, request/response shapes, error codes
5. **Component Breakdown** — Each component with responsibility, inputs, outputs
6. **Integration Points** — How this plan connects to prior and future plans
7. **Test Strategy** — Testing approach for this plan (see below)
8. **Flow Diagrams** — Mermaid diagrams for data flows, sequences, component relationships
9. **State Machines** — Mermaid state diagrams for any stateful processes
10. **Constraints & Assumptions** — What we're depending on, what we're deferring

### Test Strategy Section
The test strategy defines how the plan's code will be verified. Be pragmatic — the goal is confidence that key components work, not 100% coverage. Include:

- **Test framework and tools** — e.g., pytest for Python, Vitest for frontend
- **Component test tiers** — classify each component by complexity:
  - **Core/complex logic** (state machines, engines, validators, algorithms): thorough unit tests covering happy paths, edge cases, and error conditions
  - **Key components** (database layers, providers, API routes): at least one test pass verifying primary behavior
  - **Simple glue code** (factories, config loading, re-exports): tested implicitly through integration tests, no dedicated unit tests needed
- **Integration tests** — which components need to be tested working together
- **E2E tests** — full system tests that verify the plan's validation gate criteria
- **Test infrastructure** — fixtures, factories, test databases, mocking strategy for external services

### Diagram Requirements
Use mermaid for ALL diagrams:
- `flowchart` for data flows and component relationships
- `sequenceDiagram` for request/response flows
- `erDiagram` for data models
- `stateDiagram-v2` for state machines
- `classDiagram` for component interfaces (when useful)

## Phase 5 — Final Review

Present a summary to the user covering:
- Scope of what was decided
- Any deferred decisions (and why)
- Key risks or open questions
- Ask for final sign-off before considering the architecture complete
