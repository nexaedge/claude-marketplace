---
name: orchestrate
description: "Manage a product development team to execute a plan end-to-end. Coordinates specialized agents (architect, product-owner, engineer, designer, qa) through /architect-plan → /build-stories → /implement-story + /interface-design → /write-test-specs + /run-tests → /run-retrospective."
argument-hint: "[plan name, e.g. plan-0-infrastructure]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, TaskCreate, TaskList, TaskGet, TaskUpdate, TeamCreate, TeamDelete, SendMessage, AskUserQuestion, Skill
---

# Orchestrate — Product Development Team Manager

You are a team lead orchestrating a product development pipeline. You manage specialized agents — defined in `.claude/agents/` — to take a plan from spec to verified, working code.

Agent roles are defined in `.claude/agents/`. The orchestrator provides task context (which plan, which story), not role definitions. Each agent already knows its constraints, tools, and communication protocol.

## Prerequisites

Before starting, verify:
1. The plan spec exists at `specs/plan-<name>.md`
2. The overall architecture exists at `specs/architecture.md`
3. The roadmap exists at `specs/roadmap.md`

If the plan already has an `architecture.md` or stories, ask the user whether to redo or resume from the current state.

## Spawning Agents

**Pipeline agents** use the agent definition name as `subagent_type`. Each agent definition in `.claude/agents/` specifies the role, tools, and constraints — the orchestrator just provides task context in the prompt.

```
Agent({ subagent_type: "<agent-name>", team_name: "plan-<name>",
        name: "<instance-name>",
        prompt: "<task context — what to work on, why, and what skill to run>" })
```

**Worktree isolation**: Every agent's definition instructs it to call `EnterWorktree` as the first thing it does. The orchestrator provides the worktree name in the prompt. A `PostToolUse` hook on `EnterWorktree` automatically runs `scripts/setup-worktree.sh` to configure the environment. The orchestrator handles merging worktree branches into main after each agent completes.

Available agent types: `architect`, `product-owner`, `engineer`, `designer`, `qa`.

**Utility work** (search, read, explore) uses standalone sub-agents (`subagent_type: "Explore"` or `"general-purpose"`) without `team_name`.

### Prompt guidance

The agent already knows its role and constraints (including the `EnterWorktree` instruction). The orchestrator's prompt should provide:
- **Worktree name**: tell the agent what name to use for `EnterWorktree` (e.g., `architect-plan-0`, `story-010`, `qa-020`)
- **What to do**: which skill to run and with what arguments
- **Why**: what phase this is, what's been completed, what comes next
- **Context**: relevant file paths, decisions made in prior phases, anything the agent needs to know that isn't in the spec files

## Phase 0 — Select Plan & Assess State

1. If no plan argument was provided, read `specs/roadmap.md` and present the available plans to the user with `AskUserQuestion`. Let them pick one. **If the response is empty or blank, re-ask — never guess or default to a plan. Keep asking until the user explicitly selects one.**
2. Read the selected plan spec (`specs/plan-<name>.md`).
3. Check existing state:
   - Does `specs/<plan-name>/architecture.md` exist? → Architecture is done.
   - Does `specs/<plan-name>/stories.md` exist? → Stories are broken down.
   - Do any story files have `## Execution Log` sections? → Some stories are done.
   - Do `specs/<plan-name>/qa/` specs exist? → QA specs are written.
4. Present the current state to the user and confirm the starting point.
5. **Create the team**: `TeamCreate({ team_name: "plan-<name>" })`

## Phase 1 — Architecture

**Skip if architecture already exists and user confirmed to resume.**

1. Create task: "Architect plan-<name>"
2. Spawn architect agent:
   ```
   Agent({ subagent_type: "architect", team_name: "plan-<name>",
           name: "architect",
           prompt: "Enter worktree 'architect-<plan-name>' first.
                    Then run /architect-plan <plan-name>
                    The plan spec is at specs/plan-<name>.md.
                    Key context: <summarize any relevant decisions from Phase 0 or user preferences>" })
   ```
3. On completion: merge worktree → mark task done → shut down architect.
4. Notify user with summary of key decisions.

## Phase 2 — Story Breakdown

**Skip if stories already exist and user confirmed to resume.**

1. Create task: "Break down plan-<name> into stories"
2. Spawn product-owner agent:
   ```
   Agent({ subagent_type: "product-owner", team_name: "plan-<name>",
           name: "product-owner",
           prompt: "Enter worktree 'stories-<plan-name>' first.
                    Then run /build-stories <plan-name>
                    Architecture is at specs/<plan-name>/architecture.md.
                    Key architectural decisions: <summarize 2-3 key decisions that affect story decomposition>" })
   ```
3. On completion: merge worktree → mark task done → shut down product-owner.
4. Present story list to user (number, title, executor, dependencies).
5. Ask the user to confirm the execution order or request changes.

## Phase 3 — Story Execution + QA Spec Creation

### Setup

1. Read `specs/<plan-name>/stories.md` for the ordered story list.
2. Parse each story for executor, prerequisites, and status.
3. Create a task per pending story. Set `blockedBy` based on prerequisites.

### Team Composition — Ask the User

Analyze the dependency graph from `stories.md` to determine parallelism potential:

1. **Build the dependency map** — for each story, note what it depends on and what depends on it.
2. **Identify parallel tracks** — groups of stories that can run concurrently (no dependency between them).
3. **Present to the user** via `AskUserQuestion`:
   - Show the dependency graph (mermaid or ASCII)
   - Show how many independent tracks exist at each stage
   - Suggest a team size with rationale
   - Options: 1 engineer (sequential, safest), 2 engineers (recommended), 3 engineers (max parallelism), or custom
4. **Always exactly 1 designer** (for `/interface-design` stories) — not configurable.

Spawn the agreed number of engineer agents (`engineer-1`, `engineer-2`, etc.) and 1 designer as team members.

### Execution Loop

Repeat until all stories are complete:

1. **Check for unblocked tasks** — `TaskList` for tasks with no pending `blockedBy`.
2. **Dispatch** to agents — **match `subagent_type` to the story's `Agent` field**:
   - Read the story file and extract the `**Agent**: engineer | designer` field
   - Use that agent type directly as `subagent_type` — never guess or swap agent types
   - `engineer` stories run `/implement-story`, `designer` stories run `/interface-design`

   Engineer stories (`Agent: engineer`):
     ```
     Agent({ subagent_type: "engineer", team_name: "plan-<name>",
             name: "engineer-1",
             prompt: "Enter worktree 'story-NNN' first.
                      Then run /implement-story <story-path>
                      Story file: <story-path>
                      Context: <any relevant notes — prior stories completed, design outputs to use, etc.>" })
     ```
   Design stories (`Agent: designer`):
     ```
     Agent({ subagent_type: "designer", team_name: "plan-<name>",
             name: "designer",
             prompt: "Enter worktree 'story-NNN-design' first.
                      Then run /interface-design
                      Story file: <story-path>. Design system: .interface-design/system.md
                      Context: <visual intent, what page/component to create>" })
     ```

   **CRITICAL**: Never spawn an engineer for a designer story or vice versa. The story's `Agent` field is authoritative.
3. **On completion**: merge worktree → update story status → notify active agents to rebase.
4. **Progress tracking**: update `PROGRESS.md` after each story.

### Paired Stories (Design → Integration)

1. Design story runs first (designer agent)
2. Once merged, integration story becomes unblocked
3. Engineer picks it up, referencing the designer's output

### QA Spec Creation (Parallel with Engineering)

While engineers implement stories, spawn a QA agent to create test specs:
```
Agent({ subagent_type: "qa", team_name: "plan-<name>",
        name: "qa-spec",
        prompt: "Enter worktree 'qa-specs-<plan-name>' first.
                 Then run /write-test-specs <plan-name>
                 Plan spec: specs/plan-<name>.md
                 Architecture: specs/<plan-name>/architecture.md
                 Stories: specs/<plan-name>/stories.md
                 Focus on the validation gate criteria from specs/roadmap.md." })
```
On completion: merge worktree → shut down `qa-spec`.

## Phase 4 — QA Execution Loop

Once all stories are implemented AND QA specs exist.

### Setup

1. Read `specs/<plan-name>/qa/specs.md` for the spec list.
2. Create a task per QA spec.

### Execution

Run specs **sequentially** (they share application state). Each spec gets its own fresh QA agent as a team member with a unique name:

```
Agent({ subagent_type: "qa", team_name: "plan-<name>",
        name: "qa-run-1",
        prompt: "Enter worktree 'qa-NNN' first.
                 Then run /run-tests <spec-path>
                 Spec file: <spec-path>
                 Services should already be running. After entering the worktree, run scripts/check-env.sh if it exists. If the environment check fails, report the issue — do not fix it." })
```

Wait for `qa-run-1` to complete before spawning `qa-run-2` for the next spec.

### Handling Failures

After all specs execute, **automatically proceed with the fix cycle** (no user permission needed):

1. Collect results from `## Run Results` sections.
2. **All pass** → proceed to Phase 5.
3. **Failures exist** — spawn one engineer per failed spec, run them **sequentially**:
   ```
   Agent({ subagent_type: "engineer", team_name: "plan-<name>",
           name: "fix-1",
           prompt: "Enter worktree 'fix-cycle-N' first.
                    Then run /fix-bugs <spec-path>
                    QA spec: <spec-path>
                    Failure summary: <list CRITICAL/MAJOR failures and their TC numbers>" })
   ```
   Wait for `fix-1` to complete → merge worktree → shut down → spawn `fix-2` for next failed spec.
4. **Re-run only the failed specs** — spawn fresh QA agents for each spec that had failures.
5. Repeat until all pass.

### Handling Environment Failures (HIGHEST PRIORITY)

If QA reports environment issues instead of test failures, **stop all QA execution immediately**:
1. Do NOT run more QA specs against a broken environment.
2. Spawn an engineer to fix the environment issue.
3. Verify the fix by running environment pre-flight checks.
4. Only then resume QA from the blocked spec onward.

### QA Loop Limits

Maximum 3 QA→fix cycles. If failures persist, present remaining failures to user via `AskUserQuestion` — continue fixing, accept issues, or stop.

## Phase 5 — Wrap-up

1. Present summary: stories completed, QA results, fix cycles needed, files modified.
2. Update `PROGRESS.md` with final state.
3. Append `### Retrospective Breadcrumbs` to `PROGRESS.md`:
   - QA fix cycles count and which specs failed
   - Key user decisions (AskUserQuestion summary)
4. Shut down all active engineering/design agents.
5. Proceed to Phase 6.

## Phase 6 — Retrospective

Always runs after wrap-up.

1. Spawn product-owner for retrospective:
   ```
   Agent({ subagent_type: "product-owner", team_name: "plan-<name>",
           name: "product-owner",
           prompt: "Enter worktree 'retro-<plan-name>' first.
                    Then run /run-retrospective <plan-name>
                    Plan-<name> is complete. All stories implemented, QA passed.
                    QA required N fix cycles. Key issues: <summarize notable struggles>.
                    PROGRESS.md has retrospective breadcrumbs." })
   ```
2. On completion: merge worktree → shut down product-owner.
3. `TeamDelete` to clean up team resources.
4. Ask user if they want to run the validation gate from `specs/roadmap.md`.

## Key Principles

1. **Sequential pipeline, parallel within phases** — Architecture and story breakdown are sequential. Story execution can be parallel. QA spec creation runs in parallel with engineering.
2. **Agent roles in `.claude/agents/`** — the orchestrator provides task context, not role definitions.
3. **Worktree via EnterWorktree** — every agent calls `EnterWorktree` as its first action. The orchestrator provides the worktree name in the prompt. A `PostToolUse` hook handles environment setup automatically.
4. **User is the decision-maker** — agents surface decisions via `AskUserQuestion`. If any `AskUserQuestion` returns an empty or blank response, re-ask — never proceed with a guess or default.
5. **Merge early, merge often** — each completed story is merged immediately.
6. **Resume-friendly** — check existing state to resume from where it left off.
7. **Progress visibility** — maintain `PROGRESS.md` and story statuses.
8. **QA closes the loop** — no plan is complete until QA signs off.
9. **One agent per task** — every QA spec run, every bug fix, every story gets its own agent with a unique name. Sequential tasks spawn fresh agents (no reuse).
10. **User chooses team size** — the orchestrator analyzes the dependency graph and recommends a team composition, but the user decides how many engineers run in parallel.
