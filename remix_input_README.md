# Regional Remix 

* Use these instructions to generate the input for the regional remix from metabarcoding pipeline output

The regional remix compares metabarcoding results (rainbow or REVAMP) to a curated database of 
regional species and flags taxa that would normally be found outside of this region.

In order to use the regional remix the output from metabarcoding pipelines needs 
to be transformed into the format required by the remix script.

## rainbow_bridge

Use the following script to transform the output of rainbow into the input files for the remix

* rainbow2remix.sh

Copy this file into your scripts directory
```
cd <main repo dir>
cp /share/all/rainbow_bridge_in-house-scripts/rainbow2remix.sh scripts
```

Make a directory for the remix analysis and move there
```
mkdir -p analyses
mkdir -p analyses/remix
cd analyses/remix
```

Locate and copy the following files from the output of rainbow into the remix dir:
* The final curated zotu table: "zotu_table_final_curated.tsv"
* The LCA intermediate file: "lca_intermediate.tsv"
* The fasta file with the zotu sequences: "<run dir name>_zotus.fasta"

Example:
```
cp ../blast_0_0_lca_70_70_1000hits_midori2/output/zotus/blast_0_0_lca_70_70_1000hits_midori2_zotus.fasta .
cp ../blast_0_0_lca_70_70_1000hits_midori2/output/taxonomy/lca/qcov70_pid70_diff1/lca_intermediate.tsv .
cp ../blast_0_0_lca_70_70_1000hits_midori2/output/final/zotu_table_final_curated.tsv .
```

Execute `rainbow2remix.sh`
```
sbatch ../../scripts/rainbow2remix.sh
```

Check the `rainbow2remix-*.out` file and see that the script found all files and generated no errors.

If the script run successfully, it would have generated the `remix_sum.tsv` and `zotu_seqs.tsv` 
which are the two input files for the remix script 

Note: This script will delete the copies of the rainbow output you just made. 
If something goes wrong, you will need to make those copies again.

## REVAMP

---

<details><summary>Disclaimer</summary>
<p>

This repository is a scientific product and is not official communication of the National Oceanic and
Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code
is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the
Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub
project will be governed by all applicable Federal law. Any reference to specific commercial products,
processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply
their endorsement, recommendation or favoring by the Department of Commerce. The Department of
Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply
endorsement of any commercial product or activity by DOC or the United States Government

</p>
</details>



