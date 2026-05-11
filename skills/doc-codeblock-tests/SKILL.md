---
name: doc-codeblock-tests
description: Validate Python code blocks in Markdown documentation using pytest-codeblock.
---

# Markdown code block tests (AUTHORITATIVE)

This skill enforces correctness of Python code examples in Markdown (`.md`) files
by executing them as tests using [pytest-codeblock](https://pytest-codeblock.readthedocs.io/en/latest/source_tree.txt).

Broken documentation examples are treated as test failures.

---

## Scope

- Applies **only** to Markdown files (`*.md`)
- Applies **only** to Python code blocks
- reStructuredText (`.rst`) is explicitly out of scope

---

## Mandatory code block rules

All Python code blocks in Markdown MUST:

1. Be explicitly **named**
2. Use a `test_…` prefix
3. Contain executable Python code

Example (guaranteed-valid, stdlib-only):

````markdown
```python name=test_pathlib_basics
from pathlib import Path

p = Path("example.txt")

assert p.name == "example.txt"
assert p.suffix == ".txt"
assert p.parent == Path(".")
```
````

Unnamed Python code blocks are **invalid**.

---

## Grouping rules

- Group code blocks **only** when they form a single logical example
- Grouping across multiple blocks is allowed and supported
- Do not group unrelated examples

Each grouped example still requires named blocks
and must be valid when concatenated.

---

## Test execution

- Code blocks are collected and executed by `pytest-codeblock`
- Execution happens as part of the normal pytest run
- Failures indicate incorrect or outdated documentation

No special configuration is required unless the project explicitly defines it.

---

## Alignment with dev-workflow

This skill is **not standalone**.

When modifying documentation:

- Documentation code block tests MUST run as part of the normal test pass
- A failing documentation code block:
  - blocks completion
  - must be fixed before work is considered done

This integrates automatically with the repository’s `dev-workflow` (or similar)
definition of “done”.

---

## Prohibited practices

You must NOT:

- Skip failing documentation tests
- Comment out code blocks to silence failures
- Convert executable examples into non-executable pseudo-code
- Remove `test_…` names to avoid collection

Documentation correctness is enforced, not optional.

---

## Intent

Documentation is treated as a first-class, executable contract.
If users can copy it, it must run.
