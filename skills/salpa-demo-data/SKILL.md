---
name: salpa-demo-data
description: Give an existing Salpa node package the sample input it lacks — real demo_data and a DEMO_CONFIG for every node `salpa validate` flags — then prove each node runs on it with `salpa smoke`. Attended; asks only when the science of a sample is genuinely the user's call.
---

# Add demo data to an existing package

A node without sample input cannot be run by a reviewer, a test, or the app's own checks. This
skill closes that gap for a package that already exists. It is procedure only: what a node is,
how `DEMO_CONFIG` is read, and what counts as sample input all live in `salpa docs` and in
`salpa validate`'s hints. Do not restate them; follow them.

## What you stop for

Stop **only** when a sample's science is the user's to decide — which protein, which ligand,
which sequence — *and* the package gives no clue. A package whose README, tests, or other
nodes already name a molecule or a structure has told you; use that and do not ask. Everything
else — file names, formats, the size of the sample, how to declare it — is yours.

If the user goes quiet, wait. Never invent a sample you cannot vouch for.

## Procedure

1. **Measure first.** `salpa validate --json <pkg>` and read every `H4` finding: that is the
   list. Nothing else in the package is yours to change. Note which nodes have a **file or
   folder parameter** and which are driven by **text and numbers only** — the two need
   different things:
   - a file/folder parameter needs a real file (or directory) in that node's `demo_data/`;
   - a text-only node needs a `DEMO_CONFIG` whose values are real; `demo_data/` may hold the
     same sample as a file for a human to read, but it is the declaration that runs.
2. **Read the node before choosing a sample.** `execute()` says what it reads — a file name it
   composes from `case_name`, a directory it expects a particular file in, a sequence it
   validates. The sample must satisfy *that*, not a general idea of the format. A node that
   reads `<case>_encrypted.txt` from `input_dir` needs a `demo_data/<case>/` holding exactly
   that file, produced the way the upstream node would produce it.
3. **Use a real sample, and say where it came from.** Prefer one the package already uses
   elsewhere (its README, its other nodes, its tests) so the package tells one story. A
   sequence or structure from a public database is real; state its identifier. If a sample has
   to be *produced* by running an upstream node, run it and keep what it wrote — do not fake
   its output by hand.
4. **Keep it small.** It ships inside the package. Kilobytes, not megabytes.
5. **Declare `DEMO_CONFIG`** in `node.py` with the values that make the node run on that
   sample: paths as `demo_data/...`, and every scalar the node needs. A parameter's type gives
   its shape and never its value, so every value is yours to write down.
6. **`demo_data/README.md`**: one paragraph — what the sample is, where it came from, and the
   hand-checkable fact about it (a length, a count, a known answer) that a reviewer can verify
   without running anything.
7. **Prove it.** `salpa validate --json` must show no `H4` for the nodes you touched.
   `salpa smoke --json` must run each of them on the sample. A node that talks to a paid
   service or needs credentials will fail to *execute* under smoke; that is expected — say so
   in the README, and keep the declaration, because `validate` and a reviewer still need it.
   Do not weaken `DEMO_CONFIG` to make smoke pass; smoke is reporting the node's real needs.
8. **Version and ship.** A package that gains sample input has changed: bump its version, run
   the package's own tests if it has any, and publish through the route the package came
   from. If the package has a bundled copy elsewhere, change both; a guard usually checks.

## Then report

For each node: what the sample is and where it came from, the `DEMO_CONFIG` you declared, and
what `validate` and `smoke` said — including a smoke failure that is expected and why. What
you did not change.

## Do not

- Ask the user to name a file, a format, or a `DEMO_CONFIG` value.
- Invent a sequence, a structure, or a molecule you cannot source.
- Hand-write a file that an upstream node is supposed to produce.
- Edit a node's `execute()` to accept the sample; the sample serves the node, not the reverse.
- Report `validate` clean without saying whether `smoke` ran the node.
