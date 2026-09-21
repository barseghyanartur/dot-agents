==========
dot-agents
==========

A collection of SKILL.md files for AI agents — covering repository governance,
development workflows, and Python project management.

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
