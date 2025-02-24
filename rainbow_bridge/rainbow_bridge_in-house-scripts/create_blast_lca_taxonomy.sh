#!/bin/bash
#SBATCH --job-name=blst-txnm    # Job name
#SBATCH --partition=cpu              # Partition name (change to 'cpu' 360G or 'gpu' 740G as needed)
#SBATCH --mem=340G                    # Total memory per node (adjust as needed)
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --ntasks=192                   # Number of tasks (usually 1 for single-job scripts)
#SBATCH --cpus-per-task=1           # Number of CPU cores per task
#SBATCH --time=2-00:00:00            # Time limit (D-HH:MM:SS)
#SBATCH --output=blast-taxo-%j.out     # Standard output and error log (%j will be replaced by job ID)
#SBATCH --mail-type=END,FAIL              #Send email on all job events
#SBATCH --mail-user=@tamucc.edu    #Send all emails to email_address

# This script generates the file "blast_lca_taxonomy" which incoorporates basic blast metrics to the zotus selected by the LCA taxonomy collapse
# This file is then upload to R to generate plots of dataset statistics

## to execute
## 1.- move into the dir where you ran rainbow_bridge (will have output created by the run) 
## 2.- assuming this script is the repo's script directory, then
## bash ../../scripts/create_blast_lca_taxonomy.tsv


# Input files
taxonomy_file="lca_taxonomy.tsv"
intermediate_file="lca_intermediate.tsv"
output_file="blast_lca_taxonomy.tsv"
temp_file="lca_intermediate_no_sp.tsv"

# Headers for output file
echo -e "zotu\tseqid\tevalue\tqcov\tpident\tdomain\tkingdom\tphylum\tclass\torder\tfamily\tgenus\tspecies\tunique_hits\ttaxid" > "$output_file"

# Iterate through each ZOTU in the taxonomy file
while IFS=$'\t' read -r zotu domain kingdom phylum class order family genus species unique_hits taxid; do

    # Get matching rows from lca_intermediate.tsv for this ZOTU
    grep -P "^$zotu\t" "$intermediate_file" > temp_rows.tsv
    num_rows=$(wc -l < temp_rows.tsv)

    if [[ $num_rows -eq 1 ]]; then
        # Case 1: Only one row per zotu in lca_intermediate.tsv
        while IFS=$'\t' read -r izotu seqid taxid blast_species commonname blast_kingdom pident length qlen slen mismatch gapopen gaps qstart wend sstart send stitle evalue bitscore qcov qcovhsp iunique_hits num_hits_per_taxid idomain ikingdom iphylum iclass iorder ifamily igenus ispecies itaxon; do
            echo -e "$zotu\t$seqid\t$evalue\t$qcov\t$pident\t$domain\t$kingdom\t$phylum\t$class\t$order\t$family\t$genus\t$species\t$unique_hits\t$taxid" >> "$output_file"
        done < temp_rows.tsv

    else
        # Case 2: Multiple rows per zotu in lca_intermediate.tsv

        # Step 1: Remove rows with species marked as "sp." (case-insensitive)
        grep -vP "\t[Ss][Pp]\.\s" temp_rows.tsv > "$temp_file"

        # If no rows remain after filtering, fill with "na"
        remaining_rows=$(wc -l < "$temp_file")
        if [[ $remaining_rows -eq 0 ]]; then
            echo -e "$zotu\tna\tna\tna\tna\t$domain\t$kingdom\t$phylum\t$class\t$order\t$family\t$genus\t$species\tna\tna" >> "$output_file"
        else
            # Step 2: Calculate averages of seqid, evalue, qcov, pident for the remaining rows
            avg_evalue=$(awk -F"\t" '{sum+=$19; count++} END {if (count > 0) print sum/count; else print "na"}' "$temp_file")
            avg_qcov=$(awk -F"\t" '{sum+=$21; count++} END {if (count > 0) print sum/count; else print "na"}' "$temp_file")
            avg_pident=$(awk -F"\t" '{sum+=$7; count++} END {if (count > 0) print sum/count; else print "na"}' "$temp_file")

            # Since seqid is a string, assign "na" when multiple rows exist
            echo -e "$zotu\tna\t$avg_evalue\t$avg_qcov\t$avg_pident\t$domain\t$kingdom\t$phylum\t$class\t$order\t$family\t$genus\t$species\tna\tna" >> "$output_file"
        fi
    fi

done < <(tail -n +2 "$taxonomy_file")  # Skip the header

# Sort the output by ZOTU (assuming zotu format is Zotu1, Zotu2, Zotu3, etc.)

# Create header
head -n1 $output_file > header
# remove header from output file so sort works correctly
tail -n+2 $output_file > body
sort -V body -o body
#sort -V "$output_file" -o "$output_file"

# Restoring output file
cat header body > $output_file
# Clean up temporary files
rm temp_rows.tsv "$temp_file" header body

# Report Job stats
seff $SLURM_JOB_ID
