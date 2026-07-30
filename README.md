# Sample Data for RiboFlow

All files and references herein are coming from the human genome.

The files in this repo are small subsets of the originally published data.

## Required and Optional Files

Not all files are required by RiboFlow. 

## Fastq

  1) Ribosome profiling with UMIs, plus matched RNA-Seq: (GSM8325903, GSM8325907 ribo;
  GSM8325891, GSM8325895 RNA-Seq). Sourced from [NCBI GEO accession number GSE269734](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE269734)
published in [Liu et. al](https://doi.org/10.1038/s41587-025-02718-5). One `.fastq.gz` each containing preselected reads
  aligning to the shipped reference.
  
 
  2) Bulk ribosome profiling and RNA-Seq data: (GSM1606107, GSM1606108 ribo; GSM1606099,
  GSM1606100 RNA-Seq). Sourced from
[NCBI GEO accession number GSE65778](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE65778)
published in 
[Sidrauski et. al](https://elifesciences.org/articles/05033).  

  3) Paired-end RNA-Seq: `fastq/rnaseq_pe/SRR1039508/` sourced from
[NCBI GEO accession number GSE52778](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE52778)
published in [Himes et. al](https://doi.org/10.1371/journal.pone.0099625).

## Annotation

The tsv file contains transcript lengths.
The bed file contains region boundaries; CDS, 5'UTR and 3'UTR.


## Metadata

Contains metadata for the ribo files in yaml format — `GSM1606107.yml`, `GSM1606108.yml`
and `ing_hek293.yaml`, covering the GSE65778 samples.

## Transcriptome Reference

Bowtie2 index files for the transcriptome.
The actual output of the RiboFlow pipeline, i.e., ribo files, is obtained using the reads that are mapped to the transcriptome reference.


## Filter

Bowtie2 index coming from the 
filter sequences which are mainly ribosomal and tRNAs.


## Genome

`genome/star_index/` — a prebuilt **STAR** index of human **chrM**.
```yaml
input:
  reference:
    genome: ./rf_sample_data_genome/genome/star_index
```
See `genome/README.md`.

## Genome Source

`genome/genome_source/genome.{fa,gtf}` — the uncompressed FASTA + annotation the index
above was built from, currently chrM. `example_build_index.yaml` feeds them to the
pipeline's build-from-FASTA path (Mode B, `STAR --runMode genomeGenerate`), which writes
back to `genome/star_index/`:

```yaml
input:
  reference:
    genome_fasta: ./rf_sample_data_genome/genome/genome_source/genome.fa
    gtf:          ./rf_sample_data_genome/genome/genome_source/genome.gtf
```



_Genomic Reference is an optional parameter for RiboFlow, but it is required by
`riboflow_genome` whenever the genome path is enabled (`genome.run: true`, the default)._
