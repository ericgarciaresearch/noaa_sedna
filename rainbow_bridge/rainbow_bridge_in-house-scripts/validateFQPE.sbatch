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

fileEXTENSIONS=($(ls $dirPATH/$fqPATTERN | sed 's/.*\([\._][rR]*[12]\.fa*s*t*q\.gz\)/\1/g' | sort | uniq))

if [ ${#fileEXTENSIONS[@]} -gt 2 ]; then
  echo "Error: Too many file extensions found: ${fileEXTENSIONS[*]}" >&2
  exit 1
fi

ls $dirPATH/$fqPATTERN | \
  sed 's/[\._][rR]*[12]\.fa*s*t*q\.gz//g' | \
  uniq | \
  parallel --no-notice -k crun.fastq_utils "fastq_info {}${fileEXTENSIONS[0]} {}${fileEXTENSIONS[1]}" &> $dirPATH/fqValidationReport.txt

echo PAIRED END FASTQ VALIDATION REPORT
echo
echo Directory: $dirPATH
echo File Pattern: $fqPATTERN
echo File extensions found: ${fileEXTENSIONS[*]}
echo
echo Number of paired end fq files evaluated: $(ls $dirPATH/$fqPATTERN | sed 's/[\._][rR]*[12]\.fa*s*t*q\.gz//g' | uniq | wc -l)
echo Number of paired end fq files validated: $(grep -c "^OK$" $dirPATH/fqValidationReport.txt)
echo
echo Errors Reported:
grep "^ERROR" $dirPATH/fqValidationReport.txt
