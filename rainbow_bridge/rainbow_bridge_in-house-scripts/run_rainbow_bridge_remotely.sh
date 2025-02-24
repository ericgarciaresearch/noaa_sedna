#!/bin/bash
#SBATCH --job-name=rainbow_bridge    # Job name
#SBATCH --partition=cpu              # Partition name (change to 'cpu' 360G or 'gpu' 740G as needed)
#SBATCH --mem=340G                    # Total memory per node (adjust as needed)
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --ntasks=192                   # Number of tasks (usually 1 for single-job scripts)
#SBATCH --cpus-per-task=1           # Number of CPU cores per task
#SBATCH --time=2-00:00:00            # Time limit (D-HH:MM:SS)
#SBATCH --output=rainbow_bridge-%j.out     # Standard output and error log (%j will be replaced by job ID)
#SBATCH --mail-type=END,FAIL              #Send email on all job events
#SBATCH --mail-user=user@tamucc.edu    #Send all emails to email_address
##SBATCH --ntasks=8                   #Request 8 tasks
##SBATCH --ntasks-per-node=2          #Request 2 tasks/cores per node

############################
### run_rainbow_bride.sh ###
############################

# This script runs rainbow_bridge in the TAMU Supercomputer 'Launch'. After logging in, you must enter a computing node in Launch.
# You will need a reference database and a barcode decode file if your sequences have not been demultiplex

#----------------------------
# Execute:
# sbatch run_rainbow_brigde.sh <params YAML file> 
#
# example:
# sbatch run_rainbow_brigde.sh paired_demuxed.yml 
#----------------------------

# note: I am using NCBI's nucleotide database blastn v2_16_0. You might want to check if a newer version exist in https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/
# currently this database lives in '/home/u.eg195763/GCL/databases/ncbi_2_16_0/nt'
# "nt" is the name of the NCBI's nucleotide database (without file extensions)

# Load necessary modules (Launch - TAMUCC)
module load GCC/13.2.0 rainbow_bridge/2024.07.15

# Print SLURM configuration
#env | grep SLURM

# Record the start time
start_time=$(date +%s)
echo "Start time: $(date)"
echo ""

# Get the name and full path of the script executed
script_path=$(scontrol show job $SLURM_JOB_ID | awk -F= '/Command=/{print $2}')

# Initial reporting. Print parameters used
PARAMSFILE=$1
# Write the script name to the output file
echo "The script executed is: $script_path"
echo "Script executed from: $(pwd)"
echo -e "Using params file=$PARAMSFILE\n"
echo "cat $PARAMSFILE"
cat $PARAMSFILE
echo ""

# Run rainbow_bridge with desired options
nextflow run -params-file $PARAMSFILE mhoban/rainbow_bridge
#nextflow run -params-file $PARAMSFILE /home/u.eg195763/GCL/rainbow_bridge/rainbow_bridge.nf


# Record the end time
end_time=$(date +%s)
echo ""
echo "End time: $(date)"

# Calculate the elapsed time
elapsed_time=$((end_time - start_time))

# Convert elapsed time to hours, minutes, and seconds
hours=$((elapsed_time / 3600))
minutes=$(( (elapsed_time % 3600) / 60 ))
seconds=$((elapsed_time % 60))

echo -e "Total time taken: ${hours}h ${minutes}m ${seconds}s\n"

echo -e "\nReport Resource Usage:"
seff $SLURM_JOB_ID

# Copy files for customer

# copy blast results with headings
cat ~/GCL/rainbow_bridge/blast_headings.tsv output/blast/*/blast_result_merged.tsv > ../blast_result.tsv
# copy descriptions of columns
cp ~/GCL/rainbow_bridge/blast_columns_descriptions.tsv ..
# copy raw zotu table
cp output/zotus/zotu_table.tsv ../zotu_raw_table.tsv
# copy fastqc reports
cp output/fastqc/*/*html ..
