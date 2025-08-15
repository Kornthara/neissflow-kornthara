#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

out="${1:-illumina_pairs.csv}"
echo "sample,fastq_1,fastq_2" > "$out"

for r1 in *_R1*.fastq.gz *_R1*.fq.gz *_R1*.fastq *_R1*.fq; do
  [[ -e "$r1" ]] || continue
  sample="${r1%%_R1*}"              # everything before first _R1
  r2="${r1/_R1/_R2}"                # swap _R1 -> _R2, keep rest (e.g., lane bits)
  if [[ -f "$r2" ]]; then
    printf '%s,%s,%s\n' "$sample" "$r1" "$r2" >> "$out"
  else
    printf 'Warning: No matching R2 for %s\n' "$r1" >&2
  fi
done

echo "CSV file created: $out"

