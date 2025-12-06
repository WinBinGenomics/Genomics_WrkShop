#!/bin/bash
#SBATCH --job-name=vcf2plink
#SBATCH --output=plink_pedmap_%j.out
#SBATCH --error=plink_pedmap_%j.err
#SBATCH --time=04:00:00
#SBATCH --partition=CPU
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

#⣠⣀⡠⠤⠂⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⢇⠀⠈⠒⠢⡀⠀⠁⠂⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡶⣿⡁
#⠀⠣⡀⠀⠀⠘⢟⡀⠀⠀⠀⠑⠒⠒⠐⠄⠄⠔⣊⠝⠳⡤⠄⠀
#⠀⠀⠈⠢⡀⠀⠀⠈⠁⠂⠤⣀⠀⠀⠀⢄⡢⠚⠁⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠑⠢⠤⠤⠤⠤⢮⠣⠐⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

# Snigenda workshop
# Author: Kaden Winspear - Dec. 2025
# Usage: sbatch step1_vcf2plink.sh
# Purpose: This script takes VCF input and outputs plink (.ped and .map) formatted files for LD analysis.

module load vcftools/0.1.16

# Home Directory
basedir='/data/shared/snigenda/finwhale_projects/filteredvcf/workshop'

# Population VCF dirs
ENP_vcfdir="${basedir}/vcfs/filtered/LD_ROH/LD_stuff/ENP"
GOC_vcfdir="${basedir}/vcfs/filtered/LD_ROH/LD_stuff/GOC"

# Output dirs
ENP_outdir="${basedir}/LD_analysis/ENP/plink"
GOC_outdir="${basedir}/LD_analysis/GOC/plink"

# vcfs
ENP_vcf="${ENP_vcfdir}/Passingsites_bisnps_ENP_chr1.vcf.gz"
GOC_vcf="${GOC_vcfdir}/Passingsites_bisnps_GOC_chr1.vcf.gz"

mkdir -p "$ENP_outdir" "$GOC_outdir"

######### Begin ENP VCF2PLINK ###########
ENP_prefix="${ENP_outdir}/ENP_chr1"

echo "Converting ENP VCF to PLINK:"
echo "  VCF:  $ENP_vcf"
echo "  OUT:  ${ENP_prefix}.ped / .map"

vcftools --gzvcf "$ENP_vcf" --plink --out "$ENP_prefix"

if [[ $? -ne 0 ]]; then
    echo "ERROR: vcftools --plink failed on ENP file: $ENP_vcf" >&2
    exit 1
else
    echo "nice job!: ENP ${ENP_prefix}.ped and .map created"
fi

# Fix phenotype column (6th) to -9
pedfile="${ENP_prefix}.ped"
tmp_ped="${ENP_prefix}.tmp.ped"

awk 'BEGIN{OFS=" "} { $6 = -9; print }' "$pedfile" > "$tmp_ped" && mv "$tmp_ped" "$pedfile"
echo "Phenotype column fixed to -9 for ENP PED file."


######### Begin GOC VCF2PLINK ###########
GOC_prefix="${GOC_outdir}/GOC_chr1"

echo "Converting GOC VCF to PLINK:"
echo "  VCF:  $GOC_vcf"
echo "  OUT:  ${GOC_prefix}.ped / .map"

vcftools --gzvcf "$GOC_vcf" --plink --out "$GOC_prefix"

if [[ $? -ne 0 ]]; then
    echo "ERROR: vcftools --plink failed on GOC file: $GOC_vcf" >&2
    exit 1
else
    echo "nice job!: GOC ${GOC_prefix}.ped and .map created"
fi

# Fix phenotype column (6th) to -9
pedfile="${GOC_prefix}.ped"
tmp_ped="${GOC_prefix}.tmp.ped"

awk 'BEGIN{OFS=" "} { $6 = -9; print }' "$pedfile" > "$tmp_ped" && mv "$tmp_ped" "$pedfile"
echo "Phenotype column fixed to -9 for GOC PED file."

echo "All conversions done."
