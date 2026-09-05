# Worked examples

Packages built with the `salpa-node` skill, each with the record of its build: what the agent
was asked, where it stopped, what the user answered, and what `salpa validate` and `salpa smoke`
said. The package directory here is the source of truth; the Salpa Hub mirrors it, and an
installed Salpa finds it there.

| package | what it does | record |
|---|---|---|
| [`smiles_to_3d/`](smiles_to_3d/) | 3D conformers from SMILES as SDF — RDKit ETKDGv3 + MMFF94; every platform | [smiles-to-3d.md](smiles-to-3d.md) |
| [`ligand_pdbqt_meeko/`](ligand_pdbqt_meeko/) | docking-ready PDBQT ligands from an SDF — Meeko 0.8 + RDKit; every platform; chains after smiles-to-3d | [ligand-pdbqt-meeko.md](ligand-pdbqt-meeko.md) |
| — | six Hub nodes given sample input with `salpa-demo-data` (hello-world ×3, cloud stubs ×3) | [demo-data-hub-2026-09-05.md](demo-data-hub-2026-09-05.md) |
