#!/bin/bash
#SBATCH --job-name=filter_goneprep
#SBATCH --output=bcftools_filter_%j.out
#SBATCH --error=bcftools_filter_%j.err
#SBATCH --time=04:00:00
#SBATCH --partition=GPU
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

#⣠⣀⡠⠤⠂⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⢇⠀⠈⠒⠢⡀⠀⠁⠂⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡶⣿⡁
#⠀⠣⡀⠀⠀⠘⢟⡀⠀⠀⠀⠑⠒⠒⠐⠄⠄⠔⣊⠝⠳⡤⠄⠀
#⠀⠀⠈⠢⡀⠀⠀⠈⠁⠂⠤⣀⠀⠀⠀⢄⡢⠚⠁⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠑⠢⠤⠤⠤⠤⢮⠣⠐⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

# snigenda workshop. Script is used to filter VCFS for only passing Biallelic Snps with a maf of 0.05.
#⣠⣀⡠⠤⠂⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⢇⠀⠈⠒⠢⡀⠀⠁⠂⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡶⣿⡁
#⠀⠣⡀⠀⠀⠘⢟⡀⠀⠀⠀⠑⠒⠒⠐⠄⠄⠔⣊⠝⠳⡤⠄⠀
#⠀⠀⠈⠢⡀⠀⠀⠈⠁⠂⠤⣀⠀⠀⠀⢄⡢⠚⠁⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠑⠢⠤⠤⠤⠤⢮⠣⠐⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

# Snigenda workshop 
# Author: Kaden Winspear - Dec. 2025
# Usage: sbatch step0_PopSplit_PassBiSnps_maf05.sh
# Purpose: Script is used to split populations and  filter VCFS for only passing Biallelic Snps with a maf of 0.05. 


# Load modules
module load bcftools/1.19

# Load variables.
homedir='/data/shared/snigenda/finwhale_projects/filteredvcf/workshop'
ENPids="${homedir}/scripts/configs/ENPids.txt"
GOCids="${homedir}/scripts/configs/GOCids.txt"
vcfs=(downsampled_ENP_GOC_01.vcf.gz downsampled_ENP_GOC_02.vcf.gz downsampled_ENP_GOC_03.vcf.gz)

cd "${homedir}/vcfs/unfiltered"

######## Seperating Populations #########
i=1
for FILE in "${vcfs[@]}"; do

    ENP_VCF="ENP_only_${i}.vcf.gz"
    GOC_VCF="GOC_only_${i}.vcf.gz"

    bcftools view -S ${ENPids} -Oz -o "${homedir}/LD_analysis/ENP/vcfs/$ENP_VCF" "$FILE"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to subset ENP from $FILE" >&2
        exit 1
    fi

    bcftools view -S ${GOCids} -Oz -o "${homedir}/LD_analysis/GOC/vcfs/$GOC_VCF" "$FILE"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to subset GOC from $FILE" >&2
        exit 1
    fi

    bcftools index "$ENP_VCF"
    bcftools index "$GOC_VCF"

    ####### Filtering ####### ENP VCFs
    ENP_OUT=$(printf "Passingsites_bisnps_maf05_ENP_%02d.vcf.gz" "$i")

    bcftools view -f PASS -m2 -M2 -v snps -q 0.05:minor -Oz -o "${homedir}/LD_analysis/ENP/vcfs/$ENP_OUT" "$ENP_VCF"

    if [[ $? -ne 0 ]]; then
        echo "ERROR: Filtering failed for $ENP_VCF" >&2
        exit 1
    else
        echo "nice job!: $ENP_OUT created"
    fi

    bcftools index "$ENP_OUT"

    ######## Filtering ####### GOC VCFs
    GOC_OUT=$(printf "Passingsites_bisnps_maf05_GOC_%02d.vcf.gz" "$i")

    bcftools view -f PASS -m2 -M2 -v snps -q 0.05:minor -Oz -o "${homedir}/LD_analysis/GOC/vcfs/$GOC_OUT" "$GOC_VCF"

    if [[ $? -ne 0 ]]; then
        echo "ERROR: Filtering failed for $GOC_VCF" >&2
        exit 1
    else
        echo "nice job!: $GOC_OUT created"
    fi

    bcftools index "$GOC_OUT"

    ((i++))
done

