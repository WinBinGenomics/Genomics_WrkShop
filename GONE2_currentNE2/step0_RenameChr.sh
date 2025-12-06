#!/bin/bash
#SBATCH --job-name=split_filter_pops_19_21
#SBATCH --output=renamechr.%j.out
#SBATCH --error=renamechr.%j.err
#SBATCH --time=04:00:00
#SBATCH --partition=GPU
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

# Load modules
module load bcftools/1.19
module load htslib/1.19.1
# Dirs. Edit to your local filesystem.
REFDIR=/data/shared/snigenda/finwhale_projects/cetacean_genomes/blue_whale_genome/GCF_009873245.2_mBalMus1.pri.v3
#VCFDIR=/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/vcfs/filtered/admixture
VCFDIR=/data/shared/snigenda/finwhale_projects/filteredvcf/workshop/vcfs/filtered/LD_ROH/LD_stuff
# Filenames
autosomesVCF=Passingsites_bisnps_var_chr1.vcf.gz
renamedVCF=Passing_biallelic_var_chr1_renamed_chr.vcf.gz

cd ${VCFDIR}

# Echo paths + files
echo "REFDIR:     $REFDIR"
echo "VCFDIR:     $VCFDIR"
echo "Input VCF:  $autosomesVCF"
echo "Output VCF: $renamedVCF"

# Now build autosome list + chromosome mapping file from tha .fai

grep "NC"  "$REFDIR/GCF_009873245.2_mBalMus1.pri.v3_genomic.fasta.fai" | \
grep -v -e "NC_045806.1" -e "NC_045807.1" -e "NC_001601.1" > autosomesBlueWhale.fai

# make autosome file: <scaffold_id> <start> <end>
awk -v OFS="\t" '{print $1, 1, $2}' autosomesBlueWhale.fai > autosomes
# Create chromosome lengths file: <chrN> <length>
#awk -v OFS="\t" '{print "chr" FNR, $3}' autosomes > chromosome_lengths.txt
awk -v OFS="\t" '{print FNR, $3}' autosomes > chromosome_lengths.txt
# Create mapping: <old_scaffold_id> <new_chr_name>
#awk -v OFS="\t" '{print $1, "chr" FNR}' autosomes > chromosome_mapping
awk -v OFS="\t" '{print $1, FNR}' autosomes > chromosome_mapping

echo "Generated chromosome_mapping:"
head chromosome_mapping

# for workshop. last three chromosomes.
#tail -3 chromosome_mapping > last3chromosome_mapping
head -1 chromosome_mapping > firstchromosome_mapping

echo "Running bcftools annotate --rename-chrs ..."
bcftools annotate --rename-chrs firstchromosome_mapping --output "$renamedVCF" \
  --output-type z "$autosomesVCF"

echo "Indexing renamed VCF"
tabix -p vcf "$renamedVCF"
