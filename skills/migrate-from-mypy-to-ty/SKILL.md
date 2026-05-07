---
name: migrate-from-mypy-to-ty
description: Migrate Python repositories from mypy to ty for static type checking.
---

# Migrate from mypy to ty (AUTHORITATIVE)

This skill replaces `mypy` with `ty` as the static type checker across all
project surfaces: dependencies, configuration, Makefile targets, pre-commit
hooks, CI pipelines, and documentation.

`ty` is the Astral type checker (`uv add --group dev ty`).
The canonical invocation in a uv-managed project is `uv run ty check`.

---

## Scope

This skill applies to all surfaces where `mypy` is referenced:

- `pyproject.toml` — dependency groups and `[tool.mypy]` configuration
- `Makefile` — `mypy` targets and phony declarations
- `.pre-commit-config.yaml` — mypy hooks
- CI pipeline files (`.github/workflows/`, `tox.ini`, etc.)
- Documentation and README files

This skill MUST NOT modify:

- Source code type annotations
- Any file outside the surfaces listed above

---

## Relationship with migrate-to-uv

If the `migrate-to-uv` skill was previously applied, the following artifacts
reference `mypy` and MUST be updated by this skill:

- Verification commands: `uv run mypy {{ mypy_paths }}` → `uv run ty check`
- Makefile targets: `make mypy` → `make ty` (or equivalent)
- `pyproject.toml` template: `[tool.mypy]` → `[tool.ty]`

---

## Phase 1 — Survey (READ-ONLY)

Before making any change, identify all mypy references:

- `pyproject.toml`: `mypy` in `[dependency-groups]` or
  `[project.optional-dependencies]`; `[tool.mypy]` section
- `Makefile`: targets, `.PHONY`, variables, and `help` output mentioning `mypy`
- `.pre-commit-config.yaml`: any hook with `mypy` in `id`, `name`, or `repo`
- CI files: steps or commands referencing `mypy`
- `README.*`, `docs/`: command examples referencing `mypy`
- `tox.ini` or `tox.toml`: any `mypy` commands in `[testenv]` sections

Record every file and line before editing. The survey output drives the
migration; do not skip files that appear to be low-risk.

---

## Phase 2 — Dependency migration

MUST remove `mypy` and all mypy plugins from every dependency group:

```bash
uv remove mypy
uv remove mypy-extensions
uv remove types-*      # remove all stub packages added for mypy
```

MUST add `ty`:

```bash
uv add --group dev ty
```

Rules:

- `ty` goes in the `dev` dependency group unless the project uses a dedicated
  `lint` or `typecheck` group, in which case it goes there.
- Third-party stub packages (`types-requests`, `types-PyYAML`, etc.) MUST be
  evaluated individually — `ty` bundles many stubs; remove only those no longer
  needed.
- Do not add `ty` as a runtime (`[project].dependencies`) dependency.

---

## Phase 3 — Configuration migration

### Remove mypy configuration

Remove the `[tool.mypy]` section and any `[[tool.mypy.overrides]]` sections
from `pyproject.toml` in their entirety.

MUST NOT leave a `[tool.mypy]` section with no entries as a "placeholder."

### Add ty configuration

Add a minimal `[tool.ty.environment]` section. Encode only settings that are
explicitly required by the project:

```toml
[tool.ty.environment]
# Required when the package lives under src/ — tells ty where to resolve imports
root = ["src"]
```

For multi-root projects (examples, benchmarks, etc.) list every directory that
must be importable:

```toml
[tool.ty.environment]
root = ["src", "benchmarks", "examples/gae"]
```

Valid top-level keys under `[tool.ty]` are: `environment`, `src`, `rules`,
`terminal`, `analysis`, `overrides`. Attempting to add any other key (e.g.
`exclude`) causes a hard TOML parse error.

Rules:

- Do not mechanically translate every mypy flag to a ty equivalent; ty has
  different defaults and a different flag surface.
- Strictness settings from mypy (`disallow_untyped_defs`, etc.) MUST NOT be
  blindly copied; verify whether ty supports the equivalent before adding it.
- If `ty` does not support a mypy flag that the project relied on, document the
  gap in a comment and raise it in the completion report rather than silently
  dropping it.

### Ignore comment migration

`# type: ignore` (PEP 484 / mypy syntax) is a **silent no-op in ty**. ty uses
its own syntax:

```python
some_expression  # ty: ignore[rule-name]
```

The rule name matches exactly what ty prints in brackets, e.g.
`error[unresolved-reference]` → `# ty: ignore[unresolved-reference]`.

Running `uv run ty check --add-ignore` inserts `# ty: ignore` comments
automatically for every current diagnostic — useful as a starting point.

MUST audit every existing `# type: ignore` comment in the codebase:

1. Run `uv run ty check` and note which locations ty flags.
2. For each `# type: ignore` location:
   - If ty still flags it → replace `# type: ignore[...]` with
     `# ty: ignore[rule-name]`.
   - If ty does not flag it → remove the comment (it is dead).
3. Do not leave `# type: ignore` comments as migration artefacts — they provide
   no suppression and create false confidence.

### Jupyter notebook awareness

ty checks `.ipynb` files by default when it scans the project root. Projects
with Jupyter notebooks may receive unexpected `unresolved-attribute` errors
because notebook cells call methods on union return types without type narrowing.

For each failing notebook cell that accesses attributes on a typed result:

- **Preferred fix:** add `assert isinstance(res, ExpectedType)` in the cell
  where the variable is assigned. ty narrows the type for all subsequent cells.
- **Alternative:** add `# ty: ignore[unresolved-attribute]` to the specific
  line inside the cell source.

Do not attempt to suppress notebook errors via `exclude` under `[tool.ty]` —
that key is not valid there and will cause a parse error.

### Common ty error patterns

Patterns that ty catches which mypy often accepted silently:

| Pattern | ty error code | Fix |
| ------- | ------------ | --- |
| `mod.attr = val` on a `types.ModuleType` | `unresolved-attribute` | Use `setattr(mod, "attr", val)` or `# ty: ignore[unresolved-attribute]` |
| Referencing a runtime-injected global (e.g. kernprof's `profile`) | `unresolved-reference` | Use `# ty: ignore[unresolved-reference]` |
| Calling a method that doesn't exist on the actual type (e.g. `.close()` on `list`, hidden by `contextlib.suppress`) | `unresolved-attribute` | Remove the dead call |
| Accessing attributes on a union type without narrowing (e.g. `Optional[Union[str, Result]]`) | `unresolved-attribute` | Add `assert isinstance(...)` or cast before attribute access |

---

## Phase 4 — Makefile migration

MUST replace every `mypy`-related target:

- Rename the target: `mypy:` → `ty:` (or `typecheck:`)
- Replace the command: `uv run mypy $(MYPY_PATHS)` → `uv run ty check`
- Update `.PHONY` to reference the new target name
- Update the `help` output if the project uses a help target
- Remove or rename any variable that was dedicated to mypy paths (e.g.
  `MYPY_PATHS`) if it is no longer needed

MUST NOT leave a dead `mypy:` target alongside a new `ty:` target.

---

## Phase 5 — Pre-commit migration

Inspect `.pre-commit-config.yaml` for any mypy hook:

- If a mypy hook from `https://github.com/pre-commit/mirrors-mypy` is present,
  remove the entire repo block.
- If `mypy` appears as a local hook, replace the command with `ty check`.
- If `ty` does not yet have a pre-commit mirror available, use a local hook:

```yaml
- repo: local
  hooks:
    - id: ty
      name: ty
      entry: uv run ty check
      language: system
      types: [python]
      pass_filenames: false
```

Run `uv run pre-commit run --all-files` after updating the file.

---

## Phase 6 — CI migration

In every CI pipeline file, replace:

- `mypy` install steps with `ty` (usually handled by `uv sync`)
- `mypy` or `uv run mypy` commands with `uv run ty check`
- Any caching configuration keyed on mypy (`.mypy_cache`) with the ty
  equivalent (`.ty_cache`) if caching is enabled

---

## Phase 7 — Documentation migration

Update all documentation referencing `mypy`:

- README setup or usage instructions
- Developer guides
- `docs/` pages with type checking instructions
- AGENTS.md or SKILL.md files that name `mypy` explicitly (e.g. verification
  sequences in `migrate-to-uv` or `dev-workflow`)

MUST NOT leave user-facing documentation that instructs users to run `mypy`
after this migration is complete.

If any code examples in Markdown reference `mypy`, they MUST be updated to
reference `ty`. Code examples in Markdown MUST comply with the
`doc-codeblock-tests` skill (Python code blocks must be named `test_*`).

---

## Phase 8 — Verification

MUST run these checks in order after completing all changes:

```bash
uv lock
uv sync --all-groups --all-extras
uv run ty check
uv run pre-commit run --all-files
```

If a Makefile target was created:

```bash
make ty          # or make typecheck — match the new target name
```

A migration is NOT complete until `uv run ty check` exits zero.

---

## Prohibited practices

- MUST NOT leave `mypy` in any dependency group after migration
- MUST NOT leave `[tool.mypy]` in `pyproject.toml` after migration
- MUST NOT blindly copy mypy configuration flags that ty does not support
- MUST NOT silently drop type errors that mypy caught but ty does not yet catch
  — document any known regressions in the completion report
- MUST NOT leave `# type: ignore` comments in the codebase after migration —
  ty does not honour them; they suppress nothing and create false confidence.
  Convert to `# ty: ignore[rule-name]` where ty still flags the location, or
  remove them where ty does not.

---

## Completion report (MANDATORY)

Report after migration:

- All files modified and the nature of each change
- Mypy flags that were dropped because ty does not support them
- Third-party stub packages removed and any retained with justification
- Known type errors suppressed by ty that mypy would have flagged
- Any surfaces left unmodified (e.g. tox skipped because the project uses it
  for legacy CI only) with explicit justification
