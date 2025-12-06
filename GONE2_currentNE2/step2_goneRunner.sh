#!/bin/bash -l
#SBATCH -J gone2
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=30:00:00
#SBATCH --mem=8G
#SBATCH --partition=GPU
#SBATCH --mail-user=winsp001@csusm.edu
#SBATCH --mail-type=ALL

#⣠⣀⡠⠤⠂⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⢇⠀⠈⠒⠢⡀⠀⠁⠂⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡶⣿⡁
#⠀⠣⡀⠀⠀⠘⢟⡀⠀⠀⠀⠑⠒⠒⠐⠄⠄⠔⣊⠝⠳⡤⠄⠀
#⠀⠀⠈⠢⡀⠀⠀⠈⠁⠂⠤⣀⠀⠀⠀⢄⡢⠚⠁⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠑⠢⠤⠤⠤⠤⢮⠣⠐⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

# Snigenda workshop
# Author: Kaden Winspear - Dec. 2025
# Usage: sbatch step3_goneRunner.sh [Population] Example: sbatch step3_goneRunner.sh ENP 
# Purpose: Runs gone2 on populations.

set -euo pipefail

# Load Gone2
module load gone2/1.0.2

# Load variables
pop=$1
inputdir="/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/LD_analysis/${pop}/plink"
outputdir="/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/LD_analysis/GONE2/${pop}"
mkdir -p "${outputdir}"

# Go to output directory
cd "${outputdir}"

# Run GONE2 on the input.
srun gone2 -t "${SLURM_CPUS_PER_TASK}" -r 0.8 -s 1999999 -M 0.05 "${inputdir}/${pop}_CHR1.ped" -o "${outputdir}/${pop}"
#srun gone2 -t "${SLURM_CPUS_PER_TASK}" -r 0.8 -x "${inputdir}/${pop}_chr19-21.ped" -o "${outputdir}/${pop}"
