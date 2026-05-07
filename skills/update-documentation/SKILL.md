---
name: update-documentation
description: Keep project documentation aligned with code by detecting and auto-fixing mismatches using agent-based analysis.
---

# Update Documentation (AUTHORITATIVE)

This skill synchronizes **project documentation** with **source code**.

It treats **code as ground truth** and documentation as a **derived artifact**
that must be kept accurate, consistent, and runnable.

This is a **pure agent-based process**.
No Python scripts, generators, or external tooling are used.

---

## Scope

This skill applies to:

- `README.md` / `README.rst`
- `AGENTS.md`
- All `SKILL.md` files
- Project documentation under `docs/` (Markdown or RST)

It MUST NOT modify:

- Source code
- Test code
- Generated or vendored documentation

---

## When to use this skill

Invoke this skill when the user asks to:

- "sync documentation"
- "update documentation"
- "fix documentation drift"
- "align docs with code"

This skill is **not** a linter.
It **actively edits documentation** to restore alignment.

---

## Ground truth hierarchy

Ground truth is determined in this order:

1. **Source code**
2. **AGENTS.md**
3. **SKILL.md files**
4. **README / docs**

Documentation MUST conform to the above.
Lower levels MUST NOT contradict higher levels.

---

## Agent-based synchronization process

When invoked, the agent MUST follow these steps **in order**.

---

### Step 1 — Extract ground truth from code

Scan the repository to identify externally visible behavior, including:

- Public APIs (exports, public classes, functions)
- CLI commands and options
- Exception types and error behavior
- Default values and limits
- Environment variable usage
- Configuration models or schemas

Only documented, reachable behavior counts as ground truth.

---

### Step 2 — Scan documentation files

Read and analyze all relevant documentation sources, including:

- `README.*`
- `AGENTS.md`
- All `SKILL.md` files
- `docs/**/*.md` or `docs/**/*.rst`

Identify:

- API descriptions
- Tables of behavior or limits
- Code examples
- File paths and references
- Cross-links between documents

---

### Step 3 — Detect misalignment

Compare documentation against ground truth and identify:

- Outdated or missing APIs
- Incorrect CLI usage or flags
- Missing or extra exception types
- Stale default values
- Broken file paths
- Code examples that no longer match behavior
- Skills or agents documentation contradicting code

---

### Step 4 — Auto-fix documentation

The agent MUST directly edit documentation files to restore correctness.

Allowed fixes include:

- Adding or updating tables
- Updating examples to match current APIs
- Fixing file paths and references
- Removing references to removed features
- Aligning AGENTS.md and SKILL.md descriptions with real behavior
- Updating default values and limits

The agent MUST NOT invent behavior.
If the ground truth is unclear, the agent MUST stop and report it.

---

### Step 5 — Report changes

After modifications, report:

- Files changed
- Nature of each change
- Any mismatches that could not be fixed automatically
- Any assumptions made (if unavoidable)

---

## AGENTS.md alignment rules

- `AGENTS.md` MUST accurately describe:
  - architecture
  - workflows
  - constraints
  - known intentional behaviors
- If an AGENTS.md statement contradicts code, the documentation MUST be updated.
- This skill MUST NOT modify AGENTS.md structure or intent — only correctness.

---

## SKILL.md alignment rules

- SKILL.md files are **policy**
- Documentation MUST reflect what skills actually enforce
- If a skill mentions behavior not present in code, documentation MUST be corrected
- This skill MUST NOT edit SKILL.md behavior definitions

---

## Code examples in documentation

- All code examples MUST reflect actual APIs
- Examples SHOULD be runnable when possible
- Example naming conventions defined by project skills MUST be preserved
- Outdated examples MUST be rewritten or removed

---

## What this skill must NOT do

- Modify source code to match documentation
- Silence inconsistencies without fixing them
- Invent undocumented features
- Change policy encoded in SKILL.md files
- Reformat documentation unnecessarily

---

## Failure mode

If alignment cannot be restored without guessing:

- Stop
- Explain the ambiguity
- Ask for clarification

Correctness always beats completeness.
