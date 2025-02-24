#!/bin/bash
#SBATCH --job-name=plots
#SBATCH --output=plots-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=cpu                # Partition name (change to 'cpu' 360G or 'gpu' 740G as needed)
#SBATCH --time=2-00:00:00              # Time limit (D-HH:MM:SS)
#SBATCH --output=blast-taxo-%j.out     # Standard output and error log (%j will be replaced by job ID)
#SBATCH --mail-type=END,FAIL           #Send email on all job events
#SBATCH --mail-user=@tamucc.edu        #Send all emails to email_address

# Load necessary modules
module load R/4.3.3

# Define the input file path
INPUT_FILE=$1

# Run the R script with the input file as an argument
Rscript /home/u.eg195763/GCL/prj_sheehy-metabarcoding/scripts/plot_rainbow_results.R $INPUT_FILE
