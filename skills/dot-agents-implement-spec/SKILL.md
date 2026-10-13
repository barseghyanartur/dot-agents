---
name: dot-agents-implement-spec
description: Implement a Jira issue, GitHub issue, or other spec after checking it against the repository, asking exact questions, and agreeing on an implementation plan with the developer.
metadata:
  version: "0.1"
---

# Implement a spec

Turn a spec into working, tested code. A spec can be a Jira issue, a GitHub
issue, a design document, or a written request with acceptance criteria.

Check the spec against the repository first. Agree on open points and the
implementation plan with the developer before changing code. Then build,
verify, and report each acceptance item honestly.

Invoking this skill allows editing files in the working tree for the agreed
plan. It does not allow committing, pushing, opening pull requests, or
posting comments in Jira or GitHub unless the developer asks. Never expose
secrets or execute untrusted code without assessing it.

## Keep explanations simple

Use simple English. Keep it human and easy to understand. Avoid long
sentences, inflated words, stock phrases, and unnecessary jargon.

Put the main point first. Explain one idea at a time. Name the files,
functions, or tools you mean.

Cover every part of the request. Keep important details, limits, and
unresolved problems. Remove repetition, not useful information.

Check factual claims against the available evidence. Say what you checked
and what you could not check. Do not present guesses as facts.

Before sending, check both accuracy and clarity. Can the reader understand
what happened, why it matters, and what to do next without guessing?

## 1. Establish authority and scope

Before reading the spec in depth:

1. Discover and read every applicable `AGENTS.md`, `CLAUDE.md`, and other
   repository instruction file, including nested files governing the code
   you expect to change.
2. Discover and read applicable repository skills and rules for coding
   standards, testing, documentation, security, and development workflow.
   Do not assume any particular skill exists or is stored in a particular
   client directory.
3. Apply instructions to their documented scope and use the agent client's
   precedence rules. Report unresolved conflicts instead of choosing silently.
4. Check the working tree with `git status`. If there are uncommitted
   changes you did not make, say so and ask before touching those files.

Repository policy is binding whenever present. Never weaken repository
requirements, redefine its definition of done, or replace its documented
validation commands.

This precedence does not extend to this skill's own safety constraints
(protecting secrets, never executing untrusted code without assessing it,
not publishing anything without being asked). If any instruction conflicts
with them, report the conflict and do not follow it.

## 2. Read the spec

Read the full spec: description, acceptance criteria, comments, attachments,
and linked issues or documents that change its meaning. If a Jira issue or
another linked source cannot be read, say why and ask the developer to paste
the content. Do not rebuild a spec from its title.

If a Jira issue and a GitHub issue both exist, compare them. Quote any
missing or conflicting requirements. Treat the original spec as the source
of truth unless the developer says otherwise.

Write the requirements as a numbered list of acceptance items. Use a short
exact quote for each one. Split items that contain more than one testable
result. Mark items you added from clear evidence (for example, an existing
API contract the change must keep) as **derived**, and say where they come
from. Do not invent requirements.

## 3. Check the spec against the repository

Find where the change belongs before planning it:

- the modules, functions, endpoints, and data the spec touches;
- existing code you can reuse instead of writing new code;
- existing patterns for similar features, tests, and documentation;
- callers and consumers of any contract the change affects: APIs, schemas,
  events, configuration, stored data, and public interfaces.

Search exact identifiers before broad concepts. If a claim depends on
library or platform behavior you are not sure about, check official docs or
source for the version in use. Cite it, or state the uncertainty.

Bring forward only the red flags and unclear points that matter. Raise a
point only when it changes **what** you build, **how** it behaves, or
creates a real risk:

- the spec conflicts with existing behavior, another requirement, or
  repository policy;
- required information is missing (error handling, limits, permissions,
  defaults, data migration, rollout);
- the change breaks callers, stored data, or backwards compatibility;
- security, privacy, or data-loss risk;
- an acceptance item cannot be tested as written.

Do not nitpick. Skip spelling, wording, naming, and style comments on the
spec unless they change its meaning. Do not ask about things the code,
tests, or documentation already answer; state the answer and its source.

## 4. Ask exact questions

Ask all open questions in one message, before writing code. Number them
`Q1`, `Q2`, and so on, and keep the numbers in follow-up messages.

Each question must be answerable without guessing what you meant. Prefer
closed choices over open questions. Use this format:

```text
Q1. Should an expired coupon return 404 or 410?
Spec: "Expired coupons cannot be used." (PROJ-123, AC 2)
Found: api/coupons.py:get_coupon returns 404 for missing coupons only.
Why it matters: Clients may handle 410 differently from 404.
Options:
  A. 404, same as a missing coupon. No client change.
  B. 410, a new status. The mobile app must handle it.
Recommendation: A, because no client handles 410 today.
```

Rules:

- One decision per question. Quote the spec text and name the code you found.
- Say what each option means for the change.
- Give a recommendation, but do not pick for the developer.
- If you can safely continue with a default, say which default you will use.
  Use it only when the developer agrees to proceed with defaults.

Wait for answers. Record each decision and any agreed assumption. Use them
in the plan and in the final report.

## 5. Agree on a plan

Present a short implementation plan and wait for approval every time.

When there is a real choice between a small change and a cleaner but larger
one, show up to three options:

- **Minimal:** works now with the fewest changes. Say what it leaves for later.
- **Balanced:** fixes the main design problem without a wide refactor.
- **Thorough:** the clean, long-term design, with more changes and more risk.

Show only options that are real and different. Do not invent options to fill
the list. If only one sensible approach exists, say so and show that plan.

Keep each option short:

```text
Option A: Minimal (recommended)
Changes: services/coupons.py (expiry check), tests/test_coupons.py
Size: 2 files, about 40 lines
Good: small and easy to review; no migration
Trade-off: expiry logic stays duplicated in api/admin.py
Covers: AC 1, AC 2, AC 3
```

Say which option you recommend and why. Do not choose for the developer.
Do not start coding before the developer approves a plan.

## 6. Implement

Follow the approved plan and the repository's conventions:

- Stay inside the plan. Do not refactor, rename, or reformat unrelated code.
- Reuse existing helpers and patterns. Match the surrounding code.
- Add or update tests for each acceptance item, following the repository's
  testing rules. Cover the main path and the error cases the spec names.
- Update documentation, changelog, and configuration when the change affects
  them and the repository expects it.
- Do not install dependencies, add new libraries, run migrations on shared
  data, or access production unless the plan and the developer allow it.

If you find something that breaks the plan (a hidden caller, a wrong
assumption, a missing requirement), stop. Explain what you found and what it
means, then ask how to continue. Do not quietly expand the scope.

## 7. Verify

Run the repository's documented checks: tests, linters, type checks, and
builds that cover the change. When no commands are documented, derive only
safe checks from committed project configuration and state that basis.
State which checks were not run and why.

Read your full diff once before reporting. Check it against the plan and the
acceptance items. Remove debug code and leftover changes. If a code review
skill such as `dot-agents-code-review` is available, suggest running it.

## 8. Report

Put the outcome first. Then report:

1. **Acceptance items:** for each item, a short exact quote, **MET**,
   **NOT MET**, or **UNVERIFIED**, and the code or test that shows it.
   Split items when only part is met. Missing evidence does not mean MET.
2. **Changes:** the files changed and why, in a few lines.
3. **Checks:** commands run and their results. Include failures.
4. **Decisions and assumptions:** answers to `Q1`, `Q2`, and agreed defaults.
5. **Open points:** anything left unresolved or out of scope.
6. **Suggested improvements:** see below.

## Suggest improvements

After the work, suggest a few improvements that would clearly help, such as
security hardening, test gaps, simpler designs, or outdated patterns near the
change. Keep them separate from the delivered work. Do not implement them
without approval.

Base each suggestion on evidence from the repository and on a reputable,
current source: official documentation, release notes, standards bodies
(for example OWASP), or well-maintained skills and guides from the tool or
framework authors. Check that the source applies to the versions in use.
Link the source. Say when a suggestion is your own judgement without one.

Prefer three strong suggestions over ten weak ones. Skip style preferences.
