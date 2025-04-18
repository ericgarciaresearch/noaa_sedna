#!/bin/bash

#SBATCH --job-name=checkFQ
#SBATCH --output=checkFQ-%j.out      # Standard output and error log (%j will be replaced by job ID)
#SBATCH --exclusive                  # Request exclusive access to node
#SBATCH --partition=cpu              # Partition name (change to 'gpu' if needed)
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --ntasks=1                   # Number of tasks (usually 1 for single-job scripts)
#SBATCH --cpus-per-task=40           # Number of CPU cores per task
#SBATCH --mem=64G                    # Total memory per node (adjust as needed)
#SBATCH --time=2-00:00:00            # Time limit (D-HH:MM:SS)

echo -e "############  checkFQ.sh  ############\nThis script checks the size as well as the\nzip and fastq formats in your .gz files.\nFiles with\npotentially problematic size, zip\nor fastq formats will be printed in the log\n and respectively saved to:\n\nfiles_wDiff_sizes.txt\nfiles_w_alternative_zip_format.txt\nfiles_w_bad_fastq_format.txt\n\nYou might want to try to redownload\nthese .gz files and/or check for\nissues with the formats\n######################################\n\n"

# This scripts assumes that the tamucc_files.txt exits in the same directory as fq|fastq.gz files
# Normal .gz files would have the following format: Blocked GNU Zip Format (BGZF; gzip compatible), block length xxxxxx
# Alternative formats do not necessarily cause problems but they should be checked

# Directory with .gz data files
DATADIR=$1

#Move to working dir
cd $DATADIR

# Compare size of tamucc and lauch files
# Check if the tamucc_files was created with ls or ls -lthr, and use that list to download files
if [ ! -e "tamucc_files.txt" ]; then
    echo "Cannot find 'tamucc_files.txt'. Place this file in the same directory as .gz files to  compare sizes. Skipping size check"
fi

NCOL=$(cat tamucc_files.txt | tail -n1 | awk '{print NF}')

if [[ $NCOL -eq 9 ]]; then 
	# Checking sizes of files from source and lpwd
	echo -e "\nComparing file sizes from source (TAMUCC) and lpwd (Lauch) with (grep -vf). This script assumes files have the same name"
	# Create Intermediate files
	cat tamucc_files.txt | grep '[zv]$' | tr -s " " | cut -d " " -f5,9 > tamucc_gzfiles
	ls -lh *[zv] | tr -s " " | cut -d " " -f5,9 > lauch_gzfiles

	grep -vf tamucc_gzfiles lauch_gzfiles > files_w_Diff_sizes.txt
fi

if [[ -s files_w_Diff_sizes.txt ]]; then
        echo -e "\nFiles with different sizes detected. Offending file(s) printed in files_w_Diff_sizes.txt. Please check files_w_Diff_sizes and compare tamucc_files.txt with current downloaded data"
        rm tamucc_gzfiles lauch_gzfiles
else 
        echo -e "\nNo size mismatch in files was detected"
	echo -e "\nNo size mismatch in files was detected" > files_w_Diff_sizes.txt
        rm tamucc_gzfiles lauch_gzfiles
fi

# Check the file format of each .gz
echo  -e "\nChekcing zip format in files"
ls *.gz | parallel --no-notice -kj40 file {} > file_types.txt

# Print files without Blocked GNU Zip Format
echo -e "Checking if any .gz file has another format other than <Blocked GNU Zip Format>.\nIf all downloaded files have the format: Blocked GNU Zip Format, files_w_alternative_zip_format.txt will be empty\n\n"

mkdir -p fqgz_fileCheck
echo "Files with an alternative zip format:"
cat file_types.txt | grep -v 'Blocked GNU Zip Format'
cat file_types.txt | grep -v 'Blocked GNU Zip Format'> files_w_alternative_zip_format.txt
mv file_types.txt fqgz_fileCheck

# Checking that files have proper FASTQ format (4 lines per sequence, where the 3rd is a "+")
echo -e "\nChecking if files have proper FASTQ format (4 lines per sequence, where the 3rd is a +)\nResults will be printed in the log and in  files_w_bad_fastq_format.txt\n"

ls *.gz | sed 's/\.gz//' | parallel --no-notice -kj40 "zcat {}.gz | paste - - - - | cut -f3 | sort | uniq -c > fqgz_fileCheck/{}.third_column.txt"

# Iterate through each file in the directory
for file in fqgz_fileCheck/*third_column.txt; do
    # Check if the file is a regular file and not a directory
    if [ -f "$file" ]; then
        line_count=$(wc -l < "$file")
	BASE=$(echo $file | sed -e 's/.*\///' -e 's/\.third_column\.txt//')
        if [ $line_count -gt 1 ]; then
		echo "File with one or more reads WITHOUT proper fastq format: $BASE.gz"
		echo "$BASE.gz" >> files_w_bad_fastq_format.txt
        elif [ $line_count -eq 1 ]; then
            echo "File with proper fastq format: $BASE.gz"
	    echo "No issues detected. All files seem to have proper fastq format" > files_w_bad_fastq_format.txt
        else
            echo "Empty file: $BASE.gz"
        fi
    fi
done

