#!/bin/bash
#SBATCH --job-name=split_filter_pops_19_21
#SBATCH --output=split_filter_pops_19_21.%j.out
#SBATCH --error=split_filter_pops_19_21.%j.err
#SBATCH --time=04:00:00
#SBATCH --partition=GPU
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

set -euo pipefail

module load bcftools/1.19
module load htslib/1.19.1

# Base project directory
homedir=/data/shared/snigenda/finwhale_projects/filteredvcf/workshop

# Directory containing the renamed VCF from the first script
VCFDIR=${homedir}/vcfs/filtered/LD_ROH/LD_stuff
cd "$VCFDIR"

# Renamed VCF (Chr ## instead of scaffold id)
FILE=Passing_biallelic_var_chr1_renamed_chr.vcf.gz

# Sample ID lists
ENPids="${homedir}/scripts/configs/ENPids.txt"
GOCids="${homedir}/scripts/configs/GOCids.txt"

# Output directories for population-specific VCFs
ENP_OUTDIR="${homedir}/vcfs/filtered/LD_ROH/LD_stuff/ENP"
GOC_OUTDIR="${homedir}/vcfs/filtered/LD_ROH/LD_stuff/GOC"

mkdir -p "$ENP_OUTDIR" "$GOC_OUTDIR"

# Pop-level raw (unfiltered) VCF names (still chr19–21 combined)
ENP_VCF_RAW="ENP_chr1_unfiltered.vcf.gz"
GOC_VCF_RAW="GOC_chr1_unfiltered.vcf.gz"

# Pop-level filtered VCF names (PASS, biallelic SNPs only)
ENP_VCF_FILT="Passingsites_bisnps_ENP_chr1.vcf.gz"
GOC_VCF_FILT="Passingsites_bisnps_GOC_chr1.vcf.gz"

echo "Using renamed VCF: $VCFDIR/$FILE"
echo "ENP ids file:      $ENPids"
echo "GOC ids file:      $GOCids"

# 1. Subset ENP from VCF

echo "Subsetting ENP from $FILE ..."
bcftools view -S "$ENPids" -Oz -o "${ENP_OUTDIR}/${ENP_VCF_RAW}" "$FILE"
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to subset ENP from $FILE" >&2
    exit 1
else
    echo "ENP subset created: ${ENP_OUTDIR}/${ENP_VCF_RAW}"
fi

tabix -p vcf "${ENP_OUTDIR}/${ENP_VCF_RAW}"


# 2. Subset GOC from renamed VCF

echo "Subsetting GOC from $FILE ..."
bcftools view -S "$GOCids" -Oz -o "${GOC_OUTDIR}/${GOC_VCF_RAW}" "$FILE"
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to subset GOC from $FILE" >&2
    exit 1
else
    echo "GOC subset created: ${GOC_OUTDIR}/${GOC_VCF_RAW}"
fi

tabix -p vcf "${GOC_OUTDIR}/${GOC_VCF_RAW}"


# 3. Filtering ENP: PASS, bi-SNPs only #

echo "Filtering ENP VCF for PASS biallelic SNPs ..."
bcftools view -f PASS -m2 -M2 -v snps -Oz -o "${ENP_OUTDIR}/${ENP_VCF_FILT}" \
    "${ENP_OUTDIR}/${ENP_VCF_RAW}"

if [[ $? -ne 0 ]]; then
    echo "ERROR: Filtering failed for ${ENP_OUTDIR}/${ENP_VCF_RAW}" >&2
    exit 1
else
    echo "nice job!: ${ENP_OUTDIR}/${ENP_VCF_FILT} created"
fi

tabix -p vcf "${ENP_OUTDIR}/${ENP_VCF_FILT}"

# 4. Filtering GOC: PASS, bi-SNPs only

echo "Filtering GOC VCF for PASS biallelic SNPs ..."
bcftools view -f PASS -m2 -M2 -v snps -Oz -o "${GOC_OUTDIR}/${GOC_VCF_FILT}" \
    "${GOC_OUTDIR}/${GOC_VCF_RAW}"

if [[ $? -ne 0 ]]; then
    echo "ERROR: Filtering failed for ${GOC_OUTDIR}/${GOC_VCF_RAW}" >&2
    exit 1
else
    echo "nice job!: ${GOC_OUTDIR}/${GOC_VCF_FILT} created"
fi

tabix -p vcf "${GOC_OUTDIR}/${GOC_VCF_FILT}"

echo
echo "All done."
echo "ENP filtered VCF: ${ENP_OUTDIR}/${ENP_VCF_FILT}"
echo "GOC filtered VCF: ${GOC_OUTDIR}/${GOC_VCF_FILT}"

