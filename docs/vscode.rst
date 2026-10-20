=========================
Install skills in VS Code
=========================

This guide shows how to add the dot-agents skills to VS Code. It also works
in a sandbox, a dev container, or GitHub Codespaces.

---------
You need
---------

- VS Code with GitHub Copilot Chat.
- A trusted workspace. Agents do not run in Restricted Mode. If you see the
  Restricted Mode banner, click it and choose *Trust*.

--------------------------
Option 1: one step install
--------------------------

VS Code can install skills straight from GitHub, as an agent plugin.

In Copilot Chat, type:

.. code-block:: text

    /plugin install https://github.com/barseghyanartur/dot-agents

Or open the Command Palette and run *Chat: Install Plugin From Source*.
Paste the same URL.

Done. Type ``/`` in chat to see the skills.

If nothing happens, turn on the ``chat.plugins.enabled`` setting and try
again.

------------------------
Option 2: install script
------------------------

Use this if your sandbox blocks plugins. Run this in the VS Code terminal:

.. code-block:: sh

    curl -fsSL https://raw.githubusercontent.com/barseghyanartur/dot-agents/main/scripts/install.sh | sh

The script copies the skills to ``~/.agents/skills/``. Other skills in that
folder are kept. Run it again to update.

Type ``/`` in chat to see the skills. If they are missing, run
*Developer: Reload Window*.

-----
Notes
-----

- Both options leave your project untouched. Nothing shows up in
  ``git status``.
- To remove the skills, uninstall the plugin (Option 1), or delete the
  ``dot-agents-*`` folders in ``~/.agents/skills/`` (Option 2).

-------
Sources
-------

- `Agent plugins in VS Code
  <https://code.visualstudio.com/docs/agent-customization/agent-plugins>`_
- `Agent plugin authoring reference
  <https://code.visualstudio.com/docs/agents/reference/agent-plugin-reference>`_
- `Use Agent Skills in VS Code
  <https://code.visualstudio.com/docs/agent-customization/agent-skills>`_
- `AI security in VS Code (Restricted Mode)
  <https://code.visualstudio.com/docs/agents/run/security>`_
