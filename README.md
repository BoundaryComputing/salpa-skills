# Salpa skills

Procedures for coding agents that build [Salpa](https://salpa.app) nodes with
[`salpa-cli`](https://pypi.org/project/salpa-cli/). A node is a step in a computational molecular
science workflow; this repo is how you get one **without writing it yourself**: describe what it
should do, and an agent builds, verifies and installs it, stopping to ask you exactly twice.

## What is here

| skill | does |
|---|---|
| [`salpa-node`](skills/salpa-node/SKILL.md) | Build a working node from a description — investigate the tool, scaffold, implement, verify with `salpa validate` and `salpa smoke`, install into your running Salpa. |
| [`salpa-demo-data`](skills/salpa-demo-data/SKILL.md) | Give an existing package the sample input it lacks — real `demo_data` and a `DEMO_CONFIG` for every node `salpa validate` flags, then prove each runs with `salpa smoke`. |

Two skills, deliberately. Others will be added only when they earn their place — the second
was added because 25 of the Hub's 47 nodes lacked sample input, which is a procedure, not knowledge.

## Install

Skills are plain markdown. Copy the directory into wherever your agent reads skills from:

| agent | reads |
|---|---|
| Claude Code, OpenCode, Grok Build, Goose | `.claude/skills/` in the project (or `~/.claude/skills/`) |
| pi, Qwen Code | `.agents/skills/` in the project |

```bash
git clone https://github.com/BoundaryComputing/salpa-skills
cd your-project
../salpa-skills/install.sh .          # copies skills/ into .claude/skills/ and .agents/skills/
```

Then ask your agent for a node in plain words — *"a node that takes a SMILES string and writes a
3D conformer as SDF"* — and answer its two questions when they come.

## Prerequisites

- `pip install salpa-cli` — the scaffolding and verification tool the skill drives
- [pixi](https://pixi.sh) — the Salpa app seeds one; otherwise install it
- a running Salpa app, for the final install step

## How it works, and what it does not do

The skill carries **procedure, not knowledge**. Everything about what a node *is* — its files,
its parameters, how it is tested, which platforms it can declare — lives in `salpa docs`, in the
comments of the scaffold `salpa new` generates, and in the hints `salpa validate` prints. Those
three ship with the CLI and stay current; the skill points at them and does not restate them, so
it cannot drift from them.

It is **attended**. The agent stops at two points where only you can answer: *is this the right
thing to build?* and, after the first working run, *is this answer right?* Automated checks prove
that a node runs, fails on bad input, and repeats; they cannot prove the science is correct. You
can. On a yes it verifies and installs without asking again; if you go quiet, it waits.

## A worked example

[`examples/`](examples/) holds packages built with these skills, each with the record of its build.
It is also published on the [Salpa Hub](https://github.com/BoundaryComputing/salpa-hub), which is
where an installed Salpa finds it.

## License

Apache 2.0, the same as `salpa-cli`.
