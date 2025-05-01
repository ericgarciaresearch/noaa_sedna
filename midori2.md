# Midori2 SEDNA Databases

This README documents general information about Midori2 Databases and provides a loose guide to help you use, setup or update these on NOAA’s supercomputer **SEDNA**

Note: if you are new to SEDNA or still need general help to work in SEDNA, please start by reading the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0) and/or the
 [Working on SEDNA README](https://github.com/ericgarciaresearch/noaa_sedna)

NCBI GenBank databases are known to have various problems such as erroneous identification of organisms, potential lack of sequence curation, etc. This is where Midori2 can be useful for metabarcoding analyses. 

[**Midori2**](https://www.reference-midori.info/) is a set of publicly accessable, mitochondrial marker or amino acid databases (from NCBI GenBank), that have already been curated and gets updated every few months. In addition, these databases have also been pre-formatted to fit many common metabarcoding pipelines, and raw sequences are also available if your desired format is not included.

**Key features:**
	
* Public (easily downloaded with wget or other protocols)
* Updated every few months
* Already curated mtDNA databases from NCBI
* Several formats available:  RDP,  MOTHUR, QIIME, SPINGO, SINTAX, DADA2, and BLAST+.
* Raw sequence database available for custom databases
* Multiple database types:
	* "AA" = amino acid sequence database 
	* "NUC" = nucleic acid sequence database 
	* "sp" = those databases include sequences that lack binomial species-level description, such as "sp.," "aff.," "nr.," "cf.," "complex," and "nomen nudum." 
	* "UNIQ" = UNIQ files contain all unique haplotypes associated with each species.
	* "LONGEST" = LONGEST files contain the longest sequence for each species.

See [Midori2's README](https://www.reference-midori.info/download.php) in their website for more info. 

---

## Midori2 Databases SEDNA locations
```
# parent dir
/share/all/midori2_database

# sub-databases
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI
/share/all/midori2_database/2024-12-14_customblast_sp_uniq_COI
/share/all/midori2_database/2024-12-14_customblast_sp_uniq_12S
/share/all/midori2_database/2025-03-08_customblast_sp_uniq_16S
```
**if you add addintional databases please add them to the list above**

***As in April 30th, 2025, the 2025-03-08 is the latest release***

---

## Setting up the MIDORI2 database

**SEDNA SETUP** 

I have downloaded and setup the [Midori2 database](https://www.reference-midori.info/) for few markers in SEDNA since I'll be using these with `rainbow_bridge`.

Parent directory for midori2 databases:
```
/share/all/midori2_database
```

***NOTE:*** `rainbow_bridge` is not one of the formats already available.

* No problemo! We can download the RAW dataset and create a custom blast dataset :)

I decided to start by setting up the COI species "sp" , "uniq" which retains all haplotypes from all taxonomic labels. For instance, this will include all sequences that have been matched to only a genus or a family. 

**Screen and Interactive Node** 
Some ofe these processes might take a while so it might be a good idea to run this using [screen](https://www.gnu.org/software/screen/manual/screen.html) which is already installed in SEDNA and use srun to allocate resources.

To start a screen you can use:
```
#screen -S <screen_name>
screen -S midori2_COI
```
where the `-S` allows you to provide a name to the screen.

a few useful `screen` commands:
```
screen -L  		# will create a log
screen -L -S <name>	# log and screen name
Ctrl-a d		# detach from screen. If you want to leave that running and work outside the screen
screen -ls		# lists all available screens
screen -r <name>	# re-attaches to the specific screen 
screen -S <name> -X quit  # to kill screen from outside the screen (detached)
exit			# kills the screens
```
for a more details here is a [screen tutorial](https://linuxize.com/post/how-to-use-linux-screen/) 

Then, request an interactive node:
```
srun --partition=standard --mem=4g --time=00:30:00 --pty bash
```
30 min and 4Gb of memory should be enough. You might have to wait a bit to get the resquested resources, 1-2 min is normal. If this is taking much longer or gets stuck, cancell it then view what's available, you might have to request a `medmem` node. For example:
```
control + c             # this cancels your command
sinfo			# will list all nodes. Look for "idle" nodes in a particular partition"
srun --partition=medmem --mem=4g --time=00:30:00 --pty bash	# will request now a medmem node 
```

### Downloading the a database

I created a dir for the corresponding version of the midori2 database and I downloaded the SP Uniq COI to begin with using srun (you can follow these steps to create new databases with other markers, etc.):
```
cd /share/all/midori2_database
mkdir 2024-10-13_customblast_sp_uniq_COI
cd 2024-10-13_customblast_sp_uniq_COI
srun wget -c https://www.reference-midori.info/download/Databases/GenBank261_2024-10-13/RAW_sp/uniq/MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta.gz
```
*modify the link according to the database you are downloading*

Now umcompress the file for the next step:
```
gunzip MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta.gz
```

***NOTE:*** The Midori2 database gets updated every few months. Make sure you download the latest and note which version you are using in your metadata and READMEs, etc.

### Prep Fasta for makeblastdb

Next problems:

* Midori2 raw fasta files have sequence names with the entire taxonomic information making these super long and `makeblastdb` has a limit of 50 characters.
* `makeblastdb` requires a `taxid_map` file where the read names and NCBI taxonomic ids are provided in the column1 and column2, respectively (tab separated).

To solve this, I created the script `clean_midori2fasta_for_makeblastdb.sh` that cleans the midori2 raw fasta and generates a taxid_map. This script lives in 
```
/share/all/midori2_database/
```

Cleanning includes:
1. Keeping only the accession number and species (and sub-species of hybrid) info but it removes extra taxonomic info such as higher taxo-levels.
2. Truncates names to 50 characters
3. Makes the `taxid_map` file. Luckily the ncbi taxid of each species is given by midori2 already. This script harvest this info.


Move to the working dir (one level about the downloaded database)
``` 
cd /share/all/midori2_database
```

Execute `clean_midori2fasta_for_makeblastdb.sh` with:
```
# bash clean_midori2fasta_for_makeblastdb.sh  <input dir> <input_fasta> <output_fasta>
bash clean_midori2fasta_for_makeblastdb.sh 2024-10-13_customblast_sp_uniq_COI MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta
```
where `input_dir` is the directory with the midori2 file you downloaded, `input_fasta` is the input file name, and `output_fasta` is the "cleaned" output file name, which will be used to make the database

* Inspect the resulting fasta file: see that names are correctly truncated and have the taxid at the end, etc. For example:
```
>MH910097.1.Paravannella_minima_1443144
ATGGATACCTTGGCATTAAATAAAGAGGACGTAAGTATGCGAAAAGTTACAGGGAGTTTA
ATACTGTGATCTGTAAATTTCCTTGAGTAAACTCATTTAATTTTTTTTCTATTTAATGAA
TTGAAACATCTTAGTAATTAAAAGTAAAATAAATCAAACGAGATTTCATTAGTAGCGGTG
AGCGAATGTGAATTAGGCCTTTTATTTGTATTAATCAGTAGAAAATTTTCGAATAAATTA
...
```

* Inspect the taxid_map: see that it contains the same sequence names and taxids separated by a tab. For example:
```
MH910097.1.Paravannella_minima_1443144  1443144
MH535961.1.Vannella_sp._1973054 1973054
MH535965.1.Vannella_sp._1973054 1973054
MH535960.1.Vannella_sp._1973054 1973054
...
```

Then, download the singularity image of the latest version of blastn (.sif executable file):
```
cd /share/all/midori2_database

# activate singularity
mamba activate singularity-3.8.6

# download and overwrite the existing .sif
singularity pull --force blast_latest.sif docker://ncbi/blast:latest
```
*overwritting ensures you are running the lastest version should a new version be available*

Check that the download worked and check the version
```
singularity exec blast_latest.sif blastn -version
```
You should see an output similar to:
```
blastn: 2.16.0+
 Package: blast 2.16.0, build Jul 12 2024 20:19:54
```
Make a note of the version in your metadata and/or readmes

Now, use the .sif to make the database:
```
cd 2024-10-13_customblast_sp_uniq_COI

# make database
singularity exec -B "$PWD" ../blast_latest.sif makeblastdb -in MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta -parse_seqids -dbtype nucl -taxid_map taxid_map -out midori2_customblast_sp_uniq
```
**modify the input file as needed**

If this worked ok, you should see a message like:
```
Building a new DB, current time: 04/15/2025 17:09:42
New DB name:   /share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/midori2_customblast_sp_uniq
New DB title:  MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta
Sequence type: Nucleotide
Keep MBits: T
Maximum file size: 3000000000B
Adding sequences from FASTA; added 3003352 sequences in 71.132 seconds.
```

and you should now have files like these:
```
midori2_customblast_sp_uniq.ndb
midori2_customblast_sp_uniq.nhr
midori2_customblast_sp_uniq.nin
midori2_customblast_sp_uniq.njs
midori2_customblast_sp_uniq.nog
midori2_customblast_sp_uniq.nos
midori2_customblast_sp_uniq.not
midori2_customblast_sp_uniq.nsq
midori2_customblast_sp_uniq.ntf
midori2_customblast_sp_uniq.nto
```
where `midori2_customblast_sp_uniq` is just the name I chose for the output in the previous command.

If you got errors try rerunning it or further troubleshoot with ChatGPT, etc.

Now, check that the database was created correctly:
```
singularity exec -B "$PWD" ../blast_latest.sif blastdbcmd -info -db midori2_customblast_sp_uniq
```

This should give you an output like:
```
Database: MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta 
	2,985,458 sequences; 1,927,792,267 total bases

Date: Jan 30, 2025  8:23 PM	Longest sequence: 2,298 bases 

BLASTDB Version: 5 
```

Now, open permissions to avoid potential problems accessing the database and kill your screen as needed:
```
chmod 775 *
exit			# kicks you out of the interactive node allocated by srun
exit			# kicks you out of screen and puts you back in the login node
```

When you use this, make sure to specify the full path and the basename but do not include the extensions (.ndb|.nhr|.nos etc). For example:
```
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/midori2_customblast_sp_uniq
```

**Perfect!!!** Now you have a custom BLAST database ready for your analyses.

---
