## Genome source files (FASTA + GTF)

The uncompressed FASTA + annotation pair that
[`riboflow_genome`](https://github.com/DanielNguyener/riboflow_genome) feeds to
**Mode B** — the pipeline running `STAR --runMode genomeGenerate` itself, via
`example_build_index.yaml`.

| File | Contents |
|---|---|
| `genome.fa` | **chrM** — human mitochondrial chromosome, 16,569 bp, GENCODE GRCh38 primary assembly |
| `genome.gtf` | Minimal 3-line annotation (one gene / transcript / exon spanning all of chrM) |

Both must stay **uncompressed** — `genomeGenerate` does not accept `.gz` input.