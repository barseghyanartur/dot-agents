=========
Changelog
=========

0.2 (2026-09-22)
================

Added
-----

- ``dot-agents-code-review``: new standalone, read-only review skill for
  pull requests, branches, commits, and local diffs. Defines an
  evidence-gated finding format (``P0``-``P3`` severity, required fields:
  location, trigger, failure, impact, evidence, verification, minimal fix,
  confidence) and works without any other ``dot-agents`` skill installed.
- ``metadata.version`` added to every skill's frontmatter, starting this
  changelog's version tracking.

Changed
-------

- **Breaking:** every skill directory and frontmatter ``name`` renamed from
  a bare name to a ``dot-agents-`` prefixed one, to avoid collisions with
  same-named skills from other sources:

  - ``skills/repo-bootstrap`` → ``skills/dot-agents-repo-bootstrap``
  - ``skills/skill-authoring`` → ``skills/dot-agents-skill-authoring``
  - ``skills/update-documentation`` → ``skills/dot-agents-update-documentation``
  - ``skills/doc-codeblock-tests`` → ``skills/dot-agents-doc-codeblock-tests``
  - ``skills/migrate-to-uv`` → ``skills/dot-agents-migrate-to-uv``
  - ``skills/migrate-from-mypy-to-ty`` → ``skills/dot-agents-migrate-from-mypy-to-ty``

  Any ``@skill <old-name>`` reference or ``/<old-name>`` slash command must
  be updated to the new prefixed name.
- All skills updated their internal cross-references (mentions of sibling
  skill names in prose) to the new ``dot-agents-`` prefixed names.
- ``dot-agents-repo-bootstrap``: the specification for the
  ``dot-agents-code-review`` skill it generates in bootstrapped repositories
  was rewritten from a flat 9-item checklist into the same five-section
  structure as the standalone ``dot-agents-code-review`` skill (authority
  and scope, inspect the change, review by risk, gate and verify findings,
  report findings), including the full risk sub-criteria, the finding
  template, and the ``P0``-``P3`` severity taxonomy. It replaces the
  previous, less detailed ``pr-review`` skill concept. Local-work scope
  resolution now also requires enumerating and inspecting untracked paths
  via ``git status``, not just staged and unstaged changes.
- ``dot-agents-migrate-from-mypy-to-ty``: updated cross-references to
  ``dot-agents-migrate-to-uv``, ``dot-agents-dev-workflow``, and
  ``dot-agents-doc-codeblock-tests``; removed stray trailing whitespace.
- ``README.rst``: skills table and usage examples updated to the new
  ``dot-agents-`` prefixed names and locations.

0.1 (2026-05-12)
================

- Initial public release with six skills: ``repo-bootstrap``,
  ``skill-authoring``, ``update-documentation``, ``doc-codeblock-tests``,
  ``migrate-to-uv``, and ``migrate-from-mypy-to-ty``.
