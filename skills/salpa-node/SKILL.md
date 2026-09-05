---
name: salpa-node
description: Build a working Salpa node from a description of what it should do — investigate the tool, scaffold with salpa-cli, implement, verify with `salpa validate` and `salpa smoke`, and install it into the user's running Salpa. Attended: the user answers two questions and nothing else.
---

# Build a Salpa node

You do the technical work. The user makes **two** decisions and is not troubled with anything else.

## The two checkpoints, and why exactly two

Stop and ask **only** where the user's judgement cannot be replaced by yours or by a tool:

| # | after | the question | why it must be theirs |
|---|---|---|---|
| **1** | investigating | *is this the right thing to build?* | Only they know what they actually want. Getting this wrong wastes everything after it. |
| **2** | the first working run | *is this answer correct?* — and on a yes, you verify and install without asking again | **They are the oracle.** No check you can run knows whether the science is right. Installing into their own app needs no separate stop once they have judged the answer. |

Everywhere else, decide for yourself and keep going. Dependency choices, file layout, parameter
types, error handling, test design, how to fix a `validate` finding — these are yours. Asking about
them is not caution; it is offloading work onto someone who came here to avoid it.

The test for whether something is a checkpoint: *would a wrong answer here waste the following
phase, and can only the user supply it?* If not, decide.

**If the user goes quiet, wait.** Say what you are waiting for and stop. Never fall through to an
unattended guess at the science: that is a different product, and it is not this one.

## Never restate the contract

The node contract is documented in three places that ship with `salpa-cli` and stay current. Read
them; do not reproduce them here or in your own words:

- **`salpa docs`** — start with `node-package-structure`, then `node-parameters`,
  `testing-and-loading-your-node`, `dependencies-and-platforms`, `multi-node-packages`,
  `publishing-to-your-app`, `machine-readable-output`.
- **The scaffold you generate.** Read `node.py` and `core.py` top to bottom before editing,
  comments included. The 3-stage import block and the `stream_log` calls are load-bearing;
  `salpa docs node-package-structure` says why.
- **`salpa validate` findings.** Each carries a `hint` written for exactly this situation. Follow
  the hint; do not invent a different fix.

If those three disagree with anything you remember about Salpa, they are right and you are stale.

## Prerequisites — check, do not assume

`salpa --version` (install with `pip install salpa-cli` if absent), `pixi --version` (the Salpa
app seeds one; otherwise https://pixi.sh), and for the last step a running Salpa app. If one is
missing, say which and stop; do not work around it.

---

## Phase 1 — Understand

**Goal: know what to build, and whether it can be built, before writing anything.**

1. Establish what the node should do: its inputs, its outputs, and what a *correct* result looks
   like. If the description is ambiguous about an observable — units, which of two conventions,
   what counts as an item — resolve it now. Ambiguity here surfaces later as a node that runs and
   is wrong.
2. Identify the underlying tool or library. Prefer a maintained package over reimplementing: a
   wrapper around the real tool is the point of a node.
3. Check it is obtainable — on conda-forge or PyPI, and for which platforms. `salpa add` and
   `salpa platforms` answer the platform question from the channel index; do not guess it.
4. Note anything that could stop this working: a licence, a compiler, model weights, a GPU,
   network access at runtime.
5. If the request is genuinely several steps that pass data along a chain, say so now and propose
   the split; do not silently build one node that does three things.

Then **stop** and present, briefly and without jargon:

- what the node will do, in one or two sentences
- what it takes in and gives back
- what it is built on, and whether that is free and installable — and on which platforms
- **GO / CAUTION / NO-GO**, with the one thing that makes it a caution if it is one
- anything you had to assume

Ask for a go-ahead or a correction. **Do not scaffold before you have it.**

---

## Phase 2 — Build

**Goal: a node that runs and produces a result the user can judge.**

No questions in this phase. Work.

1. **Scaffold — do not hand-write the package.**
   `salpa new <kebab-name> --yes -d "<description>" --category "<...>" --hashtags "..."`
   Use `-t multi-node-package` only for the split agreed at checkpoint 1.
2. **Read every generated file** before changing it, comments included.
3. **Declare dependencies with `salpa add <package> ...`**, never by editing `pixi.toml` by hand.
   It finds each package in the declared channels, narrows `platforms` to what can run all of them
   with a reason per change, and solves once. Then `salpa env install`. Nothing meaningful can be
   checked until this succeeds.
4. **Implement** — the real computation in `core.py`, the Salpa wrapper in `node.py`. Keep
   `core.py` free of Salpa imports so it stays testable on its own.
5. **The node must work standalone.** Its parameters are its interface: someone must be able to
   run it by supplying parameters alone, with no upstream node. `predecessor_data` is extra
   freedom, never a requirement. This single rule is the difference between a package where most
   nodes are verifiable and one where most are not.
6. **Provide real `demo_data/`.** One small, genuine input. Replace the placeholder. If you must
   generate it, generate something realistic and say how you made it.
7. **Declare `DEMO_CONFIG`** in `node.py` so the node can be run automatically against that input.
8. **Replace the scaffolded tests** with tests of the actual behaviour, including at least one
   hand-worked case whose expected value you computed yourself rather than copied from your own
   output.
9. **Run it on the demo data** and look at the result yourself first. If it is obviously wrong,
   fix it — do not present a result you do not believe.

Then **stop** and show the user:

- **the actual output** for the demo input. If it is a number or a short table, show it. If it is
  a file too large to show — a trajectory, a structure with thousands of atoms — show where it is,
  its size, and **one or two numbers derived from it that a domain expert can check** (an atom
  count, an energy, a distance), and say how you derived them.
- what the input was
- which parameters they can change, in plain language
- anything you had to decide that a domain expert might decide differently

Ask plainly: **is this answer right?** Say explicitly that automated checks cannot answer this and
that you need their judgement, and that on a yes you will verify and install without asking again.
If they say it is wrong, fix and show again.

---

## Phase 3 — Verify and install

**Goal: it is not merely right once — it is well-formed, repeatable, honest about failure, and in
their app.**

No questions in this phase. Iterate against the tools until they are clean.

1. `salpa validate --json <pkg>` — fix every **error**. Fix warnings unless a warning is wrong for
   this node, and say which and why if you leave one.
   **`errors: 0` is not enough:** if `import_checks` is not `"ran"`, nothing deep was checked at
   all — build the environment and run it again.
2. `salpa smoke --json <pkg>` — the node must run on its own `demo_data`, **fail** when its input
   is missing, and be deterministic, idempotent and path-independent.
   **A skipped run is not a passing run.** If `skipped` is set, fix the cause. A failing node's
   verdict carries its whole exception and an `stderr_tail`; read them before changing anything.
3. `salpa platforms <pkg>` — the declared list matches the evidence, or you know why not.
4. `pixi run test` — tests pass, and none are skipped.
5. When a check fails, fix **the code**, never the test or the demo data. Changing what you are
   measured against is not a repair.
6. `salpa push <pkg>` puts it into their running Salpa. Confirm it is there and tell them where
   to find it. If Salpa is not running, say so and wait — do not try to start it.

Then report, in one short block:

- what passed, and that the import checks actually ran
- anything you deliberately left, and why
- what this does and does not prove — that it runs correctly and repeatably; correctness of the
  science rests on their judgement at checkpoint 2
- where it is in their app

---

## If things go wrong

- **The tool cannot be installed** (no build for their platform, needs a licence, needs a GPU they
  do not have) — stop and say so at Phase 1. Do not build a node that cannot run.
- **A dependency will not solve** — try a relaxed constraint or an alternative package. If it still
  fails, report exactly what the solver said; do not silently drop the dependency and reimplement
  it.
- **You cannot make a check pass** — say which check, what you tried, and what you think is wrong.
  A truthful "this fails and here is why" is worth more than a package that passes because you
  weakened the test.
- **Salpa is not running at install time** — say so and wait.

## Do not

- Ask the user to choose a dependency, a parameter type, a file name, or a fix.
- Present a result you have not looked at yourself.
- Report a green check without saying whether the import checks actually ran.
- Edit tests or `demo_data/` to make a failing check pass.
- Claim the node is *correct* on the strength of `validate` and `smoke`. They prove it runs.
- Guess at the science when the user is silent.
