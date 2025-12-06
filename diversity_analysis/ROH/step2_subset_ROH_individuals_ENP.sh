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


cd /data/shared/snigenda/finwhale_projects/filteredvcf/workshop/Diversity_analysis/ROH/ENP

file=ENP_roh_bcftools_AFACANGT.txt

tail -n +6 ${file} > tmp.txt


awk '$2 == "ENPWA14" { print }' tmp.txt > ENPWA14_${file}
awk '$2 == "ENPCA08" { print }' tmp.txt > ENPCA08_${file}
awk '$2 == "ENPBC18" { print }' tmp.txt > ENPBC18_${file}
awk '$2 == "ENPAK29" { print }' tmp.txt > ENPAK29_${file}
awk '$2 == "ENPBC16" { print }' tmp.txt > ENPBC16_${file}

wait

gzip ENP*
gzip ${file}
rm tmp.txt

