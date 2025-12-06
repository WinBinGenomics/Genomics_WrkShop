#!/bin/bash
#SBATCH --time=23:00:00
#SBATCH --mem=15G
#SBATCH --job-name=bcftoolsroh
#SBATCH --mail-type=ALL


# This script identifies regions with autozigosity or runs of homozygosity (ROH) for each population
# Author: Sergio Nigenda & Adjusted by Kaden Winspear @ CSUSM -> Eastern Pacific Fin Whale Project.
# Usage: sbatch roh_bcftools.sh population

module load anaconda3/2023.09
source /cm/shared/apps/anaconda3/2023.09/etc/profile.d/conda.sh
conda activate fintools

set -o pipefail


########## Defining variables, directories and files

pop=$1
homedir=/data/shared/snigenda/finwhale_projects/filteredvcf/workshop
workdir=${homedir}/Diversity_analysis/ROH
scriptdir=${homedir}/scripts/genomic_diversity/ROH
vcfdir=${homedir}/Diversity_analysis/ROH/${pop}
popdir=${workdir}/${pop}

mkdir -p ${workdir}
mkdir -p ${popdir}

########## Performing analysis

cd ${workdir}

bcftools roh -G30 ${vcfdir}/${pop}_passingsites.vcf.gz --include 'FILTER="PASS"' -o ${popdir}/${pop}_roh_bcftools_AFACANGT_${IDX}

conda deactivate
