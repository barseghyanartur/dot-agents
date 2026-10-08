---
name: dot-agents-reproduce-and-verify-fix
description: Create an isolated test that reproduces a review finding, checks a temporary fix, and explains the results in a short companion document.
metadata:
  version: "0.1"
---

# Reproduce and verify a fix

Use the finding and brief request from the current review. Ask only if the
target or expected behavior is unclear.

Invoking this skill allows creating the test and its companion document.
It does not allow changing application code or publishing a review comment.
Follow the repository's instructions and testing rules.

## Build the evidence

Create one small test file with two clearly named cases:

- **Original behavior:** assert the intended result. It should fail because
  of the reported defect, not because setup or imports are broken.
- **Temporary fix:** run the same operation, inputs, and assertions with the
  smallest proposed fix applied through monkeypatching or an equivalent.

Use real application code and relevant libraries. Keep the hooks and other
parts involved in the failure enabled. Fake only outside dependencies,
such as network or storage, needed to make the test safe and repeatable.
Do not mock away the defect or return a canned success from the patched code.

Keep the fix inside the test. Patch where the code looks up the function,
including imported references when needed. Restore patches after each case.
Use fresh state so the cases do not affect each other.

Prefer one test with two cases when that is clearer. Remove extra controls
and helpers unless they are needed to prove the cause.

## Run and check

Use the repository's runtime and test tools. Include the exact run command
and expected results in the test file.

Run both cases. Check the original failure reaches the reported defect and
the patched case passes the same assertions.

Do not hide the original failure with an expected-failure marker or change
its assertion to accept the bug. Explain that this evidence test is expected
to exit with a failure before the application is fixed.

If either result differs, investigate and report it honestly. If execution
is blocked, give the reason and label the results unverified.

Do not install dependencies, use real credentials, contact live services,
or change application files to make the demonstration work.

## Explain it simply

Create a Markdown file beside the test, with the same base name. Keep it
short enough to use as supporting material in a review comment:

- What fails and why it matters.
- The short path from the real operation to the failure.
- Which file/function needs changing, what to change, and why it helps.
- What the two cases actually showed and what was faked.

Explain what the temporary fix does in plain language. Address any likely
misunderstanding. Do not claim that one passing case proves the whole fix.

Include the run command and actual results. Follow repository rules for
documentation examples; use a small diff for a suggested code change.

End the response with file links, results, and a short ready-to-paste review
comment. Suggest a changed line for the comment when known. Keep the comment
clear on its own. Do not publish it.
