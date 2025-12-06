#!/bin/bash
#SBATCH --time=23:00:00
#SBATCH --mem=15G
#SBATCH --job-name=NewVcf_bcftools
#SBATCH --mail-type=ALL

module load anaconda3/2023.09
source /cm/shared/apps/anaconda3/2023.09/etc/profile.d/conda.sh
conda activate fintools

set -o pipefail

pop=$1

homedir=/data/shared/snigenda/finwhale_projects/filteredvcf/workshop
workdir=${homedir}/LD_ROH/ROH
scriptdir=${homedir}/scripts
vcfdir=${homedir}/vcfs/filtered/pixy
popdir=${workdir}/${pop}
popfile=${scriptdir}/configs/${pop}ids.txt

mkdir -p ${workdir}
mkdir -p ${popdir}


# The bcftools manual recomends to do the subsetting and filtering of as two different steps becuase sample removal can change the
# allele frequency, so we do it like it is recommended by pipping the results of step 1 (subsetting samples) into step 2 (filtering variants)
bcftools view -S ${popfile} -Ou ${vcfdir}/Passing_biallelic_all_19-21.vcf.gz | bcftools view --include 'FILTER=="PASS"' -o ${popdir}/${pop}_Passing_biallelic_all_19-21.vcf.gz -Oz

conda deactivate

