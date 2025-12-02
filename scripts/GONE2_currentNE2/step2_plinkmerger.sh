#!/bin/bash
#SBATCH --job-name=plink_merge
#SBATCH --output=plink_merge_%j.out
#SBATCH --error=plink_merge_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G

#⣠⣀⡠⠤⠂⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⢇⠀⠈⠒⠢⡀⠀⠁⠂⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡶⣿⡁
#⠀⠣⡀⠀⠀⠘⢟⡀⠀⠀⠀⠑⠒⠒⠐⠄⠄⠔⣊⠝⠳⡤⠄⠀
#⠀⠀⠈⠢⡀⠀⠀⠈⠁⠂⠤⣀⠀⠀⠀⢄⡢⠚⠁⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠑⠢⠤⠤⠤⠤⢮⠣⠐⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

# Snigenda workshop
# Author: Kaden Winspear - Dec. 2025
# Usage: sbatch step2_plinkmerger.sh
# Purpose: Merges the plink (.ped and .map) files for chromosome 1-3. Requires merge config files.

# Load Modules
module load plink/1.9b7.2

# Load variables
homedir='/data/shared/snigenda/finwhale_projects/filteredvcf/workshop'

# PLINK dirs
ENP_dir="${homedir}/LD_analysis/ENP/plink"
GOC_dir="${homedir}/LD_analysis/GOC/plink"

# Merge lists
ENP_list="${homedir}/scripts/GONE2_currentNE2/config/ENP_mergelist.txt"
GOC_list="${homedir}/scripts/GONE2_currentNE2/config/GOC_mergelist.txt"

####### Merge ENP plink files ######
cd "$ENP_dir"

plink --file Passingsites_bisnps_maf05_ENP_01 --merge-list "$ENP_list" --make-bed --allow-extra-chr --out ENP_Merged

if [[ $? -ne 0 ]]; then
    echo "ERROR: ENP merge failed" >&2
    exit 1
fi

# Recode from binary merge BED to PED
plink --bfile ENP_Merged --recode --allow-extra-chr --out ENP

if [[ $? -ne 0 ]]; then
    echo "ERROR: ENP recode failed" >&2
    exit 1
else
    echo "nice job!: ENP merged and recoded successfully"
fi

####### Merge GOC plink files ######
cd "$GOC_dir"

plink --file Passingsites_bisnps_maf05_GOC_01 --merge-list "$GOC_list" --make-bed --allow-extra-chr --out GOC_Merged

if [[ $? -ne 0 ]]; then
    echo "ERROR: GOC merge failed" >&2
    exit 1
fi

# Recode from binary merge BED to PED
plink --bfile GOC_Merged --recode --allow-extra-chr --out GOC

if [[ $? -ne 0 ]]; then
    echo "ERROR: GOC recode failed" >&2
    exit 1
else
    echo "nice job!: GOC merged and recoded successfully"
fi
