#!/usr/bin/env bash
# Build the prebuilt STAR index that ships in this directory, from
# ../genome_source/genome.{fa,gtf}.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FASTA="$HERE/./genome_source/genome.fa"
GTF="$HERE/./genome_source/genome.gtf"
OUT="$HERE/star_index"
THREADS="${THREADS:-8}"
SJDB_OVERHANG="${SJDB_OVERHANG:-28}"     # read_length - 1 for the ribo-seq libraries
STAR_IMAGE="${STAR_IMAGE:-danielnguyener/riboflow:0.0.2}"

[[ -s "$FASTA" ]] || { echo "error: missing $FASTA" >&2; exit 1; }
[[ -s "$GTF"   ]] || { echo "error: missing $GTF" >&2; exit 1; }

GENOME_LEN=$(awk '!/^>/ { n += length($0) } END { print n+0 }' "$FASTA")
NBASES=$(awk -v L="$GENOME_LEN" 'BEGIN {
    v = int(log(L) / log(2) / 2 - 1)
    if (v > 14) v = 14
    if (v < 2)  v = 2
    print v
}')
CHROM=$(grep -m1 '^>' "$FASTA" | sed 's/^>//' | awk '{print $1}')

echo "==> reference: $CHROM, $GENOME_LEN bp"
echo "==> --genomeSAindexNbases $NBASES  --sjdbOverhang $SJDB_OVERHANG"

rm -rf "$OUT" && mkdir -p "$OUT"

STAR_ARGS=(
    --runMode genomeGenerate
    --runThreadN "$THREADS"
    --genomeDir /data/genome/star_index
    --genomeFastaFiles /data/genome_source/genome.fa
    --sjdbGTFfile /data/genome_source/genome.gtf
    --sjdbOverhang "$SJDB_OVERHANG"
    --genomeSAindexNbases "$NBASES"
    --outFileNamePrefix /data/genome/star_index/
)

if [[ "${NATIVE:-0}" == "1" ]]; then
    command -v STAR >/dev/null || { echo "error: STAR not on PATH" >&2; exit 1; }
    STAR --runMode genomeGenerate --runThreadN "$THREADS" \
         --genomeDir "$OUT" --genomeFastaFiles "$FASTA" --sjdbGTFfile "$GTF" \
         --sjdbOverhang "$SJDB_OVERHANG" --genomeSAindexNbases "$NBASES" \
         --outFileNamePrefix "$OUT/"
else
    command -v docker >/dev/null || { echo "error: docker not found (or use NATIVE=1)" >&2; exit 1; }
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v "$(cd "$HERE/.." && pwd)":/data \
        "$STAR_IMAGE" \
        STAR "${STAR_ARGS[@]}"
fi

rm -f "$OUT/Log.progress.out" "$OUT/_STARtmp" 2>/dev/null || true
rm -rf "$OUT/_STARtmp" 2>/dev/null || true

echo "==> done"
du -sh "$OUT"
ls "$OUT"
