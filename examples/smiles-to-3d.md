# smiles-to-3d — the record of the build

The first package built with the `salpa-node` skill, 2026-09-05. The agent was Claude Code,
following `skills/salpa-node/SKILL.md` as written. This is what was asked, where it stopped, what
the user answered, and what the tools said. The package is `examples/smiles_to_3d/`; the same
files are mirrored on the Salpa Hub as `smiles-to-3d` 0.1.0.

## The request

*A small, all-platform node with tiny real demo data, useful in a ligand-preparation pipeline,
to serve as the worked example for the skill.*

## Phase 1 — Understand

The agent proposed three candidates and investigated the first: a SMILES-to-3D node on RDKit.
`salpa add rdkit --dry-run --json` on a throwaway scaffold answered the platform question from
the channel index — builds for linux-64, osx-64, osx-arm64, win-64, and linux-aarch64 could be
added; BSD-3-Clause; no GPU, no weights, no runtime network.

**Checkpoint 1 — *build this?*** Presented: SMILES in (typed, or a file, one per line), hydrogens
added, one ETKDG conformer with a fixed seed, MMFF94 optimisation, an SDF out; GO; assumptions
named — one conformer by default with a parameter for more, an unparseable SMILES fails the node
rather than being skipped. Alternatives offered: sequence-properties (Biopython), pdb-contact-map
(MDAnalysis). **Answer: build smiles-to-3d as proposed.**

## Phase 2 — Build

No questions. In order:

1. `salpa new smiles-to-3d --yes -d … --category Chemistry --hashtags …`
2. Read every generated file, comments included.
3. `salpa add rdkit` — wrote the dependency and left the four declared platforms; then
   `salpa env install` (21 s, cache warm).
4. `core.py`: `read_smiles` (the `.smi` convention, `#` comments), `embed_conformers`
   (ETKDGv3 with a seed, MMFF94 minimise, energies), `process` (writes every conformer to one
   SDF with `SMILES`, `conformer_id`, `MMFF94_energy_kcal_mol` properties). RDKit imported
   inside the functions, so the parsing helpers import without it.
5. `node.py`: five parameters (SMILES text, SMILES file, conformers per molecule, random seed,
   output directory); `predecessor_data` used only to fill `data["smiles"]` when nothing else was
   given; an unparseable SMILES raised as an `input` error naming it.
6. `demo_data/ligands.smi`: ethanol, aspirin, caffeine.
7. `DEMO_CONFIG`: the file, one conformer, seed 42.
8. Tests replaced: atom counts hand-worked from the formulas (C2H6O → 9, C9H8O4 → 21,
   C8H10N4O2 → 24), refusal of a non-SMILES, same seed → same coordinates, every conformer
   written with a finite energy, the node end to end, no input fails loudly. 9 tests.
9. Ran it on the demo data and looked:

```
ethanol   CCO                          atoms=9   heavy=3   MMFF94=  -1.3369 kcal/mol
aspirin   CC(=O)Oc1ccccc1C(=O)O        atoms=21  heavy=13  MMFF94=  18.9098 kcal/mol
caffeine  Cn1cnc2c1c(=O)n(C)c(=O)n2C   atoms=24  heavy=14  MMFF94=-122.5284 kcal/mol
SDF records: 3 | titles: ethanol, aspirin, caffeine
ethanol C–O bond length: 1.420 Å (reference ~1.43 Å)
```

**Checkpoint 2 — *is this answer right?*** Presented the numbers above, the parameters the user
can change, and the decisions a domain expert might make differently: MMFF94 rather than UFF,
absolute rather than relative energies, hydrogens kept in the SDF, one conformer by default, an
unparseable SMILES failing the whole node. Said that automated checks cannot judge this, and that
on a yes the agent would verify and install without asking again. Alternatives offered: relative
energies, UFF. **Answer: yes, this is right.**

## Phase 3 — Verify and install

- `salpa validate --json` — 0 errors, 0 warnings, `import_checks: ran`
- `salpa smoke --json` — ran, success; refused a missing file; deterministic, idempotent,
  path-independent; no advisories
- `salpa platforms --solve --write` — linux-aarch64 added with its reason; the five resolve
  together
- tests — 9 passed
- `salpa push --copy --yes` into a running Salpa (dev build, 0.4.0 code), then the app's own
  installer from the shelf: **SMILES to 3D** appears in the palette under *Chemistry*

## What the build found in the tools — three findings, none in the node

1. **`salpa add rdkit` wrote `rdkit = ">=2017"`.** The channel index's `latest_version` is a
   string maximum; for rdkit that is `Release_2017_09` because R sorts after 2, while the channel
   holds 2026.03.5. Fixed in salpa-cli 0.15.1 (the floor now comes from the version list compared
   by numbers).
2. **`salpa platforms <dir>` was refused** — 0.14.0/0.15.0 took the directory only as `--path`,
   where every sibling verb takes a positional. The skill, and this agent, typed the positional.
   Fixed in 0.15.1; both spellings work.
3. **A stale developer pixi rejected the lock.** The dev machine's pixi was 0.63.1 against the
   app's pinned 0.73.0; `pixi run test` failed on "lock-file version 7 is newer than supported",
   and the app-side install failed the same way until the binary was re-seeded. The environment's
   own python ran the tests meanwhile. Not a node problem; a reminder that the app seeds its own
   pixi for a reason.

## Where the skill's text was thin

- It said `salpa platforms <pkg>`; that was right in intent and wrong for 0.15.0. Kept, now true.
- Checkpoint 2 for a "large output" case was not exercised: the SDF is 5 KB and the numbers fit
  on a screen. The rule for trajectories stands untested.
