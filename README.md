# Spec Plugin

A Claude Code plugin for spec-driven product development. Provides a complete pipeline from ideation to verified, working code — orchestrated by AI agents.

## Pipeline

```
/ideate → /architect → /plan → /orchestrate (per plan)
```

| Skill | Purpose |
|-------|---------|
| `/ideate` | Build a product specification through conversational refinement |
| `/architect` | Create high-level technical architecture for the project |
| `/plan` | Break the spec into ordered execution plans with a roadmap |
| `/orchestrate` | Execute a plan end-to-end with a coordinated agent team |

The orchestrator runs the per-plan pipeline automatically:

```
/architect-plan → /build-stories → /implement-story + /interface-design → /write-test-specs + /run-tests → /run-retrospective
```

## Agents

| Agent | Role |
|-------|------|
| `architect` | Deep-dive plan architecture. No Bash — documents only. |
| `product-owner` | Story breakdown and retrospectives. |
| `engineer` | Story implementation and bug fixes. Test-first for bugs. |
| `designer` | Visual UI creation following the design system. |
| `qa` | Test spec creation and execution. Reports failures, never fixes. |

All agents call `EnterWorktree` as their first action to work on an isolated copy of the repo. A `PostToolUse` hook runs `scripts/setup-worktree.sh` after entry if the file exists in the project — otherwise it silently skips.

## All Skills

| Skill | Description |
|-------|-------------|
| `/ideate` | Product spec through conversation |
| `/architect` | Project-level architecture |
| `/plan` | Spec → execution plans + roadmap |
| `/architect-plan` | Per-plan architecture deep-dive |
| `/build-stories` | Plan → ordered story files |
| `/implement-story` | Execute one story with working code |
| `/fix-bugs` | Fix QA failures with test-first discipline |
| `/write-test-specs` | Create test specifications for a plan |
| `/run-tests` | Execute test specs against running app |
| `/run-retrospective` | Post-plan lessons learned |
| `/orchestrate` | Full plan execution with agent team |

## Worktree Isolation

Agents work in isolated git worktrees to avoid conflicts. The mechanism:

1. **Agent definitions** instruct each agent to call `EnterWorktree` before doing any work
2. **Orchestrate skill** provides worktree names in agent prompts (e.g., `story-010`, `qa-020`)
3. **PostToolUse hook** on `EnterWorktree` runs `scripts/setup-worktree.sh` if it exists in the project (silently skips otherwise)
4. **Setup script** (optional) copies `.env`, `.tool-versions`, and other gitignored files from the main repo

### Customizing the setup script

`scripts/setup-worktree.sh` is a template. Customize it for your project:

```bash
# Add files to copy from main repo
FILES_TO_COPY=(
  ".tool-versions"
  ".env"
  "config.yaml"        # your project config
  "Procfile.dev"       # process manager
)

# Add environment variable checks
ENV_VARS=(
  "DATABASE_URL:Database connection"
  "API_KEY:External API access"
)

# Add service health checks
check_service "Backend (8000)" "http://localhost:8000/api/health"
check_service "Redis (6379)" "redis://localhost:6379"
```

## Specs Directory Convention

All specifications live in `specs/`:

```
specs/
├── <project-name>.md          # Product specification (from /ideate)
├── architecture.md             # Technical architecture (from /architect)
├── roadmap.md                  # Plan sequence and connections (from /plan)
├── plan-0-infrastructure.md    # Plan specs (from /plan)
├── plan-1-extraction.md
├── plan-1.5-source-management.md
├── plan-0-infrastructure/      # Per-plan folders (from /orchestrate)
│   ├── architecture.md         # Plan architecture (from /architect-plan)
│   ├── stories.md              # Story index (from /build-stories)
│   ├── 010-story-slug.md       # Story files
│   └── qa/                     # QA specs (from /write-test-specs)
│       ├── specs.md
│       └── 010-spec-name.md
└── ...
```

## Installation

Add this plugin to your project's `.claude/settings.json`:

```json
{
  "plugins": ["jaisonerick/spec-plugin"]
}
```

Or reference as a local path during development:

```json
{
  "plugins": ["~/code/jaisonerick/spec-plugin"]
}
```

## Optional Dependencies

- **`/interface-design` plugin** — Required for `designer` agent stories. Install separately.
- **Chrome DevTools MCP** — Used by `/run-tests` for browser-based QA.
