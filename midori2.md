# Midori2 SEDNA Databases

This README documents general information about Midori2 Databases and provides a loose guide to help you use, setup or update these on NOAA’s supercomputer **SEDNA**

Note: if you are new to SEDNA or still need general help to work in SEDNA, please start by reading the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0) and/or the [Working on SEDNA README]()

---

## Midori2 Databases SEDNA locations
```
# parent dir
/share/all/midori2_database

# sub-databases
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/		
```
*if you add addintional databases please add them to the list above*

---

## Setting up the [MIDORI2 database](https://www.reference-midori.info/)

NCBI GenBank databases are known to have various problems such as erroneous identification of organisms, potential lack of sequence curation, ets. This is where Midori2 can help. 

[**Midori2**](https://www.reference-midori.info/) is a set of publicly accessable, already curated mitochondrial marker or amino acid databases (from NCBI GenBank) that get updated every few months and are useful for metabarcoding analyses. In addition, these databases have also pre-formatted to fit many common metabarcoding pipelines, and raw sequences are also available if your desired format is not included.

**Key features:**
	
	* Public

	* Public (easily downloaded ith wget or other protocols)

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

See Midori2's README in their website for more info. 

**SEDNA SETUP** 

I went ahead and downloaded and setup the [Midori2 database](https://www.reference-midori.info/) in SEDNA for rainbow_bridge.

Parent directory for midori2 databases:
```
/share/all/midori2_database
```


***NOTE:*** `rainbow_bridge` is not one of the already available formats.
	* Not a problme! We can download the RAW dataset and create a custom blast dataset :)

I decided to start by setting up the COI species "sp" , "uniq" which retains all haplotypes from all taxonomic labels. For instance, this will include all sequences that have been matched to only a genus or a family. 

### Download Database

I downloaded the SP Uniq COI to begin with (after creating a dir for the corresponding version of the midori2 database):
```
cd /share/all/midori2_database
mkdir 2024-10-13_customblast_sp_uniq_COI
cd 2024-10-13_customblast_sp_uniq_COI
wget -c https://www.reference-midori.info/download/Databases/GenBank261_2024-10-13/RAW_sp/uniq/MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta.gz
```

***NOTE:*** The Midori2 database get updated every 2 months. Make sure you download the latest and note which version you are using.

### Prep Fasta for makeblastdb

Next problems:

* Midori2 raw fasta files have sequence names with the entire taxonomic information making these super long and makeblastdb has a limit of 50 characters.
* makeblastdb requires a taxid_map file where the read names and NCBI taxonomic id are provided in the column1 and column2, respectively (tab separated)

To solve this, I created the script `clean_midori2fasta_for_makeblastdb.sh` that cleans the midori2 raw fasta. This script lives in 
```
/share/all/midori2_database/
```

Cleanning includes:
1. Keeping only the accession number and species (and sub-species of hybrid) info (removes extra taxonomic info such as higher taxo-levels)
2. Truncates names to 50 characters
3. Makes the taxid_map file. Luckily the ncbi taxid of each species is given by midori2 already. This script harvest this info.

***NOTE:*** This process might take a while so might be a good idea to use a screen


Move to the working dir (one level about the downloaded database)
``` 
cd /share/all/midori2_database
```

Execute `clean_midori2fasta_for_makeblastdb.sh` with:
```
# bash clean_midori2fasta_for_makeblastdb.sh  <input dir> <input_fasta> <output_fasta>
bash clean_midori2fasta_for_makeblastdb.sh 2024-10-13_customblast_sp_uniq_COI 2024-10-13_customblast_sp_uniq_COI/MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta
```
where `input_dir` is the directory with the midori2 file you downloaded, `input_fasta` is the input file name, and `output_fasta` is the "cleaned" output file name, which will be used to make the database


Then, I downloaded the singularity image of the latest version of blastn (.sif executable file):
```
cd /share/all/midori2_database

# grab a computing node and activate singularity
ssh node39
mamba activate singularity-3.8.6

# download .sif
singularity pull blast_latest.sif docker://ncbi/blast:latest

# check that the download worked and check the version
singularity exec blast_latest.sif blastn -version
```

Now, use the .sif to make the database:
```
cd 2024-10-13_customblast_sp_uniq_COI

# make database
singularity exec ../blast_latest.sif makeblastdb -in MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta -parse_seqids -dbtype nucl -taxid_map taxid_map -out midori2_customblast_sp_uniq
```

If this worked ok, the output should include files like these:
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

Now, check that the database was created correctly:
```
singularity exec ../blast_latest.sif blastdbcmd -info -db midori2_customblast_sp_uniq
```

This should give you an output like:
```
Database: MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta 
	2,985,458 sequences; 1,927,792,267 total bases

Date: Jan 30, 2025  8:23 PM	Longest sequence: 2,298 bases 

BLASTDB Version: 5 
```

***If you see errors or messages about mapping, there might be issues and you might have to remake the database.***

Now, open permissions to avoid potential problems accessing the database:
```
chmod 775 *
```

When you use this, make sure to specify the full path and the basename but do not include the extensions (.ndb|.nhr|.nos etc). For example:
```
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/midori2_customblast_sp_uniq
```

**Perfect!!!** Now you have a custom BLAST database ready for `rainbow_bridge`

---
