---
name: dot-agents-reproduce-and-verify-fix
description: Create an isolated test that reproduces a review finding, checks a temporary fix, and explains the results in a short companion document.
---

# Reproduce and verify a fix

Use the current review and the user's brief request. Ask if the finding or
expected behavior is unclear. Follow repository rules.

Create one small, separate test file with two cases:

- **Original:** assert the correct behavior; show it fails from the defect.
- **Temporary fix:** repeat the same inputs and assertions with the smallest
  fix monkeypatched into the real code.

Run real application code and the libraries involved. Mock only outside
services, such as network or storage. Keep the failing path active; do not
replace it with a fake success. Restore patches and reset state between cases.

Run both cases using the repository's tools. Keep the original failure
visible, without `xfail`. Include the run command and expected results in
the test file. If results differ, investigate. If blocked, say why.

Create a Markdown file beside the test with the same base name. Briefly explain:

- What fails, why, and who is affected.
- Where to fix it, what to change, and why it works.
- What was mocked and what each case actually showed.

Use plain words and short sentences. Include a small fix diff when helpful.
A passing patched case verifies this example, not the whole fix.

Return file links, actual results, and a short ready-to-paste review comment.
Do not change application files, install dependencies, contact live services,
use real credentials, or publish the comment.
