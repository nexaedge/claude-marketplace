# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project maintains two independent versions:
- **Marketplace** (`metadata.version` in `.claude-plugin/marketplace.json`)
- **Plugin: spec-plugin** (`version` in `plugins/spec-plugin/.claude-plugin/plugin.json`)

## [Plugin: spec-plugin v3.1.0] - 2025-03-16

### Changed
- Agent worktree lifecycle: agents now commit, merge to main, and clean up worktrees before reporting back to the team lead
- All 5 agents enforce commit-merge-cleanup flow before SendMessage

## [Plugin: spec-plugin v3.0.0] - 2025-03-10

### Added
- Context-aware project type detection (code repo, document workspace, empty directory, nested project)
- Skills adapt behavior based on workspace context
- Project Context section in specs captures workspace details for downstream skills

### Changed
- All skills now read workspace context before executing

## [Plugin: spec-plugin v2.0.0] - 2025-03-05

### Changed
- Refactored to version-based execution pipeline
- Evolutionary delivery: projects broken into versions, each with its own architecture, stories, and validation
- Pipeline flow: /ideate → /architect → /plan → /orchestrate

## [Plugin: spec-plugin v1.0.0] - 2025-03-05

### Added
- Initial plugin with spec-driven development pipeline
- 5 agents: architect, product-owner, engineer, designer, qa
- 9 skills: ideate, architect, plan, architect-version, build-stories, execute-task, validate-execution, run-retrospective, orchestrate
- QA commit guard hook
- Worktree isolation for all agents

## [Marketplace v1.0.0] - 2025-03-18

### Added
- Initial marketplace structure with spec-plugin as the first plugin
- Separated marketplace versioning from plugin versioning
- CLAUDE.md with development conventions
