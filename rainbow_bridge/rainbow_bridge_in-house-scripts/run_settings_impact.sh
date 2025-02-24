#!/bin/bash

# run_settings_impact.sh
# prints out used settings and basic zotu and taxonomic stats from a single or multiple rainbow_bridge runs

# To use:
# You do not need to move the script. Just "cd" to one level immediately above the output dir(s) created by rainbow_bridge, and
# execute: bash path_to_script/run_seetings_impact.sh <outdir or regex for multiple dirs>

# User defined variable
DIRPATTERN=$1

echo "Script executed from=$PWD"
outfile="$PWD/settings_impact_results.tsv"

if [ -f "./settings_impact_results.tsv" ]; then
    echo "The file ./settings_impact_results.tsv was found. Stats will be appended to this existing file"
else
    echo "The file ./settings_impact_results.tsv was not found. This file will be created and stats will be appended to it"
    # Create file with headings
    echo -e "JOBDIR\tmaxhits\tqcov\tpid\teval\tlca-qcov\tlca-pid\tlca-diff\tzotus_blast\thits_blast\thits_per_zotu\ttaxa_blast\tzotus_mapped\tzotus_lulu\tzotus_lca\tzotus_final\ttaxa_final" > settings_impact_results.tsv
    echo -e "defaults\t10\t100\t95\t0.001\t100\t97\t1\tna\tna\tna\tna\tna\tna\tna\tna\tna" >> settings_impact_results.tsv
fi

for JOBDIR in $DIRPATTERN; do
    JOBDIR_NAME=$(basename "$JOBDIR")
    maxhits=$(ls -d $JOBDIR/output/blast/p* | sed -e 's/.*max//' -e 's/\///')
    qcov=$(ls -d $JOBDIR/output/blast/p* | sed -e 's/.*qcov//' -e 's/_.*//')
    pid=$(ls -d $JOBDIR/output/blast/p* | sed -e 's/.*pid//' -e 's/_.*//')
    eval=$(ls -d $JOBDIR/output/blast/p* | sed -e 's/.*eval//' -e 's/_.*//')
    lca_qcov=$(ls -d $JOBDIR/output/taxonomy/lca/q*/ | sed -e 's/.*qcov//' -e 's/_.*//')
    lca_pid=$(ls -d $JOBDIR/output/taxonomy/lca/q*/ | sed -e 's/.*pid//' -e 's/_.*//')
    lca_diff=$(ls -d $JOBDIR/output/taxonomy/lca/q*/ | sed -e 's/.*diff//' -e 's/\///')
    zotus_blast=$(cat $JOBDIR/output/blast/p*/blast_result_merged.tsv | cut -f1 | sort | uniq | wc -l)
    hits_blast=$(cat $JOBDIR/output/blast/p*/blast_result_merged.tsv | wc -l)
    hits_per_zotu=$(echo "scale=1; $hits_blast / $zotus_blast" | bc)
    taxa_blast=$(cat $JOBDIR/output/blast/p*/blast_result_merged.tsv | cut -f4 | sort | uniq | wc -l)
    zotus_mapped=$(cat $JOBDIR/output/zotus/zotu_table.tsv | tail -n+2 | wc -l)
    zotus_lulu=$(cat $JOBDIR/output/lulu/lulu_zotu_table.tsv | tail -n+2 | wc -l)
    zotus_lca=$(cat $JOBDIR/output/taxonomy/lca/q*/lca_taxonomy.tsv | tail -n+2 | wc -l)
    zotus_final=$(cat $JOBDIR/output/final/zotu_table_final_curated.tsv | tail -n+2 | wc -l)
    taxa_final=$(cat $JOBDIR/output/final/zotu_table_final_curated.tsv | tail -n+2 | cut -f11 | sort | uniq | wc -l)
    echo -e "$JOBDIR_NAME\t$maxhits\t$qcov\t$pid\t$eval\t$lca_qcov\t$lca_pid\t$lca_diff\t$zotus_blast\t$hits_blast\t$hits_per_zotu\t$taxa_blast\t$zotus_mapped\t$zotus_lulu\t$zotus_lca\t$zotus_final\t$taxa_final" >> settings_impact_results.tsv
done

# Skip the first two lines and sort the output
#tail -n +3 settings_impact_results.tsv | sort -k2,2n -k3,3nr -k6,6nr > sorted_settings_impact_results.tsv

# Add the headings back to the sorted file
#head -n 2 settings_impact_results.tsv > temp_headings.tsv
#cat temp_headings.tsv sorted_settings_impact_results.tsv > settings_impact_results.tsv

# Clean up temporary files
rm temp_headings.tsv sorted_settings_impact_results.tsv

