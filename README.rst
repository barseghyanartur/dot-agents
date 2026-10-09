==========
dot-agents
==========

A collection of SKILL.md files for AI agents — covering repository governance,
development workflows, and Python project management.

.. image:: https://github.com/barseghyanartur/dot-agents/actions/workflows/ci.yml/badge.svg?branch=main
   :target: https://github.com/barseghyanartur/dot-agents/actions/workflows/ci.yml
   :alt: CI Status

.. image:: https://img.shields.io/github/v/tag/barseghyanartur/dot-agents?label=release
   :target: https://github.com/barseghyanartur/dot-agents/tags
   :alt: Latest release

.. image:: https://img.shields.io/badge/skills-9-blueviolet
   :target: https://github.com/barseghyanartur/dot-agents/#skills
   :alt: Number of skills

.. image:: https://img.shields.io/badge/format-SKILL.md-orange
   :target: https://agentskills.io
   :alt: SKILL.md format

.. image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit
   :target: https://github.com/pre-commit/pre-commit
   :alt: pre-commit enabled

.. image:: https://img.shields.io/badge/markdown-markdownlint-informational
   :target: https://github.com/DavidAnson/markdownlint
   :alt: markdownlint

.. image:: https://img.shields.io/badge/license-MIT-blue.svg
   :target: https://github.com/barseghyanartur/dot-agents/#license
   :alt: MIT

.. image:: https://img.shields.io/badge/works%20with-Claude%20Code%20%C2%B7%20OpenCode%20%C2%B7%20Codex%20%C2%B7%20Antigravity%20%C2%B7%20Kiro%20%C2%B7%20MiMo%20%C2%B7%20Copilot%20CLI-informational
   :target: https://github.com/barseghyanartur/dot-agents/#usage
   :alt: Compatible agents

------
Skills
------

+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| Skill                                | Description                                      | Location                                         | Assets (relative to Location + assets)  |
+======================================+==================================================+==================================================+=========================================+
| dot-agents-repo-bootstrap            | Create AGENTS.md and standard SKILL.md files.    | ``skills/dot-agents-repo-bootstrap/``            |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-skill-authoring           | Add or modify SKILL.md files per AGENTS.md.      | ``skills/dot-agents-skill-authoring/``           |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-code-review               | Review changes for evidence-backed defects.      | ``skills/dot-agents-code-review/``               |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-code-optimisation         | Review changes for perf/simplification/reuse.    | ``skills/dot-agents-code-optimisation/``         |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-reproduce-and-verify-fix  | Reproduce a review finding and verify a fix.     | ``skills/dot-agents-reproduce-and-verify-fix/``  |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-update-documentation      | Detect and fix doc/code mismatches.              | ``skills/dot-agents-update-documentation/``      |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-doc-codeblock-tests       | Run Python code blocks in docs as pytest tests.  | ``skills/dot-agents-doc-codeblock-tests/``       |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-migrate-to-uv             | Migrate to uv from virtualenv, pip-tools, etc.   | ``skills/dot-agents-migrate-to-uv/``             | ``pyproject.toml.tmpl``                 |
|                                      |                                                  |                                                  | ``Makefile.tmpl``                       |
|                                      |                                                  |                                                  | ``pre-commit-config.yaml.tmpl``         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+
| dot-agents-migrate-from-mypy-to-ty   | Switch from mypy to ty for type checking.        | ``skills/dot-agents-migrate-from-mypy-to-ty/``   |                                         |
+--------------------------------------+--------------------------------------------------+--------------------------------------------------+-----------------------------------------+

-----
Usage
-----

Reference a skill in your IDE:

.. code-block:: text

    @skill dot-agents-repo-bootstrap

Or in an agent harness:

.. code-block:: text

    /dot-agents-repo-bootstrap

Skill files follow a simple priority order: ``AGENTS.md`` overrides existing
SKILL.md files, which override any new skill being added.

-------
License
-------

MIT — see ``LICENSE``.

------
Author
------

Artur Barseghyan
