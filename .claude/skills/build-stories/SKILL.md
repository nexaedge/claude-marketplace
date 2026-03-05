---
name: build-stories
description: "Break down a single plan into executable story files. Reads the plan spec, overall architecture, plan-specific architecture, and roadmap, then creates ordered .md files — each a self-contained story with clear acceptance criteria and implementation guidance. Use after /architect-plan has produced the plan's architecture document."
argument-hint: "[plan name, e.g. plan-0-infrastructure]"
---

Your task: break a plan into ordered story files, each sized for a single AI agent session.

## Phase 1 — Load Context

1. Read the plan spec: `specs/<plan-name>.md`
2. Read the plan architecture doc: `specs/<plan-name>/architecture.md`
3. Read the overall architecture: `specs/architecture.md`
4. Read the roadmap: `specs/roadmap.md`
5. Scan the existing codebase (Glob for source files, read key files) to understand what's already built
6. Check for any existing stories in `specs/<plan-name>/`

## Phase 2 — Decompose

Break the plan into stories following these principles:

### Sizing for AI Agents (NOT human teams)
- This is NOT production dev — don't think in tiny PRs, feature flags, or team coordination
- **Optimize for AI agent context window**: each story must be completable without overwhelming the executing agent's context
- A story that touches 15 files across 3 layers is **too broad**
- A story that creates one config file is **too narrow**
- Sweet spot: **one cohesive concern** per story

### Good story examples:
- "Set up DB schema + connection layer for X"
- "Build API endpoints for X resource (CRUD + validation)"
- "Design UI for Y page" (interface-design executor)
- "Build UI page for Y with data fetching" (engineer executor, picks up design output)
- "Add processing pipeline for Z with error handling"

### Agent Assignment

Every story must specify its **agent** — the agent type that will execute it. This determines WHO runs the story, not which skill they use (the orchestrator handles skill routing).

- **`engineer`** — Backend work, data layer, API endpoints, integrations, tests, and wiring UI into the codebase (data fetching, state, routing, API calls). Runs `/implement-story`.
- **`designer`** — Visual UI creation: new pages, components, layouts, design system work. Produces polished UI code with craft and consistency. Runs `/interface-design`.

The orchestrator uses this field directly as `subagent_type` when spawning agents. Do NOT use skill names (`/implement-story`, `/interface-design`) — use agent names (`engineer`, `designer`).

#### The Design -> Engineer Pipeline

For features with UI, use **paired stories**:

1. **Design story** (`agent: designer`) — Creates the visual components, pages, or layouts. Outputs working UI code following the design system. Focuses on visual craft: spacing, typography, color, hierarchy, interaction states
2. **Integration story** (`agent: engineer`) — Takes the design output and wires it into the codebase: adds data fetching, state management, API calls, routing, event handlers, tests. References the design story's deliverables as input

Not every UI story needs pairing. Use judgment:
- New page with significant visual design -> paired (design + integrate)
- Adding a data table to an existing page using established patterns -> single engineer story
- Design system initialization or new component library -> design story only
- Backend API with no UI -> engineer story only

### Testing in Stories
Every `/implement-story` story must include testing acceptance criteria proportional to the component's complexity. Reference the plan's architecture doc test strategy to determine the right level:

- **Complex logic** (engines, validators, state machines, algorithms): acceptance criteria should require thorough unit tests
- **Key components** (database layers, providers, API routes): acceptance criteria should require at least one test pass verifying primary behavior
- **Simple glue** (factories, config, wiring): no dedicated test criteria needed
- **Integration stories**: should include at least one integration test
- **Final story in a plan**: should include E2E tests verifying the plan's validation gate

Include a `## Testing Guidance` section in each story specifying: what to test, what level of coverage, and any test fixtures or mocking needed.

### Ordering
- Each story builds on the prior one with minimal rework
- Infrastructure/foundation stories come first
- Data layer before API layer before UI layer
- Design stories come before their paired integration stories
- Each story produces a **working increment** (compiles, passes all tests)

### Self-containment
- Include enough context IN each story that the executing agent doesn't need to read 10 other documents
- Inline the relevant architecture decisions
- Specify exact file paths, patterns, and conventions

## Phase 3 — Write Story Files

Create each story as `specs/<plan-name>/NNN-story-slug.md`:

```markdown
# NNN: Story Title

**Agent**: `engineer` | `designer`

## Summary
One paragraph describing what this story delivers.

## Prerequisites
- What must exist before starting (files, services, prior stories)
- For integration stories: "Design output from story NNN"

## Deliverables
- What exists after completion (new files, endpoints, components)

## Acceptance Criteria
- [ ] Concrete, testable condition 1
- [ ] Concrete, testable condition 2

## Implementation Guidance
Specific files to create/modify, patterns to follow, architecture decisions that apply.

For `/interface-design` stories: describe the visual intent (who uses it, what they accomplish, how it should feel), key UI elements, layout expectations, and interaction states.

For `/implement-story` stories that follow a design story: reference the design story's deliverables as input files. Specify what needs wiring (data fetching, state, API calls, routing).

## Testing Guidance
What to test, at what level, and any fixtures/mocking needed. Reference the plan architecture's test strategy.

## Architecture Context
Inline the relevant decisions so the executor doesn't need to cross-reference.

## References
- Links to relevant architecture sections for deeper context
```

Use mermaid diagrams in stories where they clarify flow or relationships.

## Phase 4 — Create Index

Write `specs/<plan-name>/stories.md`:

```markdown
# <Plan Name> — Stories

## Status
| # | Story | Agent | Status |
|---|-------|-------|--------|
| 001 | Story title | engineer | pending |
| 002 | Design: Page X | designer | pending |
| 003 | Integrate: Page X | engineer | pending |
| ... | ... | ... | ... |

## Dependency Graph
(mermaid diagram showing story dependencies if non-linear)
```
