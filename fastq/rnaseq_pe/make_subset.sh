#!/usr/bin/env bash
# Regenerate SRR1039508_chrM_{1,2}.fastq.gz from the ENA original.
#
# Two modes:
#
#   ./make_subset.sh                    # chrM-selected (default)
#   ./make_subset.sh --unfiltered       # plain first-50k pairs, no selection
#
# chrM-selected exists only because the sample data ships a chrM-ONLY STAR index; a
# random subset would leave ~97% of reads unmapped. If you are benchmarking or
# analysing against a REAL human genome index, use --unfiltered: the chrM-selected
# set is 100% mitochondrial and is a biased, unrepresentative input for a full genome.
#
# Deterministic either way: takes the FIRST N read pairs rather than sampling, so
# rerunning reproduces byte-identical FASTQ payloads.
#
# Requires: curl, python3 (+ bowtie2 for the default chrM-selected mode).
#
# Takes a few minutes and ~800 MB of scratch; see README.md for provenance.
set -euo pipefail

UNFILTERED=0
[[ "${1:-}" == "--unfiltered" ]] && UNFILTERED=1

ACC=SRR1039508
SLICE_PAIRS=2000000        # read pairs streamed from ENA
KEEP_PAIRS=50000           # chrM pairs retained
CHRM_FA=../../genome_source/chrM.fa
OUTDIR="$ACC"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

BASE="https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR103/008/${ACC}/${ACC}"

echo "==> streaming first ${SLICE_PAIRS} pairs from ENA"
for m in 1 2; do
    curl -s "${BASE}_${m}.fastq.gz" | gzip -cd | head -n $((SLICE_PAIRS * 4)) > "$WORK/slice_${m}.fastq" || true
done

if [[ $UNFILTERED -eq 1 ]]; then
    echo "==> emitting first ${KEEP_PAIRS} pairs unfiltered (no chrM selection)"
    mkdir -p "$OUTDIR"
    for m in 1 2; do
        head -n $((KEEP_PAIRS * 4)) "$WORK/slice_${m}.fastq" > "$OUTDIR/${ACC}_all_${m}.fastq"
    done
    gzip -9 -f "$OUTDIR/${ACC}_all_1.fastq" "$OUTDIR/${ACC}_all_2.fastq"
    ls -lh "$OUTDIR"
    echo "Done. Use these with a real genome index; point example_rnaseq_pe.yaml at"
    echo "  ${ACC}_all_{1,2}.fastq.gz  instead of  ${ACC}_chrM_{1,2}.fastq.gz"
    exit 0
fi

echo "==> aligning to chrM"
bowtie2-build -q "$CHRM_FA" "$WORK/chrM"
bowtie2 -x "$WORK/chrM" -1 "$WORK/slice_1.fastq" -2 "$WORK/slice_2.fastq" \
        -p 8 --no-unal --no-mixed --no-discordant -S "$WORK/chrM_pairs.sam"

echo "==> extracting first ${KEEP_PAIRS} concordant pairs"
mkdir -p "$OUTDIR"
KEEP_PAIRS=$KEEP_PAIRS WORK=$WORK ACC=$ACC OUTDIR=$OUTDIR python3 - <<'PY'
import os
keep_n = int(os.environ['KEEP_PAIRS']); work = os.environ['WORK']
acc = os.environ['ACC']; outdir = os.environ['OUTDIR']

keep, order = set(), []
with open(f'{work}/chrM_pairs.sam') as f:
    for line in f:
        if line.startswith('@'):
            continue
        name = line.split('\t', 1)[0]
        if name not in keep:
            keep.add(name); order.append(name)
        if len(keep) >= keep_n:
            break

for m in (1, 2):
    n = 0
    with open(f'{work}/slice_{m}.fastq') as src, \
         open(f'{outdir}/{acc}_chrM_{m}.fastq', 'w') as out:
        while True:
            h = src.readline()
            if not h:
                break
            rec = h + src.readline() + src.readline() + src.readline()
            rid = h[1:].split()[0]
            if rid.endswith(('/1', '/2')):
                rid = rid[:-2]
            if rid in keep:
                out.write(rec); n += 1
    print(f'  mate {m}: {n} reads')
PY

gzip -9 -f "$OUTDIR/${ACC}_chrM_1.fastq" "$OUTDIR/${ACC}_chrM_2.fastq"
ls -lh "$OUTDIR"
echo "Done."
