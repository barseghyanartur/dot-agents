---
name: migrate-to-uv
description: Migrate Python repositories from virtualenv, virtualenvwrapper, pip-tools, requirements files, setup.py, or setup.cfg to a uv-managed pyproject.toml and uv.lock workflow.
---

# Migrate Python Project to uv

## Purpose

Migrate legacy Python repositories to `uv` while preserving the existing
project shape, packaging metadata, quality tooling, documentation tooling,
test workflows, and release ergonomics.

This skill intentionally uses advanced templates, not minimal examples.
The templates are starting points to render and prune after inspecting the
target repository:

- `assets/pyproject.toml.tmpl`: complete project metadata, setuptools config,
  uv dependency groups, ruff, pytest, coverage, mypy, doc8, and optional
  Sphinx source-tree configuration.
- `assets/Makefile.tmpl`: uv-first install/run targets plus optional Docker,
  tox, docs, pre-commit, detect-secrets, package, release, and version targets.
- `assets/pre-commit-config.yaml.tmpl`: advanced pre-commit baseline with
  doc8, detect-secrets, pre-commit-hooks, ruff, pydoclint, markdownlint,
  and optional pyupgrade.

Never paste the templates unchanged. Replace all placeholders and remove
optional sections that the target repository does not support.

## Repository Survey

Before editing, inspect the target repository for:

- Existing `pyproject.toml`, `setup.py`, `setup.cfg`, `tox.ini`, `Makefile`,
  `docker-compose.yml`, `.pre-commit-config.yaml`, `.readthedocs.yaml`, and
  documentation config.
- Requirement sources: `requirements*.in`, `requirements*.txt`, `constraints*.txt`,
  `dev*.in`, `test*.in`, `docs*.in`, and `build*.in`.
- Package layout: `src/<package>`, flat package layout, namespace packages,
  package data, console scripts, and tests location.
- Existing tool config for pytest, coverage, ruff, mypy, doc8, Sphinx, twine,
  detect-secrets, and sphinx-source-tree.
- Published package metadata: name, version, description, authors, license,
  classifiers, keywords, project URLs, optional extras, and dynamic versioning.

Merge with existing configuration where possible. Replace files only when the
existing file is primarily legacy virtualenv, pip-tools, or setup metadata.

## Template Rendering

Render the bundled templates with repository facts:

- `{{ project_name }}`: normalized distribution name, e.g. `example-project`.
- `{{ project_description }}`: package summary from existing metadata.
- `{{ package_import_name }}`: import package name, e.g. `example_project`.
- `{{ package_src_path }}`: package directory, e.g. `src/example_project`.
- `{{ package_egg_info_path }}`: egg-info cleanup path, e.g.
  `src/example_project.egg-info`.
- `{{ version }}`: current static version, or replace with dynamic version config.
- `{{ requires_python }}`: supported Python range, e.g. `>=3.10`.
- `{{ readme_file }}`: `README.md` or `README.rst`.
- `{{ license_expression }}`: SPDX-style license expression when known.
- `{{ author_name }}`, `{{ author_email }}`: project metadata.
- `{{ maintainer_name }}`, `{{ maintainer_email }}`: maintainer metadata.
- `{{ homepage_url }}`, `{{ repository_url }}`, `{{ issues_url }}`:
  project links.
- `{{ ruff_target_version }}`: ruff target such as `py310`.
- `{{ pytest_args }}`, `{{ test_paths }}`, `{{ ruff_paths }}`,
  `{{ mypy_paths }}`: local command defaults.
- `{{ tox_default_env }}`: default tox environment, e.g. `py312`.
- `{{ version_doc_path }}`: documentation file containing version text, if any.
- `{{ pre_commit_exclude }}`: regex for generated, vendored, migration, docs
  build, and package-data paths to skip.
- `{{ pre_commit_python }}`: hook Python, e.g. `python3` or `python3.12`.
- `{{ large_file_maxkb }}`: maximum file size for `check-added-large-files`.
- `{{ trailing_whitespace_exclude }}`: paths allowed to keep trailing spaces,
  usually generated data or vendored files.
- `{{ pyupgrade_flag }}`: optional pyupgrade target derived from
  `requires-python`, e.g. `--py310-plus`.

After rendering:

- Remove all `TEMPLATE:` comments.
- Remove unneeded optional sections bounded by `BEGIN optional:<name>` and
  `END optional:<name>`.
- When removing optional Makefile sections, also update `.PHONY`, variables,
  and `help` output so they only mention targets that remain.
- Remove empty TOML tables such as `[project.scripts]` or
  `[project.optional-dependencies]` if the project does not use them.
- When removing optional pre-commit hooks, remove the entire repo block unless
  another retained hook in that repo still needs it.
- Keep advanced sections when the repository has the matching tool or config.
- Do not leave placeholder strings in final project files.

## Dependency Migration

Use a source-of-truth first strategy, but preserve locked versions when useful.

- If `<name>.in` exists, treat it as the dependency source.
- If a sibling `<name>.txt` exists, do not import it as a dependency source;
  use it as a constraint to preserve the current locked versions.
- If only `<name>.txt` exists, import it as the best available source.
- Delete legacy requirements files only after `pyproject.toml`, `uv.lock`, and
  the environment have been verified.

Typical commands:

```bash
uv add -r requirements.in -c requirements.txt
uv add --group dev -r requirements-dev.in -c requirements-dev.txt
uv add --group test -r requirements-test.in -c requirements-test.txt
uv add --group docs -r requirements-docs.in -c requirements-docs.txt
uv add --group build -r requirements-build.in -c requirements-build.txt
```

Dependency placement:

- Runtime package requirements go in `[project].dependencies`.
- Published, user-facing optional features go in `[project.optional-dependencies]`.
- Local development, test, docs, security, and release tooling go in
  `[dependency-groups]`.
- Preserve existing published extras when they are part of the package contract.
- Do not add `uv` as a project dependency.

## Metadata and Build System

For legacy `setup.py` or `setup.cfg` projects, preserve setuptools unless the
target repository clearly intends to change build backend.

Required setuptools build system:

```toml
[build-system]
requires = ["setuptools>=41.0", "wheel"]
build-backend = "setuptools.build_meta"
```

Port metadata into `[project]`:

- `name`, `description`, `readme`, `requires-python`, `authors`, `maintainers`,
  `license`, `classifiers`, `keywords`, and URLs.
- `entry_points` or `scripts` into `[project.scripts]` or
  `[project.entry-points.<group>]`.
- `package_dir`, package discovery, and package data into `[tool.setuptools]`.

For dynamic versions, use exactly one valid strategy:

```toml
[project]
dynamic = ["version"]

[tool.setuptools.dynamic]
version = {attr = "{{ package_import_name }}.__version__"}
```

Do not leave both static `version = "..."` and `dynamic = ["version"]`.

## Makefile Migration

Use `assets/Makefile.tmpl` as the advanced starting point.

Rules:

- Use `uv sync` for environment synchronization.
- Use `uv run <tool>` for Python tools.
- Do not activate `.venv` with `source`.
- Do not call `.venv/bin/python` or `.venv/bin/<tool>` directly.
- Keep Docker and tox targets only if the target repository has Docker Compose
  and tox configuration.
- Keep docs targets only if the repository has Sphinx docs.
- Keep release targets only for publishable packages.
- Keep detect-secrets targets only when the project uses detect-secrets or will
  add it to a dependency group.
- Remove catch-all targets that hide unknown Make target typos.

## Pre-commit Migration

Use `assets/pre-commit-config.yaml.tmpl` as the advanced starting point.

Rules:

- Inspect any existing `.pre-commit-config.yaml` before replacing it.
- Preserve custom/local hooks unless they conflict with the uv migration.
- Prefer `ruff` + `ruff-format` over separate `flake8`/`isort`/`black` hooks unless the repo intentionally keeps them.
- Keep `doc8` only for projects with RST docs.
- Keep `markdownlint` only for Markdown-heavy projects.
- Keep `detect-secrets` only if `.secrets.baseline` exists or the migration creates one.
- Keep `pydoclint` only if the project enforces docstring completeness.
- Keep `pyupgrade` optional and set its flag from `requires-python`, e.g. `--py310-plus`.
- Adapt `exclude` to the target repo’s generated, vendored, docs build, migrations, data, and package-data paths.
- Keep hook versions from the existing config when they are deliberately pinned
  newer than the template; otherwise use the template versions as the baseline.
- Add `pre-commit` to the `dev` dependency group so `uv run pre-commit ...`
  works without a global install.
- Run `uv run pre-commit run --all-files` after rendering.

## Documentation and Cleanup

Update README and docs so setup instructions use:

```bash
uv sync --all-groups --all-extras
uv run pytest
```

Remove virtualenvwrapper, `mkvirtualenv`, `workon`, `pip-sync`, and
`pip-compile` instructions unless the repository intentionally keeps a legacy
compatibility workflow.

Handle Python version files conservatively:

- If `.python-version` matches the intended version, keep it.
- If it conflicts, either update it with `uv python pin <version>` or remove it
  after confirming the repository no longer uses pyenv-specific workflows.

Remove legacy files only after verification:

- `requirements*.in`
- `requirements*.txt`
- `setup.py`
- `setup.cfg`
- legacy virtualenv helper scripts

Keep `uv.lock` as the canonical lockfile.

## Verification

Run the strongest applicable checks for the target repository:

```bash
uv lock
uv sync --all-groups --all-extras
uv run pytest
uv run ruff check .
uv run mypy {{ mypy_paths }}
uv run python -m build .
uv run pre-commit run --all-files
```

Also run relevant Make targets after rendering the Makefile:

```bash
make install
make quick-test
make ruff
make mypy
make build-docs
make package-build
```

If Docker/tox remains the canonical test path, verify that path too:

```bash
make test
make test-env ENV={{ tox_default_env }}
```

Report any skipped checks and the reason.
