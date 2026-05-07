==========
dot-agents
==========

A collection of agent-operable skills for repository governance, development workflows, and Python project management.

--------
Overview
--------

This repository contains structured SKILL.md files that define enforceable policies and procedures for AI agents working with code repositories. Each skill is self-contained, authoritative, and designed to be consumed by agents like Amazon Q Developer.

------
Skills
------

Repository Governance
=====================

**repo-bootstrap**
  Bootstrap agent-operable governance by creating AGENTS.md and standard SKILL.md files. Establishes the foundation for agent-driven repository management with facts-only governance and procedure-based skills.

  Location: ``skills/repo-bootstrap/``

**skill-authoring**
  Create and modify repository-specific SKILL.md policy files in strict compliance with AGENTS.md and existing project skills. Enforces authority hierarchy and conflict detection.

  Location: ``skills/skill-authoring/``

Development Workflow
====================

**update-documentation**
  Keep project documentation aligned with code by detecting and auto-fixing mismatches using agent-based analysis. Treats code as ground truth and documentation as derived artifacts.

  Location: ``skills/update-documentation/``

**doc-codeblock-tests**
  Validate Python code blocks in Markdown documentation using pytest-codeblock. Enforces correctness of documentation examples by executing them as tests.

  Location: ``skills/doc-codeblock-tests/``

Python Project Management
==========================

**migrate-to-uv**
  Migrate Python repositories from virtualenv, virtualenvwrapper, pip-tools, requirements files, setup.py, or setup.cfg to a uv-managed pyproject.toml and uv.lock workflow. Includes advanced templates for pyproject.toml, Makefile, and pre-commit configuration.

  Location: ``skills/migrate-to-uv/``

  Assets:
    - ``assets/pyproject.toml.tmpl`` - Complete project metadata and tool configuration
    - ``assets/Makefile.tmpl`` - uv-first build and development targets
    - ``assets/pre-commit-config.yaml.tmpl`` - Advanced pre-commit baseline

**migrate-from-mypy-to-ty**
  Migrate Python respositories from mypy to ty.

  Location: ``skills/migrate-from-mymy-to-ty``

-----
Usage
-----

For AI Agents
=============

Reference skills using the ``@`` syntax in your IDE:

.. code-block:: text

    @skill repo-bootstrap
    @skill migrate-to-uv

Or ``/`` in your agent harness tool:

.. code-block:: text

    /repo-bootstrap
    /migrate-to-uv

Each SKILL.md file contains:

- YAML frontmatter with name and description
- Authoritative procedures and constraints
- Explicit scope boundaries
- Prohibited practices
- Verification steps

For Developers
==============

Skills are designed to be:

- **Authoritative**: Define enforceable policy, not suggestions
- **Self-contained**: Each skill has a single responsibility
- **Explicit**: Use "MUST", "MUST NOT", "MAY" for clarity
- **Observable**: Based on facts, not assumptions

Skill Structure
===============

Every SKILL.md file follows this format:

.. code-block:: yaml

    ---
    name: skill-name
    description: Concise description of the skill's purpose
    ---

    # Skill Title (AUTHORITATIVE)

    [Skill content with explicit rules, scope, and procedures]

---------
Hierarchy
---------

Authority flows in this order:

1. **AGENTS.md** - Repository facts, constraints, and invariants
2. **Existing SKILL.md files** - Established policies
3. **New skills** - Must comply with above

Lower levels MUST NOT contradict higher levels.

-------
License
-------

MIT License

Copyright (c) 2026 Artur Barseghyan

See LICENSE file for full details.

------
Author
------

Artur Barseghyan
