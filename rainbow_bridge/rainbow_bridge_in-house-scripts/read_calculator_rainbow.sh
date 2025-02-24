#!/bin/bash
##SBATCH --job-name=read_calc    # Job name
##SBATCH --partition=cpu              # Partition name (change to 'cpu' 360G or 'gpu' 740G as needed)
##SBATCH --mem=340G                    # Total memory per node (adjust as needed)
##SBATCH --nodes=1                    # Number of nodes
##SBATCH --ntasks=192                   # Number of tasks (usually 1 for single-job scripts)
##SBATCH --cpus-per-task=1           # Number of CPU cores per task
##SBATCH --time=2-00:00:00            # Time limit (D-HH:MM:SS)
##SBATCH --output=read_calc-%j.out     # Standard output and error log (%j will be replaced by job ID)
##SBATCH --mail-type=END,FAIL              #Send email on all job events
##SBATCH --mail-user=@tamucc.edu    #Send all emails to email_address

#######  read_calculator_rainbow.sh  ########

#read_calculator_ssl.sh counts the number of reads before and after each step in the preprocess directory and creates a table reporting:
# (1) the step-specific percent of read loss and final accumulative read loss "readLoss_table.tsv" 
# to execute:
# sbatch read_calculator_rainbow.sh <raw data directory> <rainbow_bridge directory>

# load parallel
module load GCC/13.2.0 rainbow_bridge/2024.07.15

rawdataDIR=$1
rainbowDIR=$2

# Create and move to preprocess_read_change directory
#mkdir -p ${rainbowDIR}/preprocess/read_change
#cd ${rainbowDIR}/preprocess/read_change
mkdir -p ./preprocess/read_change
cd ./preprocess/read_change

## Create temporary files with read counts
ls ../../../../data/*R1_001.fastq.gz | parallel --no-notice -kj 192 "echo -n {}'	' && zgrep '^@' {} | wc -l" > raw_r1.temp
ls ../../../../data/*R2_001.fastq.gz | parallel --no-notice -kj 192 "zgrep '^@' {} | wc -l" > raw_r2.temp
ls ../../preprocess/trim_merge/*fastq | parallel --no-notice -kj 192 "grep '^@' {} | wc -l" > trim_merge.temp
ls ../../preprocess/ngsfilter/*fastq | parallel --no-notice -kj 192 "grep '^@' {} | wc -l" > ngsfilter.temp
ls ../../preprocess/length_filtered/*fastq | parallel --no-notice -kj 192 "grep '^@' {} | wc -l" > length_filtered.temp
ls ../../preprocess/relabeled/*fasta | parallel --no-notice -kj 192 "grep '^>' {} | wc -l" > relabeled.temp

cat <(echo "file	#_F-reads_raw	#_R-reads_raw	#_reads_trim_merged	#_reads_ngsfilter	#_reads_length-fltrd	#_reads_relabeled	%_readLoss_trim_merged	%_readLoss_ngsfilter	%_readLoss_length-fltrd	%_readLoss_relabeled") <(\
        paste raw_r1.temp raw_r2.temp trim_merge.temp ngsfilter.temp length_filtered.temp relabeled.temp | \
                sed 's/.*\///' | \
		awk -F "\t" 'NR==FNR{i = ((($4/((($2+$3)/2)))*(-100))+100); print $0"\t"i }' | \
                awk -F "\t" 'NR==FNR{i = ((($5/$4)*(-100))+100);print $0"\t"i }' | \
                awk -F "\t" 'NR==FNR{i = ((($6/$5)*(-100))+100);print $0"\t"i }' | \
                awk -F "\t" 'NR==FNR{i = ((($7/$6)*(-100))+100);print $0"\t"i }') > readLoss_table.tsv

# Calculate totals
#awk '{sum += $2} END {print sum}' > total-trim.temp
#awk '{sum += $3} END {print sum}' > total-ngs.temp
#awk '{sum += $4} END {print sum}' > total-l-fltrd.temp
#awk '{sum += $5} END {print sum}' > total-rlbld.temp

echo "Total\
	$(awk '{sum += $2} END {print sum}' readLoss_table.tsv)\
	$(awk '{sum += $3} END {print sum}' readLoss_table.tsv)\
	$(awk '{sum += $4} END {print sum}' readLoss_table.tsv)\
	$(awk '{sum += $5} END {print sum}' readLoss_table.tsv)\
        $(awk '{sum += $6} END {print sum}' readLoss_table.tsv)\
        $(awk '{sum += $7} END {print sum}' readLoss_table.tsv)\
	$(awk '{sum2 += $2; sum3 += $3; sum4 += $4} END {avg23 = (sum2 + sum3) / (2 * NR); print ((avg23 - sum4) / avg23) * 100}')\
	$(awk '{sum4 += $4; sum5 += $5} END {print ((sum4 - sum5) / sum4) * 100}' readLoss_table.tsv)\
	$(awk '{sum5 += $5; sum6 += $6} END {print ((sum5 - sum6) / sum5) * 100}' readLoss_table.tsv)\
	$(awk '{sum6 += $6; sum7 += $7} END {print ((sum6 - sum7) / sum6) * 100}' readLoss_table.tsv)" >> readLoss_table.tsv

# clean up
rm *temp
