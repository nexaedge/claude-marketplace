---
name: ideate
description: "Build a comprehensive product specification through conversational refinement. Produces a document like specs/<project>.md — covering problem, data model, pipeline, constraints, and success criteria. Use at the very start of a new project or major initiative."
argument-hint: "[project name or topic, e.g. corpus-graph-builder]"
---

Your task: produce a comprehensive product specification document through iterative conversation with the user.

## Phase 1 — Seed the Vision

Use AskUserQuestion to gather the initial inputs. Start with these, one round at a time (2-3 questions per round max):

**Round 1 — Problem & Domain:**
- What problem are you solving? What's painful about the current state?
- What domain is this in? What kind of data or materials are involved?
- Who is this for? (You, a team, end users?)

**Round 2 — Desired Outcome:**
- What does the end state look like? What exists when this is done?
- What's the core transformation? (raw inputs → what outputs?)
- What's explicitly out of scope? What should this NOT do?

**Round 3 — Scale & Constraints:**
- How much data? How many sources/files/records?
- Local-first or cloud? Real-time or batch? Human-in-the-loop or automated?
- Any technology preferences or constraints?

Adapt questions based on answers — skip what's already clear, dig deeper where it's vague.

## Phase 2 — Draft the Specification

Write a first draft covering these sections (adapt structure to the project):

### Document Structure

1. **Problem** — The pain point, why it matters, what's inadequate about current approaches
2. **What This Is** — One-paragraph description of the system
3. **What This Is NOT** — Explicit boundaries (prevents scope creep and misunderstanding)
4. **Data Model** — The core entities, their properties, and how they relate. Use tables for node/entity types and relationship types. Include direction, meaning, and when each is created
5. **Pipeline / Process** — The processing phases, in order. For each phase: input, process description, output. This is the heart of the spec — be detailed about what each phase does and why
6. **File Formats** — Example files showing the actual artifacts the system produces (with frontmatter, structure, content)
7. **Core Constraints** — Non-negotiable rules the system must always satisfy (e.g., provenance, incrementality, separation of concerns)
8. **Success Criteria** — Numbered list of concrete, verifiable conditions that define "done"
9. **Open Questions** — Unresolved decisions to be made during architecture or implementation

### Writing Principles

- **Concrete over abstract.** Show example files, example queries, example outputs. Don't just say "chunks are extracted" — show what a chunk file looks like.
- **Explicit over implicit.** If a phase doesn't write files, say so. If relationships are directed, specify the direction and what it means.
- **Why over what.** Every design choice should explain its rationale. The reasoning matters more than the choice.
- **Tables for structured data.** Entity types, relationship types, capabilities comparison — use tables, not prose.
- **Workflow diagrams.** Include ASCII or mermaid diagrams showing the pipeline flow end-to-end.

## Phase 3 — Refine Through Conversation

Present the draft to the user section by section (or as a complete document if short). Use AskUserQuestion to refine:

- "Does this data model capture all the entity types you need?"
- "Is this pipeline ordering correct? Should any phases be reordered or split?"
- "Are these constraints too strict or too loose?"
- "What's missing from the success criteria?"

Iterate until the user is satisfied. Expect 2-4 refinement rounds.

## Phase 4 — Write the Spec File

Write the final document to `specs/<project-name>.md`.

Present a summary to the user:
- Core entities and relationships defined
- Number of pipeline phases
- Key constraints
- Open questions that need resolution during architecture
- Suggested next step: "Run `/architect <project-name>` to define the technical architecture."
