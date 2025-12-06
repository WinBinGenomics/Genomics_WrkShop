#!/bin/bash
#SBATCH --job-name=subset_ROH
#SBATCH --time=16:00:00
#SBATCH --partition=HIMEM
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --mail-user=winsp001@csusm.edu

## This script is for subsetting bcftools roh output by individual, since the output files are very large
## Author: Sergio Nigenda & Kaden Winspear @ CSUSM -> Eastern pacific Fin whale project.
## The script also compresses the files, as they can be read into R when gzipped


cd /data/shared/snigenda/finwhale_projects/filteredvcf/workshop/Diversity_analysis/ROH/GOC

file=GOC_roh_bcftools_AFACANGT.txt

tail -n +6 ${file} > tmp.txt


awk '$2 == "GOC091" { print }' tmp.txt > GOC091_${file}
awk '$2 == "GOC010" { print }' tmp.txt > GOC010_${file}
awk '$2 == "GOC082" { print }' tmp.txt > GOC082_${file}
awk '$2 == "GOC050" { print }' tmp.txt > GOC050_${file}
awk '$2 == "GOC038" { print }' tmp.txt > GOC038_${file}

wait

gzip GOC*
gzip ${file}
rm tmp.txt

