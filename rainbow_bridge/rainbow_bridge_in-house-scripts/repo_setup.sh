#!/bin/bash

### Copy files for GitHub Repo

## to execute
## 1.- move into the dir where you ran rainbow_bridge (will have output created by the run) 
## 2.- assuming this script is the repo's script directory, then
## bash ../../scripts/repo_setup.sh

# Quality Reports
cp output/fastqc/initial/multiqc_report.html initial_multiqc_report.html 
cp output/fastqc/filtered/multiqc_report.html filtered_multiqc_report.html 

# Zotu table and fasta
cp output/zotus/zotu_table.tsv zotu_table.tsv
cp output/zotus/b*zotus.fasta zotus.fasta

# LCA intermediate and taxonomy
cp output/taxonomy/lca/q*/*tsv .
