# Six Hub nodes get their sample input — the record of the `salpa-demo-data` skill's first use

2026-09-05. Agent: Claude Code, following `skills/salpa-demo-data/SKILL.md`. The request: the
cheap half of the Hub's `demo_data` gap — hello-world-pipeline (3 nodes) and the three cloud
stubs without a sample (evo2, boltz2, chai1). The hard half (metalparm 11, pdbmdauto 7) was
deferred by decision.

## Measure first

`salpa validate --json` on each package: `H4` on all six nodes. Reading each node's `execute()`
decided what a sample had to be:

| node | reads | sample | where it came from |
|---|---|---|---|
| hello_encrypt | text + a number | `DEMO_CONFIG`: *Hello from Salpa!*, shift 3 | the node's own default message |
| hello_decrypt | `<case>_encrypted.txt` from `input_dir` | `demo_data/demo/demo_encrypted.txt` = *Khoor iurp Vdosd!* | **written by running hello_encrypt**, not typed |
| hello_reveal | both files from `input_dir` | the pair, `demo_data/demo/` | written by running encrypt then decrypt |
| cloud_gcp_evo2 | a DNA sequence or file | `demo_data/lac_operator.fasta`, E. coli lac operator O1 (21 bp) | textbook sequence, verifiable by eye (near-palindrome) |
| cloud_modal_boltz2 | a protein sequence (text) | `DEMO_CONFIG`: Trp-cage `NLYIQWLKDGGPSSGRPPPS`, `msa_mode = "empty"` | PDB 1L2Y, 20 residues |
| cloud_modal_chai1 | FASTA text | `DEMO_CONFIG`: `>protein\|name=trp-cage` + the same sequence | PDB 1L2Y |

No question was asked: every package already told its story (hello-world's default message;
the diffdock stub already ships `trp_cage_1L2Y.pdb`), and a sequence from a public database is
sourced, not invented. A first draft of the evo2 sample was a longer gene fragment the agent
could not vouch for letter by letter; it was replaced by one it could.

## What the tools said

- `salpa validate`: `H4` gone on all six; no errors; the cloud stubs keep a pre-existing `H3`
  (no README) that this skill does not touch.
- `salpa smoke` on hello-world (with an SDK python): decrypt and reveal **ran green** —
  deterministic, idempotent, path-independent. encrypt was **not checked**: it has no file
  parameter, so smoke refused to run it without `demo_data/`, while `validate` no longer
  asked for one. **The two tools disagreed about the same node.** Fixed in salpa-cli 0.15.2:
  one function, `validate.needs_demo_file`, now answers for both, and encrypt runs from its
  declaration (all three ok).
- `salpa smoke` on the cloud stubs, with the app's `cloud-client` environment: each reaches
  the gateway and stops — *"Cloud authentication required. Please sign in to use cloud
  nodes."* Expected, and said so in each `demo_data/README.md`. With the SDK-only python they
  fail earlier on a missing `requests`, which is the environment's fault, not the node's.

## Shipped

hello-world-pipeline 1.0.3 (nodes 1.0.2), cloud-gcp-evo2 / cloud-modal-boltz2 /
cloud-modal-chai1 1.0.3 — in their source repos, their bundled copies, and on the Salpa Hub
with provenance stamped. The sync guard between the bundled and published copies passed.

## What the skill's first use found

A skill followed literally is a consistency test of the tooling it drives. This one found that
`H4` and `smoke` had different ideas of "a node with nothing to run on", which no unit test
had, because each was tested against its own definition. Same lesson as the first build's two
findings, different pair of tools.
