---
name: dot-agents-code-optimisation
description: Review pull requests, branches, commits, or local diffs for evidence-backed performance, simplification, and reuse opportunities.
metadata:
  version: "0.1"
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
- the smallest safe fix direction;
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

Order confirmed findings by severity, then confidence:

- `P0`: severe cost (e.g. quadratic-or-worse on unbounded input, or an
  I/O pattern that scales with load) on a hot or user-facing path.
- `P1`: clear, measurable inefficiency or significant duplication with real
  maintenance cost.
- `P2`: concrete but limited-impact inefficiency or duplication.
- `P3`: minor dead code or low-impact cleanup; do not use for style.

Use this format for each finding:

```text
### [P1] Imperative, specific title
Location: path/to/file.ext:line
Current cost: What the code does today and why it is expensive or redundant
Benefit: Concrete, measurable improvement from fixing it
Evidence: Code and, for duplication, the other occurrence(s)
Verification: Check performed or deterministic falsification path
Minimal fix: Smallest safe direction
Confidence: High or Medium
```

After findings, report open questions, validation performed, review scope, and
residual risks. If there are no confirmed findings, say so explicitly and
identify any measurement or execution gaps. Never manufacture findings to fill
categories.
