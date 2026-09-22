---
name: dot-agents-code-review
description: Review pull requests, branches, commits, or local diffs for evidence-backed defects and security risks.
metadata:
  version: "0.2"
---

# Code review

Perform a read-only, evidence-driven review. Prioritize correctness, security,
compatibility, and missing behavioral coverage over style or optional refactoring.

Do not edit code, publish comments, approve, or request changes unless the user
explicitly asks. Never expose secrets or execute untrusted code without assessing it.

## 1. Establish authority and scope

Before reviewing:

1. Discover and read every applicable `AGENTS.md`, `CLAUDE.md`, and other repository
   instruction file, including nested files governing changed code.
2. Discover and read applicable repository skills and rules for code quality,
   security, architecture, testing, documentation, and development workflow. Do not
   assume any particular skill exists or is stored in a particular client directory.
3. Apply instructions to their documented scope and use the agent client's precedence
   rules. Report unresolved conflicts instead of choosing silently.
4. Resolve the exact review target and intended base. For branches, use the merge
   base; for local work, include staged and unstaged changes, enumerate untracked
   paths via `git status` and inspect each untracked file, and state what was read.
5. Capture the change's intent from the request, PR, issue, tests, and documentation.

Repository policy is binding whenever present. This skill is otherwise standalone:
use its generic review gates without inventing repository conventions. Never weaken
repository requirements, redefine its definition of done, or replace its documented
validation commands.

## 2. Inspect the change

Start from the diff, then inspect only enough surrounding code and history to verify
behavior. Identify changes to observable contracts, including:

- APIs, events, schemas, serialization, and persisted data;
- configuration, defaults, feature flags, deployment, and dependencies;
- authentication, authorization, ownership, privacy, and secret handling;
- concurrency, retries, timeouts, ordering, cancellation, and resource lifecycle;
- exported interfaces, exceptions, and caller-visible semantics.

For each changed contract, record its old and new behavior, exact identifiers,
owner, and plausible consumers. Search exact identifiers before broad concepts.
Inspect another repository only when a changed contract or known boundary makes it
a plausible consumer. Record meaningful hits and relevant verified no-match results.

Ignore generated, vendored, coverage, and lock-file churn unless it creates a build,
dependency, integrity, or supply-chain risk.

## 3. Review by risk

Check applicable risks, not a fixed quota of categories:

- **Correctness:** reachable edge cases, validation, state transitions, error paths,
  and behavior inconsistent with stated intent.
- **Security and privacy:** trust boundaries, injection, authn/authz, tenant or user
  scoping, unsafe deserialization, sensitive data, secrets, and dependency risk.
- **Compatibility:** callers and consumers of changed API, schema, event, config,
  storage, or library contracts.
- **Reliability:** partial failure, retries, idempotency, races, deadlocks, ordering,
  cancellation, cleanup, and timeout behavior.
- **Performance:** hot-path amplification, blocking work, unbounded input or memory,
  excessive calls or queries, and payload growth.
- **Tests:** missing coverage only when it leaves a concrete changed behavior or
  failure mode unverified.

Use independent specialist or verifier subagents when available and proportional to
the change's risk. Give them focused diffs, relevant instructions, contract evidence,
and exact consumer hits. Keep conclusions independent and verify them in the parent
review. Do not require subagents for a small, low-risk diff.

## 4. Gate and verify findings

A publishable finding MUST include:

- the changed file and line;
- a reachable trigger or state;
- the resulting failure and concrete impact;
- supporting code or contract evidence;
- a falsifiable verification step or executed reproduction;
- the smallest safe fix direction;
- medium or high confidence.

Reject style preferences, speculative risks, unrelated pre-existing defects,
duplicates, and issues prevented by existing guards, types, tests, framework behavior,
or deployment configuration. Check whether each issue also exists on the base revision.

Run the cheapest repository-approved check that can falsify each surviving finding,
then broader checks proportional to the blast radius. When no commands are documented,
derive only safe checks from committed project configuration and state that basis.
Inspect commands from changed branches before running them. Do not install dependencies,
mutate shared data, access production, start paid services, or run destructive commands
merely for a review. State which checks were not run and why.

## 5. Report findings first

Order confirmed findings by severity, then confidence:

- `P0`: catastrophic and release-blocking.
- `P1`: likely serious production, security, or data impact.
- `P2`: concrete defect with limited impact.
- `P3`: concrete low-impact defect; do not use for style.

Use this format for each finding:

```text
### [P1] Imperative, specific title
Location: path/to/file.ext:line
Trigger: Exact input, state, or sequence
Failure: What happens and why
Impact: User or system consequence
Evidence: Changed code and relevant caller or consumer evidence
Verification: Check performed or deterministic falsification path
Minimal fix: Smallest safe direction
Confidence: High or Medium
```

After findings, report open questions, validation performed, review scope, and
residual risks. If there are no confirmed defects, say so explicitly and identify any
testing or execution gaps. Never manufacture findings to fill categories.
