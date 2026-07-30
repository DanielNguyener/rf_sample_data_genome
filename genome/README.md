## Genome — prebuilt STAR index

`star_index/` holds a prebuilt **STAR** index (`SA`, `SAindex`, `Genome`,
`chrNameLength.txt`, …). It is the single genome reference every example in
[`riboflow_genome`](https://github.com/DanielNguyener/riboflow_genome) reads:

```yaml
input:
  reference:
    genome: ./rf_sample_data_genome/genome/star_index
```

**The path names no chromosome, deliberately.** What is committed here is **chrM**
(16,569 bp, ~6 MB)

### Generation
`./make_index.sh` uses `./genome_source/genome.{fa,gtf}` and
derives `--genomeSAindexNbases` from the FASTA length:
