## STAR genome index (for `DanielNguyener/riboflow_genome`)

This directory replaces upstream `mock_hg38` HISAT/Kallisto-oriented mock files from
[`ribosomeprofiling/rf_sample_data`](https://github.com/ribosomeprofiling/rf_sample_data)
with a **`STAR`** `genomeGenerate` directory (expected keys: `SA`, `SAindex`,
`Genome`, `chrNameLength.txt`, …).

The shipped default is mitochondrial-only (**chrM**, ~16 kb) built locally via:

`references_for_riboflow/genome/scripts/build_star_mini_index.sh`

(`--sjdbOverhang 28`, GENCODE GRCh38 FASTA/GTF.)

Point `example_local.yaml`:

```yaml
input:
  reference:
    genome: ./rf_sample_data/genome
```
