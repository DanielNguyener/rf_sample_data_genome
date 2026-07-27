## Paired-end RNA-seq test data

`SRR1039508/SRR1039508_chrM_{1,2}.fastq.gz` — 50,000 read pairs, 63 bp, human.

Used by `example_rnaseq_pe.yaml` in
[`riboflow_genome`](https://github.com/DanielNguyener/riboflow_genome) to exercise the
paired-end RNA-seq genome path. Every other file that example needs (the chrM STAR
index, the ribo-seq passenger, the rRNA filter) is already part of the standard
reference set — this pair is the only PE-specific input.

### Source

| | |
|---|---|
| Run | [SRR1039508](https://www.ebi.ac.uk/ena/browser/view/SRR1039508) |
| Study | [GEO GSE52778](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE52778) |
| Publication | Himes *et al.* 2014, *PLoS ONE* 9(6):e99625 — dexamethasone in airway smooth muscle |
| Layout | Paired-end, 63 bp, unstranded, **no UMIs** |

### How the subset was made

The reads are **not** a random sample: they are pre-selected to those that align to
**chrM**, because the genome index shipped in `../../genome` is chrM-only. A random
subsample would leave ~97% of reads unmapped and the test nearly signal-free.

`make_subset.sh` in this directory regenerates the files from the ENA original:

1. Stream the first 2,000,000 read pairs of each mate from ENA.
2. Align them as pairs to chrM with `bowtie2 --no-mixed --no-discordant --no-unal`
   (2.99% align concordantly — 59,747 pairs).
3. Keep the first 50,000 concordant pairs, preserving mate order.

Because step 1 takes the *first* N records rather than sampling randomly, the result
is deterministic — rerunning the script reproduces byte-identical FASTQ payloads.

### Notes for use

- Essentially all of these reads survive the pipeline's rRNA/tRNA filter step (only 3
  of 100,000 mates hit `human_rtRNA`), so the full 50k pairs reach STAR.
- **No UMIs.** `example_rnaseq_pe.yaml` declares the first 6 bp of R1 as a pseudo-UMI
  solely to exercise the `umicollapse` PE branch; the duplicate counts it produces are
  not biologically meaningful.
