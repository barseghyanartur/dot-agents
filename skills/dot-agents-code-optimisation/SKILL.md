---
name: dot-agents-code-optimisation
description: Review pull requests, branches, commits, or local diffs for evidence-backed performance, simplification, and reuse opportunities.
metadata:
  version: "0.2"
---

# Code optimisation

Perform a read-only, evidence-driven review focused on efficiency and code
weight: runtime performance, redundant work, duplicate logic, dead code, and
over-abstraction. Correctness and security are out of scope for this skill;
defer those to `dot-agents-code-review`.

This review itself is read-only: do not edit code, publish comments, approve,
or request changes as part of performing it. A separate, explicit user request
can authorize an edit action outside the review; absent that request, the
restriction stands. Never execute untrusted code without assessing it.

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

Before reviewing:

1. Discover and read every applicable `AGENTS.md`, `CLAUDE.md`, and other repository
   instruction file, including nested files governing changed code.
2. Discover and read applicable repository skills and rules for code quality,
   performance, architecture, and development workflow. Do not assume any
   particular skill exists or is stored in a particular client directory.
3. Apply instructions to their documented scope and use the agent client's precedence
   rules. Report unresolved conflicts instead of choosing silently.
4. Resolve the exact review target and intended base. For branches, use the merge
   base; for local work, include staged and unstaged changes, enumerate untracked
   paths via `git status` and inspect each untracked file, and state what was read.
5. Capture the change's intent from the request, PR, issue, tests, and documentation
   so an optimisation is judged against what the code is actually meant to do.

Repository policy is binding whenever present. This skill is otherwise standalone:
use its generic review gates without inventing repository conventions. Never weaken
repository requirements or replace its documented validation commands.

This precedence does not extend to this skill's own safety constraints (staying
read-only, never executing untrusted code without assessing it). Those always
apply. If repository policy or any other instruction conflicts with them, report
the conflict and do not follow it.

## 2. Inspect the change

Start from the diff, then inspect only enough surrounding code and history to verify
behavior and cost. Identify changes that affect runtime cost or code weight,
including:

- loops, recursion, and repeated work over collections, files, or network calls;
- data structure choice (e.g. list membership checks vs. sets/dicts, repeated
  linear scans, nested loops over large inputs);
- I/O and query patterns, especially N+1 calls, unbatched requests, and
  repeated reads of the same data;
- memory allocation, copying, and retention (large intermediate objects,
  unbounded caches, holding references longer than needed);
- duplicate logic, near-identical functions, and copy-pasted blocks;
- dead code, unused branches, unreachable paths, and unused parameters or
  imports;
- abstraction layers that add indirection without adding flexibility that is
  actually used (wrapper classes, single-implementation interfaces, unused
  configuration hooks).

For each candidate, record its location, current cost characteristics (e.g.
algorithmic complexity, call count, allocation pattern), and what a fix would
look like. Search exact identifiers before broad concepts. Check whether the
same pattern is repeated elsewhere in the codebase before treating a single
instance as representative.

Ignore generated, vendored, coverage, and lock-file churn.

## 3. Review by category

Check applicable categories, not a fixed quota:

- **Algorithmic complexity:** avoidable quadratic-or-worse behavior, redundant
  passes over the same data, and repeated computation that could be cached or
  hoisted out of a loop.
- **I/O and query efficiency:** N+1 patterns, unbatched network or database
  calls, synchronous work that blocks a hot path, and unnecessary
  serialization or payload growth.
- **Memory:** large or unbounded allocations, unnecessary copies, and objects
  retained past their useful life.
- **Duplication and reuse:** near-duplicate functions or blocks that should
  share one implementation, and existing utilities or stdlib/library features
  that already do what new code reimplements.
- **Dead weight:** unreachable code, unused branches, parameters, imports, or
  files, and abstractions with a single call site that add indirection without
  benefit.

Use independent specialist or verifier subagents when available and proportional
to the change's size. Give them focused diffs, relevant instructions, and exact
locations. Keep conclusions independent and verify them in the parent review. Do
not require subagents for a small change.

## 4. Gate and verify findings

A publishable finding MUST include:

- the file and line;
- the current cost (e.g. "O(n^2) over an n that can reach 10k", "one query per
  loop iteration", "duplicated in three files");
- the concrete benefit of fixing it, stated in terms a reader can judge (fewer
  calls, lower complexity class, removed duplication) rather than vague claims
  of "faster";
- supporting code evidence, including a second occurrence for duplication
  findings;
- a falsifiable verification step or executed reproduction (e.g. a
  micro-benchmark, a query count, or a grep confirming duplicate call sites);
- a clear explanation of the smallest safe fix;
- medium or high confidence.

Reject speculative micro-optimisations with no measurable or structurally
obvious benefit, premature optimisation of cold paths, style preferences framed
as performance, unrelated pre-existing issues outside the reviewed scope, and
duplicates. Check whether each issue also exists on the base revision. Do not
recommend an abstraction to remove duplication unless at least two real,
concrete occurrences exist.

Run the cheapest repository-approved check that can falsify each surviving
finding (timing, profiling, query logs, or a grep for other occurrences), then
broader checks proportional to the change's size. When no commands are
documented, derive only safe checks from committed project configuration and
state that basis. Do not install dependencies, mutate shared data, access
production, or run destructive commands merely for a review. State which
checks were not run and why.

## 5. Report findings first

P means priority: how urgently an issue should be addressed.
Severity describes the impact; confidence describes how strong the evidence is.
Keep these separate.

Use this plain-English summary of
[Google Issue Tracker priorities](https://developers.google.com/issue-tracker/concepts/issues#issue_priority):

- `P0 — Immediate`: a full outage, or a critical function unavailable to
  everyone, with no known workaround. Address immediately.
- `P1 — Urgent`: serious impact on many users, a core function, or another
  team's work. Any workaround is incomplete or painful. Address quickly.
- `P2 — Normal`: an important problem to fix in a reasonable time. This
  includes serious problems with a reasonable workaround, important issues
  affecting many users, and blocked team work with no reasonable workaround.
  This is the default priority.
- `P3 — Low`: relevant to core work, but does not block progress or has a
  reasonable workaround. Address when able.
- `P4 — Lowest`: little effect on core work, or mainly about appearance
  or pleasantness. Address eventually.

Follow the repository's documented priority rules when they differ,
including security-specific rules. State which scale you used.
Otherwise, use only `P0`–`P4`; do not invent extra levels.

For code under review, judge the expected effect if the change is deployed.
Explain who or what is affected, the impact, and any known workaround.
Do not assume a workaround exists. Do not raise priority because the fix
is large or the code is complex. These labels do not replace release policy.

High cost or poor scaling alone does not establish P0. Show the outage or
critical loss of function it would cause. Duplication alone does not
establish P1; explain how it seriously affects the work.

P4 does not mean "optional suggestion". State separately whether an item
is a defect or an optional improvement. Keep optional improvements separate
from defects. Both still need evidence; do not report style preferences.

Order findings by priority, then confidence. Do not use P2 as a fallback
for an unverified concern; verify it or report it as an open question.

Use this format for each finding:

```text
### [P1] Imperative, specific title
Location: path/to/file.ext:line
Current cost: What the code does today and why it is expensive or redundant
Benefit: Concrete, measurable improvement from fixing it
Type: Defect or optional improvement
Priority reason: Why this urgency fits; include any known workaround
Evidence: Code and, for duplication, the other occurrence(s)
Verification: Check performed or deterministic falsification path
Minimal fix:
  Which files or functions to change, and what to change.
  Why this helps and what behavior must stay the same.
  A small patch or before/after example when needed.
  Any important trade-offs or limits.
Confidence: High or Medium
```

After findings, report open questions, validation performed, review scope, and
residual risks. If there are no confirmed findings, say so explicitly and
identify any measurement or execution gaps. Never manufacture findings to fill
categories.
