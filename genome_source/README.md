## Genome source files (FASTA + GTF)

The uncompressed FASTA and annotation that the pre-built STAR index in `../genome`
was generated from. They are shipped separately so that
[`riboflow_genome`](https://github.com/DanielNguyener/riboflow_genome) can also
demonstrate **Mode B** — letting the pipeline run `STAR --runMode genomeGenerate`
itself — via `example_chrM_build_index.yaml`.

| File | Contents |
|---|---|
| `chrM.fa` | Human mitochondrial chromosome (chrM, 16,569 bp), GENCODE GRCh38 primary assembly |
| `chrM.gtf` | Minimal 3-line annotation (one gene / transcript / exon spanning all of chrM) |

Both must stay **uncompressed** — STAR's `genomeGenerate` does not accept `.gz`
FASTA or GTF input.

chrM is used because it is small enough that `genomeGenerate` finishes in seconds.
It exercises the index-building code path only; for real analyses build an index
from the full assembly (see "Building the STAR genome index" in the pipeline README).

Because the genome is tiny, `genomeGenerate` requires
`--genomeSAindexNbases 7` (passed via `star.index_args` in the example params
file). Full-size genomes should omit that flag.
