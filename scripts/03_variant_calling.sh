#!/usr/bin/env bash
set -euo pipefail

mkdir -p results/variants

REF64="references/bovismorbificans/ncbi_dataset/data/GCA_016454185.1/GCA_016454185.1_ASM1645418v1_genomic.fna"
REF65="references/enteritidis/ncbi_dataset/data/GCF_000612325.1/GCF_000612325.1_ASM61232v1_genomic.fna"

for sample in SRR39213464 SRR39213465; do

    if [[ "$sample" == "SRR39213464" ]]; then
        REF="$REF64"
    else
        REF="$REF65"
    fi

    BAM="results/alignment/${sample}.sorted.bam"
    RAW="results/variants/${sample}.haploid.raw.vcf.gz"
    FILTERED="results/variants/${sample}.haploid.filtered.vcf.gz"

    echo "Processing ${sample}..."

    bcftools mpileup -Ou -f "$REF" "$BAM" \
        | bcftools call --ploidy 1 -mv -Oz -o "$RAW"

    bcftools index -f "$RAW"

    bcftools view \
        -i 'QUAL>=30 && INFO/DP>=10' \
        -Oz -o "$FILTERED" "$RAW"

    bcftools index -f "$FILTERED"

    bcftools stats "$FILTERED" \
        > "results/variants/${sample}.haploid.stats.txt"

    echo "Completed ${sample}"
done

echo "Variant calling completed successfully."