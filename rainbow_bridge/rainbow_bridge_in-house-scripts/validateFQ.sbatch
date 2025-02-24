#!/bin/bash -l

# check to see if fastq files are formatted correctly

#SBATCH --job-name=vld8FQ
#SBATCH -o valiate_FQ_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env fastq_utils
export SINGULARITY_BIND=/home/e1garcia

dirPATH=$1
fqPATTERN=$2

: ${dirPATH:="."}

ls $dirPATH/$fqPATTERN | \
  parallel --no-notice -k crun.fastq_utils "fastq_info {}" &> $dirPATH/fqValidationReport.txt

echo FASTQ VALIDATION REPORT -Paired Ends Not Tested
echo
echo Directory: $dirPATH
echo File Pattern: $fqPATTERN
echo
echo Number of fq files evaluated: $(ls $dirPATH/$fqPATTERN | wc -l)
echo Number of fq files validated: $(grep -c "^OK$" $dirPATH/fqValidationReport.txt)
echo
echo Errors Reported:
grep "^ERROR" $dirPATH/fqValidationReport.txt
