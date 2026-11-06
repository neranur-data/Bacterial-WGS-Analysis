#!/usr/bin/env bash
set -euo pipefail

# Bacterial Whole-Genome Sequencing
# Step 1: Quality Control and Read Trimming

mkdir -p data/clean
mkdir -p results/fastqc
mkdir -p results/fastqc_clean
mkdir -p reports

for sample in SRR39213464 SRR39213465; do

    echo "Processing sample: $sample"

    R1="data/raw/${sample}_1.fastq"
    R2="data/raw/${sample}_2.fastq"

    CLEAN_R1="data/clean/${sample}_1.clean.fastq"
    CLEAN_R2="data/clean/${sample}_2.clean.fastq"

    # Initial quality assessment
    fastqc "$R1" "$R2" \
        -o results/fastqc

    # Adapter trimming and quality filtering
    fastp \
        -i "$R1" \
        -I "$R2" \
        -o "$CLEAN_R1" \
        -O "$CLEAN_R2" \
        -h "reports/${sample}_fastp.html" \
        -j "reports/${sample}_fastp.json"

    # Quality assessment after trimming
    fastqc "$CLEAN_R1" "$CLEAN_R2" \
        -o results/fastqc_clean

    echo "Completed sample: $sample"

done

# Combined quality control report
multiqc results/fastqc results/fastqc_clean \
    -d -dd 1 \
    -o reports \
    -n multiqc_comparison.html

echo "Quality control completed successfully."