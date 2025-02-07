# Working on SEDNA

This README documents general information and provides a loose guide to help you work on NOAA’s supercomputer **SEDNA**

Please read the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0)

Many of the steps and info in this README were copied from the above document.

---

## SEDNA info

**SEDNA General Specs:**

* Head (login) node
* NFS storage
* Fast scratch storage (43 Tb and 91 Tb on two different RAID0 arrays)
* Shared storage

** Nodes and Partitions:**

36 standard compute nodes across
	* **SLURM PARTITION: standard**
		* node01-28:  96 GB of memory, 12x 8GB
		* Default partition; 8hr default time for jobs
	* **SLURM PARTITION: medmem** 
		* node29-36: 192 GB of memory, 12x 16GB
4 high memory nodes
	* **SLURM PARTITION: himem**
		* himeme01-04: 1.5 TB of memory, 24x 64GB
		* have their own scratch (/data) space


Is possible to run jobs in multiple partitions with”
```
#SBATCH -p standard, medme
```

---

## SEDNA SETUP

**SEDNA Account**

First of all, you need to get an account setup. Talk to your supervisor for this. 
* you will need to create an new password:
	* 14 characters long
	* cannot have the same character twice in a row , for example “aa” , “55”
	* both upper and lower case characters
	* contain digits and symbols


**Connecting to SEDNA:**

You need to be in the VPN. Ask IT to help you set up the VPN in your computer.

Address:  ***sedna.nwfsc2.noaa.gov*** (IP: 161.55.52.157)

Navigation to Sedna (on the NMFS network, or through VPN): 
```
ssh <username>@sedna.nwfsc2.noaa.gov
```
*your username will be given to you once you setup an account*

Read the [SEDNA bioinformatics cluster information, use & best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0)

Each user has 4TB of space in their home directory. You can check your quota with:
```
ssh nfs quota -s
```

---

## Modules

Most software is stored in modules. To use modules ***do this once*** (only need to do it one time but you will need to log out and back in for the changes to take effect the first time):

```
echo 'export MODULEPATH=${MODULEPATH}:/opt/bioinformatics/modulefiles' >> ~/.bashrc
```

If this worked, you should now be able to see the list of modules with:

```
module av
```

this will look something like:
```
-------------------------------------------------------------------------- /opt/modulefiles ---------------------------------------------------------------------------
   gcc/8.3.1    mpich/3.3.2-gcc-8.3.1    mvapich2/2.3.3-gcc-8.3.1    openmpi/3.1.6-gcc-8.3.1    openmpi/4.0.3-gcc-8.3.1 (D)

------------------------------------------------------------------- /opt/bioinformatics/modulefiles -------------------------------------------------------------------
   R/3.4.2                            bio/blast/2.15.0+       (D)    bio/msmc2/2.1.2                  bio/stacks/2.55
   R/4.0.3                            bio/busco/4.1.4                bio/neestimator/2.1              bio/stacks/2.62
   R/4.4.1                     (D)    bio/busco/5.2.2                bio/newhybrids/202211            bio/stacks/2.65                (D)
   aligners/bowtie2/2.4.2             bio/busco/5.3.2         (D)    bio/ngsadmix/32                  bio/stringtie/2.2.0
   aligners/bowtie2/2.5.0      (D)    bio/cactus/1.2.3               bio/ngsld/1.1.1                  bio/structure/2.3.4
   aligners/bwa-mem2/2.2.1            bio/cellranger/3.1.0           bio/ngsld/1.2.0           (D)    bio/subread/2.0.3
   aligners/bwa/0.7.17                bio/cellranger/6.0.0    (D)    bio/ngsrelate/20210126           bio/treepl/202412
   aligners/hisat2/2.2.1              bio/clumpp/1.1.2               bio/ngstools/202202              bio/trf/4.09
   aligners/lastz/1.04.22             bio/clustalo/1.2.4             bio/ohana/202105                 bio/trimmomatic/0.39
   aligners/minimap2/2.18             bio/colony/2.0.6.7             bio/papara/2.5                   bio/vcftools/0.1.16
   aligners/mummer/4.0.0rc1           bio/dadasnake/0.11.1           bio/paup/4.0a168                 bio/vep/103.1
   aligners/salmon/1.4.0              bio/decona/0.1.2               bio/pcangsd/0.99                 bio/vsearch/2.29.2
```

To load modules:
```
module load <program>
```

To see a list of loaded modules you would type the following:
```
module list
```

Loading different versions of the same program might cause issues. If needed, unload the version not going to use first then load the correct one.
```
module unload <program>
```

`module purge` will unload all modules.

---

## Dependencies and other installation

Different pipelines and programs will need diffferent dependencies. Some might be installed already, others you can intall yourself, and other you will need to request intallation.

Install requests and general help is available via the [SEDNA helpdesk google form](https://docs.google.com/forms/d/e/1FAIpQLSf2tDl9nJjihmHX9hM6ytMI3ToldqERVem1ge25-kp3JHw3tQ/viewform)

see example below

### rainbow_bridge installation

You will need to activate various dependencies to use rainbow_bridge and other tools. 

Start with activating 'mamba' with:
```
/opt/bioinformatics/mambaforge/bin/mamba init
```
***This needs to be run only once***. This will modify your .bashrc so you need to exit your shell and reconnect again after.


To double check that this worked you can type the following commands:
```
mamba --version
```
You should get something like:
```
mamba 1.5.3
conda 23.10.0
```

Then:
```
mamba env list
# conda environments:
#
base                 	/opt/bioinformatics/mambaforge
busco-5.4.7          	/opt/bioinformatics/mambaforge/envs/busco-5.4.7
cd-hit-4.8.1         	/opt/bioinformatics/mambaforge/envs/cd-hit-4.8.1
cutadapt-4.4         	/opt/bioinformatics/mambaforge/envs/cutadapt-4.4
decona-0.1.2         	/opt/bioinformatics/mambaforge/envs/decona-0.1.2
...

```

Now… to activate a conda/mamba environment type:
```
mamba activate <env>
```
When a user is done using mamba they just need to type
```
mamba deactivate
```

**Note: SLURM does not read .bashrc or .bash_profile when launching a job via sbatch. If you want to use mamba with a sbatch job you need to add the following to your job script before you activate mamba (this is assuming you added the eval line to your .bashrc)**

Your script needs to have:
```
source ~/.bashrc
```

Ok, you are now ready to activate Singularity and NexFlow which are the two main dependencies of rainbow_bridge.

```
mamba activate singularity-3.8.6
mamba activate nextflow-24.04.4
```

**PROBLEM (FEB 3 2025):**

When I activate nextflow, this deactivates singularity, and 

viceversa. I need to know how to activates both simultaneously.

1. Maybe I can activate one of the above using conda ???
2.-


You can check if these worked with:
```
which singularity
which nextflow
```
which will give you the version


Great! You are ready to use Singularity.

`rainbow_bridge` and other tools rely on *singularity* and *nexflow*.



## Usage 

* It is recommended that you run programs/pipeline using a SLURM script.
	* This will help you keep track of your work and Help with reproducibility
	* See SLURM script examples at the end of this README

* If you are going to be using singularity or nextflow straight from the terminal. You need to log into a computing node (i.e. do not do work/analyses in the login node)

Grab a node (see the beginning of this document to learn about the available nodes):

Fisrt see the current node usage with:
```
sinfo
```
This will show you something like:
```
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST 
standard*    up   infinite      7    mix node[10-13,25-26,28] 
standard*    up   infinite     10  alloc node[01-09,27] 
standard*    up   infinite     11   idle node[14-24] 
himem        up   infinite      2    mix himem[01-02] 
himem        up   infinite      2   idle himem[03-04] 
medmem       up   infinite      1    mix node29 
medmem       up   infinite      7   idle node[30-36] 
```
In this case, there are 11 standard nodes (node14-24) and 7 medmem nodes (node30-36) that are "idle" meaning that they are available.

ssh into an idle node with:
```
ssh node33
```

Activate singularity and/or nextflow as before.

* If you are going to execute bash script (recommended), you don’t need to grab a node, the SLURM will automatically place your job in the specified node(s). Just include the activation of singularity and nextflow in your script.

---

## Setting up the (MIDORI2 database)[https://www.reference-midori.info/]

### Midori2 SEDNA location
```
/share/all/midori2_database
```

NCBI GenBank databases are known to have various problems such as erroneous identification of organisms, potential lack of sequence curation, ets. This is where Midori2 can help. 

**Midori2** is a set of publicly accessable, already curated mitochondrial marker or amino acid databases (from NCBI GenBank) that get updated every few months and are useful for metabarcoding analyses. In addition, these databases have also pre-formatted to fit many common metabarcoding pipelines, and raw sequences are also available if your desired formatt is not included.

Key features:
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

I went ahead and downloaded and setup the (Midori2 database)[https://www.reference-midori.info/] in SEDNA

Parent directory for midori2 databases
```
/share/all/midori2_database
```

I decided to start by setting up the COI species "sp" "uniq" which retains all haplotypes from all taxonomic labels. For instance, this will include all sequences that have been matched to only a genus or a family. 

This database lives in:
```
/home/egarcia/databases/midori2_customblast_sp_uniq
```







I downloaded the SP Uniq COI to begin with
```
wget -c https://www.reference-midori.info/download/Databases/GenBank261_2024-10-13/RAW_sp/uniq/MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta.gz
```

***NOTE:*** The Midori2 database get updated every 2 months. Make sure you download the latest and note which version you are using.

### Prep Fasta for makeblastdb

*Next problems:*

* Midori2 raw fasta files have sequence names with the entire taxonomic information making these super long and makeblastdb has a limit of 50 characters.
* makeblastdb requires a taxid_map file where the read names and NCBI taxonomic id are provided in the column1 and column2, respectively (tab separated)

To solve this, I created the script `clean_midori2fasta_for_makeblastdb.sh` that cleans the midori2 raw fasta. This script lives in `/home/egarcia/databases/midori2_customblast_sp_uniq/clean_midori2fasta_for_makeblastdb.sh`

Cleanning includes:
1. Keeping only the accession number and species (and sub-species of hybrid) info (removes extra taxonomic info such as higher taxo-levels)
2. Truncates names to 50 characters
3. Makes the taxid_map file. Luckily the ncbi taxid of each species is given by midori2 already. This script harvest this info.

***NOTE:*** This process might take a while so might be a good idea to use a screen

Move the working dir and created a dir for the corresponding version of the midori2 database:
``` 
cd /home/egarcia/databases/midori2_customblast_sp_uniq/
Mkdir 2024-10-13
```

Execute `clean_midori2fasta_for_makeblastdb.sh` with:
# bash clean_midori2fasta_for_makeblastdb.sh  <input dir> <input_fasta> <output_fasta>
bash clean_midori2fasta_for_makeblastdb.sh 2024-10-13 2024-10-13/MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW.fasta MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta
```
where `input_dir` is the directory with the midori2 file you downloaded, `input_fasta` is the input file name, and `output_fasta` is the "cleaned" output file name, which will be used to make the database


Then, I downloaded the singularity image of the latest version of blastn:
```
mkdir /home/egarcia/databases/ncbi
cd /home/egarcia/databases/ncbi

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
cd /home/egarcia/databases/midori2_customblast_sp_uniq/2024-10-13

# make database
singularity exec ../../ncbi/blast_latest.sif makeblastdb -in MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta -parse_seqids -dbtype nucl -taxid_map taxid_map -out midori2_customblast_sp_uniq
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
singularity exec ../../ncbi/blast_latest.sif blastdbcmd -info -db midori2_customblast_sp_uniq
```

This should give you an output like:
```
Database: MIDORI2_UNIQ_SP_NUC_GB263_CO1_RAW_cleanedformakeblastdb.fasta 
	2,985,458 sequences; 1,927,792,267 total bases

Date: Jan 30, 2025  8:23 PM	Longest sequence: 2,298 bases 

BLASTDB Version: 5 

Volumes: /home/egarcia/databases/midori2_customblast_sp_uniq/2024-10-13midori2_customblast_sp_uniq
```

***If you see errors or messages about mapping, there might be issues and you might have to remake it.***

Now, open permissions to avoid potential problems accessing the database:
```
chmod 775 *
```

When you use this, make sure to specify the full path and the basename but do not include the extensions (.ndb|.nhr|.nos etc). For example:
```
/home/u.eg195763/GCL/databases/midori2_customblast_longest/midori2_customblast_sp_uniq
```

***Perfect!!!*** Now you have a custom BLAST database ready for `rainbow_bridge`



QUESTIONS:

Should I put Midori2 in scratch/blastdb?


---

---

## SLURM script examples

Regular Job Script:
```
#!/bin/bash

#SBATCH --job-name=<job name>
#SBATCH --output=<name of log file>

#SBATCH --mail-user=<email address>
# See manual for other options for --mail-type
#SBATCH --mail-type=ALL

#SBATCH -p <name of partition to use, without this option uses default partition>
#SBATCH -c <number of cpus to ask for>

#SBATCH -t <walltime in mins or mins:secs or hrs:mins:secs (see manual)>
#SBATCH -D <folder to change to when starting the job>

# Commands to run
```

Array Job Script:
```
#!/bin/bash

#SBATCH --job-name=<job name>

# The %A is replaced with the jobID 
# The %a is replaced by the array ID
#SBATCH --output=job_logfile.%A.%a.txt

# Set array size, in this case 1 through 10 but limit the number of
# array sub jobs to 2 at a time.
# see the BLAST example in Appendix C in the SEDNA info & best practices doc
#SBATCH --array=1-10%2

#SBATCH -c <number of cores to ask for per array job>

# Other SBATCH options

# Commands to run for each array job
# Note: The variable SLURM_ARRAY_TASK_ID gets set to the array job ID
```

More examples available in the [SEDNA info & best practices doc](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0)

---
