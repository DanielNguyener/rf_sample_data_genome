## Paired-end RNA-seq test data

`SRR1039508/SRR1039508_all_{1,2}.fastq.gz` — 50,000 read pairs, 63 bp, human.

Used by `example_rnaseq_pe.yaml` in
[`riboflow_genome`](https://github.com/DanielNguyener/riboflow_genome) to exercise the
paired-end RNA-seq genome path. Everything else that example needs (a genome index, the
ribo-seq passenger, the rRNA filter) comes from the standard reference set — this pair
is the only PE-specific input.

### Source

| | |
|---|---|
| Run | [SRR1039508](https://www.ebi.ac.uk/ena/browser/view/SRR1039508) |
| Study | [GEO GSE52778](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE52778) |
| Publication | Himes *et al.* 2014, *PLoS ONE* 9(6):e99625 — dexamethasone in airway smooth muscle |
| Layout | Paired-end, 63 bp, unstranded, **no UMIs** |

### How the subset was made

`make_subset.sh --unfiltered` streams the first 2,000,000 read pairs of each mate from
ENA and keeps the first 50,000 — no selection applied, so the alignment rate against a
real genome is representative. Taking the *first* N records rather than sampling makes
it deterministic: rerunning reproduces byte-identical FASTQ payloads.

The script's default (no flag) instead pre-selects reads that align to chrM. That mode
existed for a retired chrM-only genome index; the resulting set is 100% mitochondrial
and is **not** appropriate against a real genome.

### Notes for use

- **No UMIs.** `example_rnaseq_pe.yaml` declares the first 6 bp of R1 as a pseudo-UMI
  solely to exercise the `umicollapse` PE branch; the duplicate counts it produces are
  not biologically meaningful.
