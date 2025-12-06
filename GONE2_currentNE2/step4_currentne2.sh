#!/bin/bash
#SBATCH -J currentNe
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH --partition=HIMEM
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

# Load currentne2
module load currentne2/1.0.1

# Load variables
pop=$1
inputdir="/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/LD_analysis/${pop}/plink"
outputdir="/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/LD_analysis/currentne2/${pop}"
mkdir -p "${outputdir}"

# Go to output directory
cd "${outputdir}"

# Run GONE2 on the input.
currentne2 ${inputdir}/${pop}.ped 3 -o ${outputdir}/${pop}.currentNe.txt
