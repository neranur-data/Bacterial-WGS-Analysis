#!/usr/bin/env bash
set -euo pipefail

# Bacterial Whole-Genome Sequencing Analysis
# Reference-based paired-end read alignment
# Tools: BWA-MEM2 2.2.1 and SAMtools 1.25

THREADS=4
OUTPUT_DIR="results/alignment"

mkdir -p "$OUTPUT_DIR"

align_sample() {
    local SAMPLE="$1"
    local REFERENCE="$2"

    echo "Aligning ${SAMPLE}..."

    bwa-mem2 mem -t "$THREADS" \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" \
        "$REFERENCE" \
        "data/clean/${SAMPLE}_1.clean.fastq" \
        "data/clean/${SAMPLE}_2.clean.fastq" \
        | samtools sort -@ "$THREADS" \
            -o "${OUTPUT_DIR}/${SAMPLE}.sorted.bam" -

    samtools index "${OUTPUT_DIR}/${SAMPLE}.sorted.bam"

    echo "Completed: ${SAMPLE}"
}

# Salmonella bovismorbificans
align_sample "SRR39213464" \
    "references/bovismorbificans/ncbi_dataset/data/GCA_016454185.1/GCA_016454185.1_ASM1645418v1_genomic.fna"

# Salmonella Enteritidis
align_sample "SRR39213465" \
    "references/enteritidis/ncbi_dataset/data/GCF_000612325.1/GCF_000612325.1_ASM61232v1_genomic.fna"

echo "All alignments completed."
