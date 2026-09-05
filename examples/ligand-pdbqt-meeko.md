# ligand-pdbqt-meeko — the record of the build

The second package built with the `salpa-node` skill, 2026-09-05, and the first the user
asked for: *"Ligand PDBQT via Meeko (SDF in, PDBQT out)"*, chosen from four candidates as the
node they actually wanted. Agent: Claude Code, following `skills/salpa-node/SKILL.md`.

## Phase 1 — Understand

`salpa add meeko rdkit --dry-run --json` on a throwaway scaffold: meeko 0.8.0 on conda-forge,
noarch (pure Python), LGPL-2.1-only; rdkit 2026.03.5; together they build for linux-64,
osx-64, osx-arm64, win-64, and linux-aarch64 could be added. No GPU, no weights, no runtime
network.

**Checkpoint 1 — *build this?*** Presented: SDF of 3D ligands in (typed, or carried from
`smiles-to-3d`), one PDBQT per record named by its title, Gasteiger charges and AutoDock atom
types via Meeko's `MoleculePreparation`; GO; assumptions — hydrogens added with coordinates when
missing and reported, macrocycles flexible by default with a rigid switch (AutoDock4 needs it),
a record Meeko cannot prepare fails the node naming it. Alternative offered: skip and report.
**Answer: build it as proposed.**

## Phase 2 — Build

1. `salpa new ligand-pdbqt-meeko --yes …`; read every file.
2. `salpa add meeko rdkit` (wrote `meeko = ">=0.8"`, `rdkit = ">=2026"`), `salpa env install`.
3. **Probed the API inside the package's own environment before writing the node**: Meeko
   0.8's `MoleculePreparation().prepare(mol)` and `PDBQTWriterLegacy.write_string(setup)`,
   and its keyword switches (`rigid_macrocycles`, `hydrate`, `flexible_amides`).
4. Demo data: `demo_data/ligands.sdf`, **produced by running the `smiles-to-3d` example on its
   own demo data** (seed 42) — not hand-written, so it is exactly what the upstream node emits.
5. `core.py`: `read_sdf` (a record RDKit cannot read is refused by position), `ensure_hydrogens`
   (adds them with coordinates and says so; a record with no 3D coordinates is refused),
   `prepare_pdbqt`, `process` (one `<name>.pdbqt` per record, duplicates numbered).
6. `node.py`: the SDF parameter, three Meeko switches, output directory; with the parameter
   blank it takes the SDF carried under `sdf_file` or `output_file` — what `smiles-to-3d`
   forwards — and forwards `pdbqt_files` for a docking node.
7. Tests, expectations hand-worked from AutoDock's rules: PDBQT atoms = heavy + polar H
   (ethanol 4, aspirin 14, caffeine 14), TORSDOF (1, 4, 0), neutral charge sums, hydrogens
   added for an H-less input giving the same PDBQT, a 2D record refused, the chained input
   path. 9 tests.
8. Ran it and looked:

```
ethanol   pdbqt_atoms=4   from 9   torsions=1  charge=-0.001
aspirin   pdbqt_atoms=14  from 21  torsions=4  charge=+0.000   (4 BRANCH blocks)
caffeine  pdbqt_atoms=14  from 24  torsions=0  charge=+0.002
```

**A hand-worked expectation corrected, with the reason.** The agent first counted aspirin at 3
torsions by treating the ester's C(=O)–O bond as amide-like. It is an ester; AutoDock's amide
rule does not apply, and Meeko counts 4. The expectation was fixed *because the rule had been
misapplied*, not because the tool disagreed — the distinction the skill draws.

**Checkpoint 2 — *is this answer right?*** Presented the numbers, the file layout (REMARK
SMILES, ROOT, BRANCH), and the decisions an expert might make differently: no protonation-state
handling (aspirin's acid stays neutral; a pH step belongs upstream), amides rigid by default,
Gasteiger charges, files named by title. Alternative offered: a protonation option.
**Answer: yes, this is right.**

## Phase 3 — Verify and install

- `salpa validate --json` — 0 errors; `import_checks: ran` (the one warning was the test
  run's `__pycache__`, removed)
- `salpa smoke --json` — ran, success; refused a missing file; deterministic, idempotent,
  path-independent
- `salpa platforms --solve --write` — linux-aarch64 added; the five resolve together
- tests — 9 passed
- `salpa push --copy --yes` into the running dev app, then the app's own installer:
  **Ligand PDBQT (Meeko)** in the palette under *Docking*, beside metaldock's MGLTools-based
  *Ligand PDBQT* — which is the point.

## What this build found

Nothing in the tools this time: the two edges the first build hit were already fixed in
salpa-cli 0.15.1, and `salpa platforms <dir>` worked as the skill says. What it exercised
that the first build did not: a dependency pair, an API probed before use, demo data produced
by another node, and the chained-input path.
