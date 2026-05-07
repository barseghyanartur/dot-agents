---
name: repo-bootstrap
description: Bootstrap repository governance by creating AGENTS.md and a standard set of SKILL.md files.
---

# Repository bootstrap (AUTHORITATIVE)

This skill bootstraps **agent-operable governance** for a repository.

When invoked, it creates:
- a clean, authoritative `AGENTS.md`
- a structured set of `SKILL.md` files, each with a single responsibility

You must follow the phases below in order.
You must not invent project details.

---

## Scope

This skill is concerned **only** with governance files:

- `AGENTS.md`
- `.agents/skills/**/SKILL.md`

It must not modify source code, configuration, or dependencies.

---

## Additive behavior (MANDATORY)

This skill MUST behave additively.

If a required governance file or skill directory already exists,
you MUST NOT regenerate, overwrite, or modify it.

Instead:

- Detect that the file or directory exists
- Skip it without changes
- Continue creating only the missing governance artifacts

Existing `AGENTS.md` and existing `SKILL.md` files are authoritative
and must be preserved exactly.

---

## Phase 1 — Initial scan (READ-ONLY)

Before creating any files, perform a read-only scan of the repository.

Look for **facts that are already true**, including:

- Primary language(s)
- Build or task runners (`make`, `npm`, `uv`, etc.)
- Test runners
- Linters / formatters (by config presence, not assumption)
- Configuration systems (settings files, env usage)
- Obvious generated or vendored directories
- CI hints (if present)

Read, if they exist:
- `README`
- build config files
- dependency manifests

### Runtime invocation detection (MANDATORY for Python projects)

If the project is Python-based, you MUST determine the canonical way to invoke
tools before writing any SKILL.md files. Do this by reading `Makefile` and
`pyproject.toml`:

1. **Locate the test target** — find the `test:` target (or equivalent) in the
   Makefile. Extract the exact command used to run tests (e.g. `uv run pytest`,
   `poetry run pytest`, `python -m pytest`, `pytest`).

2. **Identify the runtime prefix** — check whether `uv run`, `poetry run`,
   a virtualenv activation pattern, or bare calls are used across Makefile targets
   for lint, test, and build. Count occurrences: if the majority of tool
   invocations use a prefix (e.g. `uv run`), that prefix is mandatory.

3. **Detect pre-commit configuration** — check whether `.pre-commit-config.yaml`
   exists at the repository root.

4. **Record these facts** for use in Phase 3:
   - `TEST_COMMAND`: exact command from the test target
   - `RUNTIME_PREFIX`: prefix required before tool names (or "none" if bare calls)
   - `RUNTIME_MANAGER`: `uv`, `poetry`, `pip`, `virtualenv`, or other
   - `PRE_COMMIT_CONFIGURED`: `true` if `.pre-commit-config.yaml` exists, else `false`

If a fact is not clearly observable, treat it as unknown and omit it.

Do **not** infer:
- deployment targets
- cloud providers
- runtime architecture
- business rules

---

## Phase 2 — Create AGENTS.md (FACTS ONLY)

Create `AGENTS.md` at the repository root.

### Purpose of AGENTS.md

`AGENTS.md` defines:
- truths about the repository
- hard constraints
- known intentional behaviors
- non-negotiable agent obligations

It must **not** define workflows or procedures.

### Required structure

Create `AGENTS.md` with these sections, in this order:

```markdown
# AGENTS.md — <Project Name>

## Project overview

## Architecture invariants

## Repository layout (authoritative)

## Hard constraints

## Known intentional behaviors — do not change

## Configuration authority

## Mandatory workflow (every task, non-negotiable)

## Skills index

## Agent obligations
```

### Content rules

- Populate sections using only observed facts
- If a section cannot be populated, include it with an explicit note
  (for example: “No known intentional behaviors identified at bootstrap time.”)
- Do not include step-by-step instructions in any section OTHER than
  `## Mandatory workflow` — that section is explicitly procedural by design

### Mandatory workflow section (CRITICAL — inline in AGENTS.md)

This is the most important section. Skills are separate files that agents must
proactively read — they are often skipped. The mandatory workflow must be
**inline in AGENTS.md** so it is always seen on first read.

Populate it using `TEST_COMMAND`, `RUNTIME_PREFIX`, and `RUNTIME_MANAGER`
detected in Phase 1. Use real commands, not placeholders.

Template (adapt to actual detected commands):

```markdown
## Mandatory workflow (every task, non-negotiable)

**Step 0 — Test decision:** Before writing any code, decide: does this task
change behaviour, add API surface, or touch edge cases? If yes, write or update
tests first (or alongside). Never skip this decision.

- **Bug fix sub-rule:** Write a regression test that reproduces the bug first.
  Run it — it must fail. Fix the bug. Confirm the test now passes.
- **Test types:** When writing tests, cover three types: (1) unit test for the
  specific component, (2) integration test verifying system-level behaviour,
  (3) happy-path test confirming no regression in the existing working flow.

**Step 1 — Lint:** <lint command(s) from Makefile or detected linter>

**Step 2 — Fix lint errors, then repeat Step 1.**

**Step 3 — Test:** <TEST_COMMAND from Phase 1>
<if single-file variant exists, show it here>

**Step 4 — Fix failures, then repeat Step 3.**

**Step 5 — Run lint once more** to catch regressions introduced by fixes.

Maximum 3 lint → test iterations. After 3, stop and report.

**Step 6 — Documentation gate:** If you changed public API, CLI flags, or
default limits, run the `update-documentation` skill. It scans code vs docs
and auto-fixes misalignments.

**Step 7 — Pre-commit gate:**
<If PRE_COMMIT_CONFIGURED is true:>
```
pre-commit run --all-files
```
<If PRE_COMMIT_CONFIGURED is false:>
Run all lint commands individually (as in Step 1) to serve as the final gate.

<If RUNTIME_PREFIX is set, add:>
**Runtime rule — ALWAYS use `<RUNTIME_PREFIX>`.** Never call `python`,
`python3`, or any project tool directly — they will resolve to the wrong
Python or missing dependencies. Every tool invocation must use `<RUNTIME_PREFIX>`.
```

Rules:
- Use the exact `TEST_COMMAND` extracted from Phase 1 (e.g. `uv run pytest -vrx -s`)
- If a `make` wrapper exists, show both: `make test    # uv run pytest -vrx -s`
- If `RUNTIME_PREFIX` is set, the runtime rule paragraph is MANDATORY
- If `RUNTIME_PREFIX` is “none”, omit the runtime rule paragraph
- If `PRE_COMMIT_CONFIGURED` is true, Step 7 uses `pre-commit run --all-files`
- If `PRE_COMMIT_CONFIGURED` is false, Step 7 re-runs all detected lint commands

### Skills index section

After creating all SKILL.md files in Phase 3, populate `## Skills index` in
`AGENTS.md`. Its purpose is to point to detailed skill files — not to replace
the mandatory workflow which is already inline above.

Format:

```markdown
## Skills index

Detailed skill files live in `.agents/skills/<name>/SKILL.md`. Read the
relevant file for full guidance:

| Skill | When to read |
|-------|--------------|
| `dev-setup` | Environment setup or dependency troubleshooting |
| `dev-workflow` | Full Definition of Done and retry logic |
| `coding-standards` | Style, typing, and naming rules |
| `pr-review` | Pull request review checklist |
| `update-documentation` | API, CLI, or behaviour changes |
```

Rules for populating the table:
- Include only skills that were actually created in Phase 3
- Add any project-specific skills beyond the standard set

---

## Phase 3 — Create SKILL.md files (PROCEDURES ONLY)

Create the following directories and files:

```text
.agents/skills/
├── dev-setup/
│   └── SKILL.md
├── dev-workflow/
│   └── SKILL.md
├── coding-standards/
│   └── SKILL.md
├── pr-review/
│   └── SKILL.md
├── update-documentation/
│   └── SKILL.md
```

Each SKILL.md must be valid, self-contained, and have a single responsibility.

### Required SKILL.md header (MANDATORY)

Every SKILL.md file you create MUST start with a YAML frontmatter header
in the following exact format:

```yaml
---
name: <skill-name>
description: <concise description of the skill’s purpose>
---
```

---

### dev-setup/SKILL.md

Focus:
- environment setup
- dependency installation
- recovery steps for common environment failures

Include:
- canonical install or sync commands *if observable*
- fallback or repair instructions
- **Tool invocation rules derived from Phase 1 runtime detection (MANDATORY)**

#### Tool Invocation Rules section (derived from Phase 1 scan)

The **first section** of `dev-setup/SKILL.md` MUST be a “Tool Invocation Rules”
section. Its content depends on what Phase 1 detected:

**If `RUNTIME_PREFIX` = `uv run` (Makefile uses `uv run` pervasively):**

Write a section titled `## Tool Invocation Rules (MANDATORY)` that:
1. States: “Always prefix tool invocations with `uv run`.”
2. Shows the canonical test command (exact `TEST_COMMAND` from Phase 1).
3. Shows examples for each linter/formatter observed in the Makefile.
4. Lists explicitly **forbidden** bare invocations: `python`, `python3`, and
   every tool that the Makefile invokes via `uv run` (e.g. `pytest`, `ruff`,
   `doc8`). These are forbidden because bare calls use the wrong Python version
   or missing dependencies — `uv run` resolves both automatically.

**If `RUNTIME_PREFIX` = `poetry run`:**

Write the same section adapted to `poetry run`. List the same forbidden bare
invocations.

**If `RUNTIME_PREFIX` = “none” (bare calls, virtualenv assumed active):**

Write a section titled `## Tool Invocation Rules` that:
1. States the virtualenv must be activated before any tool is called.
2. Shows the activation command if detectable.
3. Shows the canonical test command from Phase 1.

**If runtime is ambiguous:**

Omit the forbidden list. Document only what was directly observed.

This section must appear **before** any setup steps so it cannot be missed.

Exclude:
- coding rules
- lint/test loops
- PR review logic

---

### dev-workflow/SKILL.md

This file defines the **Definition of Done**. It is non-negotiable: every task
MUST follow it completely. No step may be skipped for any reason.

It must include:

#### 1. TDD assessment (REQUIRED, runs before any code change)

Every task starts with a test decision. Include this as the first step:

> **Step 0 — Test decision**: Before writing any code, decide:
> - Does this task change or add public API, behavior, or edge cases?
> - If yes, write or update tests first (or alongside the implementation).
> - If no, justify explicitly why no new tests are needed.
>
> **Bug fix sub-rule:** Write a regression test that reproduces the bug before
> implementing the fix. Run it — it must fail. Then fix the bug and confirm the
> test passes.
>
> **Test types:** When writing tests, cover all three:
> 1. Unit test — targets the specific function or class being changed
> 2. Integration test — verifies system-level behaviour end-to-end
> 3. Happy-path test — confirms the existing working flow has not regressed
>
> Never declare a task complete without having made this decision consciously.

#### 2. Mandatory sequence (NON-SKIPPABLE)

State explicitly that this sequence is **mandatory for every task without
exception**. No task is “too small” or “too obvious” to skip it.

Include:
- an explicit Definition of Done (must list: lint passes, tests pass,
  documentation updated if API changed, pre-commit gate passes)
- a mandatory lint → fix → test sequence
- a documentation gate step: if public API, CLI flags, or defaults changed,
  run the `update-documentation` skill
- a pre-commit gate as the final step:
  - if `PRE_COMMIT_CONFIGURED` is true: `pre-commit run --all-files`
  - if `PRE_COMMIT_CONFIGURED` is false: re-run all detected lint commands
- retry logic with a finite limit (default: 3 iterations)
- explicit stop conditions
- forbidden actions

#### 3. Runtime-aware commands

Use `TEST_COMMAND` and `RUNTIME_PREFIX` from Phase 1 to write the exact commands
in the mandatory sequence. Do not write placeholder commands.

If `RUNTIME_PREFIX` is set (e.g. `uv run`), each command in the sequence MUST
either use a `make` target OR show the direct prefixed equivalent inline as a
comment (e.g. `make test  # = uv run pytest -vrx -s`).

Add a “Runtime Rule” note at the top of the sequence stating the prefix
requirement. Add to Forbidden Actions: “Never call tools without the required
runtime prefix.”

#### 4. Forbidden actions (REQUIRED)

Always include at minimum:
- Never skip tests to complete a task
- Never bypass linting to complete a task
- Never modify test assertions to make tests pass
- Never change code to match documentation (update docs instead)
- Never call tools without the required runtime prefix (if one is detected)
- Never skip Step 0 — always make a conscious test decision before coding
- Never declare done without running the pre-commit gate (final step)

This is the skill that enforces:
“assess test needs first, run tests, fix linting errors, run tests again,
only then finish — for every task, every time”.

---

### coding-standards/SKILL.md

Focus:
- style rules
- typing rules
- naming conventions
- logging conventions
- error-handling philosophy

Include:
- what is required
- what is prohibited
- how rules are enforced

Exclude:
- commands to run tools
- procedural workflows

---

### pr-review/SKILL.md

Focus:
- deterministic pull-request review behavior

Include:
- a numbered checklist
- explicit “must check” items
- clear reporting expectations

Exclude:
- implementation guidance
- development workflow details

---

### update-documentation/SKILL.md

This single skill responsibilities for:
- Documentation policy (precision: scope, authority, exclusions)
- Updating documentation (behavior: scan, compare, auto-fix, report)

It MUST be comprehensive and explicit.

Focus:
- define documentation authority and scope for this repository
- keep documentation aligned with code and policy
- auto-fix safe misalignments (agent edits docs directly)

Include ALL of the following sections (do not omit):

1. Operation mode
   - Explicitly state: pure agent-based synchronization
   - Explicitly state: no scripts are used
   - Explicitly state: docs are updated to match code; code is never changed to match docs

2. Ground truth and authority hierarchy
   - Code is ground truth for API, CLI, defaults, exceptions, configuration behavior
   - AGENTS.md and SKILL.md are policy and must match reality
   - README/docs are derived and must match code and policy
   - Explicit exclusions: auto-generated/vendored docs are not modified

3. Agent-based sync process (step-by-step)
   - Step 1: Extract ground truth from code (public API, CLI, exceptions, defaults, env vars, config)
   - Step 2: Scan documentation files (README, AGENTS.md, SKILL.md, docs/)
   - Step 3: Identify misalignments (missing items, outdated references, broken paths, stale defaults, wrong examples)
   - Step 4: Auto-fix documentation safely (tables, examples, references, sections; never invent behavior)
   - Step 5: Report changes (files changed, what changed, what could not be fixed, why)

4. Documentation files overview and targeting rules
   - Identify which documentation files exist in THIS repository (by scan)
   - For each, state what it is responsible for (end users vs contributors vs agents)
   - Provide “When to update each file” guidance for each discovered doc (README, AGENTS.md, docs/, CONTRIBUTING, SECURITY, etc.)
   - If a file does not exist, do not mention it

5. Feature-specific documentation checklist
   - Adding an exception: where to document, which tables/examples to update
   - Adding CLI commands/options: where to document and examples to add/update
   - Adding/changing public API: where to document and how to update examples
   - Changing defaults/limits: where to update and how to ensure consistency

6. Code example rules (documentation-as-tests)
   - If Markdown examples are intended to be runnable tests, enforce naming conventions
   - Preserve any repository-specific codeblock chaining conventions if present
   - Do not introduce pseudo-code examples where runnable examples are expected

7. Validation checklist (before reporting completion)
   - README examples match actual API/CLI
   - AGENTS.md matches architecture and workflows
   - SKILL.md descriptions remain accurate
   - Cross-references and file paths are valid
   - No generated docs were modified
   - Any documentation tests required by the repository are respected

8. What NOT to do
   - Do not modify source code to match docs
   - Do not weaken policy encoded in SKILL.md or AGENTS.md
   - Do not silently delete content; preserve intent while correcting facts
   - Do not reformat docs unnecessarily; minimize diffs

Exclude:
- any dependency changes
- any source code modifications
- any “fix by changing code to match docs” behavior

The output of this skill is documentation edits plus a clear change report.

---

## Phase 4 — Conservative defaults

If the repository does not clearly specify something:

- use minimal, conservative language
- prefer “must”, “must not”, or “when present”
- avoid naming specific tools unless confirmed

Never guess.

---

## Global prohibitions

You must never:

- invent architecture or domain rules
- infer workflows not supported by evidence
- merge procedural logic into AGENTS.md
- modify existing source code
- add dependencies
- claim the repository is “ready” beyond governance structure

---

## Completion report (REQUIRED)

After finishing, report:

- the full list of files created (with paths)
- which sections were intentionally left minimal
- any facts that were explicitly treated as unknown
- suggested follow-ups for project maintainers
