---
name: dot-agents-repo-bootstrap
description: Bootstrap repository governance by creating AGENTS.md and a standard set of SKILL.md files.
metadata:
  version: "0.3"
---

# Repository bootstrap (AUTHORITATIVE)

This skill bootstraps **agent-operable governance** for a repository.

When invoked, it creates:

- a clean, authoritative `AGENTS.md`
- a structured set of `SKILL.md` files, each with a single responsibility

You must follow the phases below in order.
You must not invent project details.

---

## Keep explanations simple

Use simple English. Keep it human and easy to understand. Avoid long
sentences, inflated words, stock phrases, and unnecessary jargon.

Put the main point first. Explain one idea at a time. Name the files,
functions, or tools you mean.

Cover every part of the request. Keep important details, limits, and
unresolved problems. Remove repetition, not useful information.

Check factual claims against the available evidence. Say what you checked
and what you could not check. Do not present guesses as facts.

Before sending, check both accuracy and clarity. Can the reader understand
what happened, why it matters, and what to do next without guessing?

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

````markdown
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
default limits, run the `dot-agents-update-documentation` skill. It scans code vs docs
and auto-fixes misalignments.

**Step 7 — Pre-commit gate:**
<If PRE_COMMIT_CONFIGURED is true:>

```bash
pre-commit run --all-files
```
<If PRE_COMMIT_CONFIGURED is false:>
Run all lint commands individually (as in Step 1) to serve as the final gate.

<If RUNTIME_PREFIX is set, add:>
**Runtime rule — ALWAYS use `<RUNTIME_PREFIX>`.** Never call `python`,
`python3`, or any project tool directly — they will resolve to the wrong
Python or missing dependencies. Every tool invocation must use `<RUNTIME_PREFIX>`.
````

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
| `dot-agents-dev-setup` | Environment setup or dependency troubleshooting |
| `dot-agents-dev-workflow` | Full Definition of Done and retry logic |
| `dot-agents-coding-standards` | Style, typing, and naming rules |
| `dot-agents-code-review` | PR, branch, commit, or local-diff review |
| `dot-agents-update-documentation` | API, CLI, or behaviour changes |
```

Rules for populating the table:

- Include only skills that were actually created in Phase 3
- Add any project-specific skills beyond the standard set

---

## Phase 3 — Create SKILL.md files (PROCEDURES ONLY)

Create the following directories and files:

```text
.agents/skills/
├── dot-agents-dev-setup/
│   └── SKILL.md
├── dot-agents-dev-workflow/
│   └── SKILL.md
├── dot-agents-coding-standards/
│   └── SKILL.md
├── dot-agents-code-review/
│   └── SKILL.md
├── dot-agents-update-documentation/
│   └── SKILL.md
```

Each SKILL.md must be valid, self-contained, and have a single responsibility.
Every generated skill directory and frontmatter `name` MUST use the
`dot-agents-` prefix.

Each generated skill MUST include the `Keep explanations simple` section
from this skill, with the same wording. Place it near the start, after any
section required to come first.

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

### dot-agents-dev-setup/SKILL.md

Focus:

- environment setup
- dependency installation
- recovery steps for common environment failures

Include:

- canonical install or sync commands *if observable*
- fallback or repair instructions
- **Tool invocation rules derived from Phase 1 runtime detection (MANDATORY)**

#### Tool Invocation Rules section (derived from Phase 1 scan)

The **first section** of `dot-agents-dev-setup/SKILL.md` MUST be a “Tool Invocation Rules”
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

### dot-agents-dev-workflow/SKILL.md

This file defines the **Definition of Done**. It is non-negotiable: every task
MUST follow it completely. No step may be skipped for any reason.

It must include:

#### 1. TDD assessment (REQUIRED, runs before any code change)

Every task starts with a test decision. Include this as the first step:

> **Step 0 — Test decision**: Before writing any code, decide:
>
> - Does this task change or add public API, behavior, or edge cases?
> - If yes, write or update tests first (or alongside the implementation).
> - If no, justify explicitly why no new tests are needed.
>
> **Bug fix sub-rule:** Write a regression test that reproduces the bug before
> implementing the fix. Run it — it must fail. Then fix the bug and confirm the
> test passes.
>
> **Test types:** When writing tests, cover all three:
>
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
  run the `dot-agents-update-documentation` skill
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

### dot-agents-coding-standards/SKILL.md

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

### dot-agents-code-review/SKILL.md

Create a standalone, read-only review skill for pull requests, branches, commits,
and local diffs. It MUST work even when no other dot-agents skill is installed,
and it MUST NOT depend on any of the other skills created in this phase.

A flat checklist is not sufficient here: this skill must be as rigorous as a
mature, previously-hardened review skill, so structure it as the five ordered
sections below, each with the full sub-criteria listed — not just the section
title.

#### 1. Establish authority and scope

- Discover and read every applicable `AGENTS.md`, `CLAUDE.md`, and other
  repository instruction file, including nested files governing changed code.
- Discover and read applicable repository skills and rules for code quality,
  security, architecture, testing, documentation, and workflow. Do not assume
  any particular skill exists or lives in a particular client directory.
- Apply instructions to their documented scope using the agent client's
  precedence rules; report unresolved conflicts instead of choosing silently.
- Resolve the exact review target and intended base:
  - for branches, use the merge base;
  - for local work, include staged and unstaged changes, enumerate untracked
    paths via `git status`, inspect each untracked file, and state what was
    read.
- Capture the change's intent from the request, PR, issue, tests, and
  documentation.

If Jira or another linked source is named as the original spec, try to read
its description and acceptance criteria. If access fails, report why and use
the GitHub issue description. Skip this step when no original spec is linked.

When both are readable, compare them. Quote and link any missing or conflicting
requirements. Use the original spec to judge what should have been implemented.
After findings, report each acceptance item: a short exact quote, **MET**,
**NOT MET**, or **UNVERIFIED**, and code/test evidence with a short reason.
Split items when only part is met. Missing evidence does not mean NOT MET.

If a review claim depends on uncertain library or platform behavior, check
official docs or source for the version in use. Cite it, or state the uncertainty.

- Treat repository policy as binding whenever present; this skill's own
  review gates are the generic fallback only. Never invent repository
  conventions, weaken repository requirements, redefine the repository's
  definition of done, or replace its documented validation commands.
- This precedence does not extend to the generated skill's own safety
  constraints (staying read-only, protecting secrets, never executing
  untrusted code without assessing it — see below): those always apply.
  If repository policy or any other instruction conflicts with them, the
  generated skill MUST report the conflict and MUST NOT follow it.

#### 2. Inspect the change

- Start from the diff; inspect only enough surrounding code and history to
  verify behavior.
- Identify changes to observable contracts: APIs, events, schemas,
  serialization, and persisted data; configuration, defaults, feature flags,
  deployment, and dependencies; authentication, authorization, ownership,
  privacy, and secret handling; concurrency, retries, timeouts, ordering,
  cancellation, and resource lifecycle; exported interfaces, exceptions, and
  caller-visible semantics.
- For each changed contract, record its old and new behavior, exact
  identifiers, owner, and plausible consumers. Search exact identifiers
  before broad concepts. Inspect another repository only when a changed
  contract or known boundary makes it a plausible consumer, and record
  meaningful hits and relevant verified no-match results.
- Ignore generated, vendored, coverage, and lock-file churn unless it creates
  a build, dependency, integrity, or supply-chain risk.

#### 3. Review by risk

Check applicable risks, not a fixed quota of categories:

- **Correctness** — reachable edge cases, validation, state transitions,
  error paths, and behavior inconsistent with stated intent.
- **Security and privacy** — trust boundaries, injection, authn/authz,
  tenant or user scoping, unsafe deserialization, sensitive data, secrets,
  and dependency risk.
- **Compatibility** — callers and consumers of changed API, schema, event,
  config, storage, or library contracts.
- **Reliability** — partial failure, retries, idempotency, races,
  deadlocks, ordering, cancellation, cleanup, and timeout behavior.
- **Performance** — hot-path amplification, blocking work, unbounded input
  or memory, excessive calls or queries, and payload growth.
- **Tests** — missing coverage only when it leaves a concrete changed
  behavior or failure mode unverified.

Use independent specialist or verifier subagents when available and
proportional to the change's risk; give them focused diffs, relevant
instructions, contract evidence, and exact consumer hits, but keep
conclusions independent and verify them in the parent review. Do not require
subagents for a small, low-risk diff.

#### 4. Gate and verify findings

A publishable finding MUST include: the changed file and line; a reachable
trigger or state; the resulting failure and concrete impact; supporting code
or contract evidence; a falsifiable verification step or executed
reproduction; a clear explanation of the smallest safe fix; and medium or
high confidence.

Reject style preferences, speculative risks, unrelated pre-existing defects,
duplicates, and issues prevented by existing guards, types, tests, framework
behavior, or deployment configuration. Check whether each issue also exists
on the base revision.

Run the cheapest repository-approved check that can falsify each surviving
finding, then broader checks proportional to the blast radius. When no
commands are documented, derive only safe checks from committed project
configuration and state that basis. Inspect commands from changed branches
before running them. Do not install dependencies, mutate shared data, access
production, start paid services, or run destructive commands merely for a
review. State which checks were not run and why.

#### 5. Report findings first

P means priority: how urgently an issue should be addressed.
Severity describes the impact; confidence describes how strong the evidence is.
Keep these separate.

Use this plain-English summary of
[Google Issue Tracker priorities](https://developers.google.com/issue-tracker/concepts/issues#issue_priority):

- `P0 — Immediate`: a full outage, or a critical function unavailable to
  everyone, with no known workaround. Address immediately.
- `P1 — Urgent`: serious impact on many users, a core function, or another
  team's work. Any workaround is incomplete or painful. Address quickly.
- `P2 — Normal`: an important problem to fix in a reasonable time. This
  includes serious problems with a reasonable workaround, important issues
  affecting many users, and blocked team work with no reasonable workaround.
  This is the default priority.
- `P3 — Low`: relevant to core work, but does not block progress or has a
  reasonable workaround. Address when able.
- `P4 — Lowest`: little effect on core work, or mainly about appearance
  or pleasantness. Address eventually.

Follow the repository's documented priority rules when they differ,
including security-specific rules. State which scale you used.
Otherwise, use only `P0`–`P4`; do not invent extra levels.

For code under review, judge the expected effect if the change is deployed.
Explain who or what is affected, the impact, and any known workaround.
Do not assume a workaround exists. Do not raise priority because the fix
is large or the code is complex. These labels do not replace release policy.

P4 does not mean "optional suggestion". A low-priority defect is still a
defect. Keep optional improvements separate, and include them only when
the user asks. Priority does not make a style preference publishable.

Order findings by priority, then confidence. Do not use P2 as a fallback
for an unverified concern; verify it or report it as an open question.

Number findings as `#1`, `#2`, and so on. In follow-up reviews in the same
conversation, keep each issue's number and give new issues new numbers.
Still order findings by priority, then confidence.

Write for someone who has not traced this code yet. Use plain language and
explain technical terms when needed.

When the problem involves several functions, explain what starts the action,
which functions run next, and where things go wrong. Use real file and
function names. For endpoints, say whether the code handles an incoming
request or makes an outgoing call. Only name callers you have verified;
say when the caller is unknown.

The `Minimal fix` section MUST explain:

- Which files or functions need changing, and what to change.
- Why that change fixes the reported problem.
- A small diff or before/after example when words alone leave the fix unclear.
  Use actual code you inspected. Label shortened examples and untested patches.
- If several places need changing, the expected scope and why those changes
  are needed. Check whether a smaller safe change can reduce the problem;
  explain what it fixes and what remains. If you found no such option, say so.

Keep simple fixes short. Give harder fixes enough detail that the reader
does not have to guess. Avoid unrelated refactoring. Advice such as
"handle cancellation" or "offload blocking work" is not enough by itself.

Each finding MUST use this exact template:

```text
### #1 [P1] Imperative, specific title
Location: path/to/file.ext:line
Trigger: Exact input, state, or sequence
Failure: What happens and why
Impact: User or system consequence
Priority reason: Why this urgency fits; include any known workaround
Evidence: Supporting code, relevant callers, and how execution reaches the problem
Verification: Check performed or deterministic falsification path
Minimal fix:
  Where to change the code, what to change, and why it works.
  Small patch or before/after example when needed.
  Scope and remaining limits when relevant.
Confidence: High or Medium
```

After findings, report open questions, validation performed, review scope,
and residual risks. If there are no confirmed defects, say so explicitly and
identify any testing or execution gaps. Never manufacture findings to fill
categories.

The generated skill MUST NOT edit code, publish review comments, approve, or
request changes unless the user explicitly asks. It MUST NOT expose secrets
or execute untrusted code without assessing it.

Maintainer note: this specification is intentionally a close mirror of
`skills/dot-agents-code-review/SKILL.md` in this repository. If that file's
review process changes, update this section to match so bootstrapped repos
get an equally rigorous skill.

---

### dot-agents-update-documentation/SKILL.md

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
   - Provide “When to update each file” guidance for each discovered doc
     (README, AGENTS.md, docs/, CONTRIBUTING, SECURITY, etc.)
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
