==========
dot-agents
==========

A collection of SKILL.md files for AI agents — covering repository governance,
development workflows, and Python project management.

------
Skills
------

+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+
| Skill                    | Description                                      | Location                             | Assets (relative to Location + assets)  |
+==========================+==================================================+======================================+=========================================+
| repo-bootstrap           | Create AGENTS.md and standard SKILL.md files.    | ``skills/repo-bootstrap/``           |                                         |
+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+
| skill-authoring          | Add or modify SKILL.md files per AGENTS.md.      | ``skills/skill-authoring/``          |                                         |
+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+
| update-documentation     | Detect and fix doc/code mismatches.              | ``skills/update-documentation/``     |                                         |
+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+
| doc-codeblock-tests      | Run Python code blocks in docs as pytest tests.  | ``skills/doc-codeblock-tests/``      |                                         |
+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+
| migrate-to-uv            | Migrate to uv from virtualenv, pip-tools, etc.   | ``skills/migrate-to-uv/``            | ``pyproject.toml.tmpl``                 |
|                          |                                                  |                                      | ``Makefile.tmpl``                       |
|                          |                                                  |                                      | ``pre-commit-config.yaml.tmpl``         |
+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+
| migrate-from-mypy-to-ty  | Switch from mypy to ty for type checking.        | ``skills/migrate-from-mypy-to-ty/``  |                                         |
+--------------------------+--------------------------------------------------+--------------------------------------+-----------------------------------------+

-----
Usage
-----

Reference a skill in your IDE:

.. code-block:: text

    @skill repo-bootstrap

Or in an agent harness:

.. code-block:: text

    /repo-bootstrap

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
