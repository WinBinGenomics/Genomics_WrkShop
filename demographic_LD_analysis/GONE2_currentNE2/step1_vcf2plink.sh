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
# Note - Output needs to be edited using awk commands at bottom of script to ensure .map files have correct chromosome identifier. 


#module load plink/1.9b7.2
module load vcftools/0.1.16

# Home Directory
basedir='/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/LD_analysis'

# Population VCF dirs
ENP_vcfdir="${basedir}/ENP/vcfs"
GOC_vcfdir="${basedir}/GOC/vcfs"

# Output dirs
ENP_outdir="${basedir}/ENP/plink"
GOC_outdir="${basedir}/GOC/plink"

mkdir -p "$ENP_outdir" "$GOC_outdir"

######### Begin ENP VFC2PLink ###########
cd "$ENP_vcfdir"

for FILE in Passingsites_bisnps_maf05_ENP_*.vcf.gz; do
    prefix="${FILE%.vcf.gz}"
    outprefix="${ENP_outdir}/${prefix}"
    vcftools --gzvcf "$FILE" --plink --out "$outprefix"

    if [[ $? -ne 0 ]]; then
        echo "ERROR: plink failed on ENP file $FILE" >&2
        exit 1
    else
        echo "nice job!: ENP ${outprefix}.ped and .map created"
    fi
done

######### Begin GOC VCF2PLINK ###########
cd "$GOC_vcfdir" || { echo "Cannot cd to $GOC_vcfdir"; exit 1; }

for FILE in Passingsites_bisnps_maf05_GOC_*.vcf.gz; do
    prefix="${FILE%.vcf.gz}"
    outprefix="${GOC_outdir}/${prefix}"
    vcftools --gzvcf "$FILE" --plink --out "$outprefix"

    if [[ $? -ne 0 ]]; then
        echo "ERROR: plink failed on GOC file $FILE" >&2
        exit 1
    else
        echo "nice job!: GOC ${outprefix}.ped and .map created"
    fi
done


# Next step is to replace the scaffold id with the correct chromosome identifier using these awk commands. GONE2 will fail with the scaffold ID.
#  awk '{$1=1}1' Passingsites_bisnps_maf05_GOC_01.map > tmp && mv tmp Passingsites_bisnps_maf05_GOC_01.map
#  awk '{$1=2}1' Passingsites_bisnps_maf05_GOC_02.map > tmp && mv tmp Passingsites_bisnps_maf05_GOC_02.map
#  awk '{$1=3}1' Passingsites_bisnps_maf05_GOC_03.map > tmp && mv tmp Passingsites_bisnps_maf05_GOC_03.map
