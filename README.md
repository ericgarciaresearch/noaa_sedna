# Working on SEDNA

This README documents general information and provides a loose guide to help you work on NOAA’s supercomputer **SEDNA**. 

Please read the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0)

Many of the steps and info in this README were summarised from the above document.

## What is SEDNA?

You're presumably working with genomic data, and your tiny laptop doesn't have enough memory, cpus, or storage to analyze these data. This is why we need SEDNA. Basically,  SEDNA is a bunch of computers that live at NWFSC (FYI- this is where all "the cloud" is too). These computers have more memory and storage than your computer and don't need to turn off at the end of the day, so we can run large, memory intensive, and long jobs on SEDNA. To do this, we have to access SEDNA via the command line and submit "jobs", which is just a set of commands we're telling SEDNA to run. This is how you will do your analyses.

When you submit a job, SEDNA distributes it to the compute nodes. You have to tell SEDNA exactly how many resources you want it to use. For example, how much memory, time, cores, etc. We will talk about this more later in this document.

---

## SEDNA hardware info

**SEDNA General Specs:**

* Head (login) node
* NFS storage
* Fast scratch storage (43 Tb and 91 Tb on two different RAID0 arrays)
* Shared storage

**Nodes and Partitions:**

40 compute nodes across:

* **SLURM PARTITION: standard** 
	* node01-28:  96 GB of memory, 12x 8GB
 	* 20 cores/node
	* Default partition; 8hr default time for jobs
* **SLURM PARTITION: medmem** 
	* node29-36: 192 GB of memory, 12x 16GB
 		* SLURM only allows setting `--mem` to 185G at most 
 	* 20 cores/node 

* **SLURM PARTITION: himem**
	* himem01-04: 1.5 TB of memory, 24x 64GB
 	* 4 cores/node	
	* have their own scratch (/data) space

---

## SEDNA SETUP

**SEDNA Account**

First of all, you need to get an account setup. Talk to your supervisor for this or if you work at PIFSC you can submit a [Jira ticket](https://apps-st.fisheries.noaa.gov/jirasm/servicedesk/customer/portal/4) 

You will need to create an new password:
* 14 characters long
* cannot have the same character twice in a row , for example “aa” , “55”
* both upper and lower case characters
* contain digits and symbols

**Connecting to SEDNA:**

You need to be on the VPN. Ask IT to help you set up the VPN in your computer (PIFSC you can submit a [Jira ticket](https://apps-st.fisheries.noaa.gov/jirasm/servicedesk/customer/portal/4)).

Address:  ***sedna.nwfsc2.noaa.gov*** (IP: 161.55.52.157)

Navigation to Sedna (on the NMFS network, or through VPN): 
```
ssh <username>@sedna.nwfsc2.noaa.gov
```
*your username will be given to you once you setup an account*

Now read the [SEDNA bioinformatics cluster information, use & best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0) if you haven't done so already.

Each user has 4TB of space in their home directory. You can check your quota with:
```
ssh nfs quota -s
```

---

## Login vs Compute Nodes

When you first login into SEDNA you will be in the login node. You know you are in the login now when your prompt line reads something like:
```
(base) [userID@sedna currentDIR]$
```

It is ok to do some light processes like navigation, listing, file organization, etc. However, you should NOT do any mid to heavy computations in the login node. You should instead either run a script, which will automatically grab a computing node, or you can use `srun` to start an interactive job on a computing node (i.e. sdandard, medmem or himem nodes).

All jobs on SEDNA are managed by [SLURM](https://slurm.schedmd.com/documentation.html). What this means is that you will submit a job via slurm where you request some set of resources (memory, cpus, time). Slurm will put you in the queue to get those resources. Once the resources are available, your job will start. 

There are two types of jobs: interactive and batch

### interactive jobs

You can run interactive jobs where sedna will allocate resource and you can run your code one line at at time. Here is an example:

```bash
srun --partition=standard --mem=4g --time=02:00:00 --pty bash
```

Now my prompt looks like:
```
(base) [egarcia@node36 currentDIR]$
```
In this case, we asked for 4 gb of memory for 2 hours on the standard partition. We ask for a bash job (i.e., just your normal command line). 

### batch jobs

Most jobs and the true power of a SEDNA is via batch jobs. These are jobs that we submit to run non-interactively. 


```bash
sbatch test.sbatch
```
and after we submit will say:
```
Submitted batch job 2060966
```

where `test.sbatch` might look like this:

```bash
#!/bin/bash
#SBATCH --partition=standard
#SBATCH --time=02:00:00
#SBATCH --mem=4G

echo "Hello!"
```

Notice that we requested the same resources as our `srun` job, above.

This will write the output to our std out file: `slurm-2060966.out`

which looks like this:
```
$cat slurm-2060966.out
Hello!
```

There are many, many slurms options to put in the file and the example above is very minimal. Most of the parameters have a default, but you should specify these yourself so you're efficiently using resources. 

Also, for your own jobs, you would replace `echo "Hello!"` with something actually useful. 

To see currently runnings jobs enter: `squeue`

To see just your jobs: `squeue -u [user ID]`

**Node Usage:**

For most jobs, you will use `standard`. Generally, you only request the higher memory nodes when your job requires this higher memory. 

Use nodes by specifying your desired partition in sbatch scripts
```
#SBATCH -p medmem
```
(`standard` is the default if not specified). The system will automatically designate a node withing the specified partition for your job.

---

## Loading software

Many common packages and software are already installed on SEDNA. For those that aren't (or if you need a specific version), you can put in a request to install or do it yourself for your own use. Pre-installed software are either in `modules` or `mamba`, which will be discussed below. 

### Modules

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

To see a list of already loaded modules you would type the following:
```
module list
```

Loading different versions of the same program might cause issues. If needed, unload the version you are not going to use first then load the correct one.
```
module unload <program>
```

`module purge` will unload all modules.

---

### Mamba

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
```
should give you:
```
# conda environments:
#
base                 	/opt/bioinformatics/mambaforge
busco-5.4.7          	/opt/bioinformatics/mambaforge/envs/busco-5.4.7
cd-hit-4.8.1         	/opt/bioinformatics/mambaforge/envs/cd-hit-4.8.1
cutadapt-4.4         	/opt/bioinformatics/mambaforge/envs/cutadapt-4.4
decona-0.1.2         	/opt/bioinformatics/mambaforge/envs/decona-0.1.2
...

```

Now...

To activate a conda/mamba environment type:
```
mamba activate <env>
```
and when a user is done using mamba they just need to type
```
mamba deactivate
```

**Note: SLURM does not read .bashrc or .bash_profile when launching a job via sbatch. If you want to use mamba with a sbatch job you need to add the following to your job script before you activate mamba (this is assuming you added the eval line to your .bashrc)**

Your script needs to have:
```
source ~/.bashrc
```

Ok, now you should be able to use module and environment with mamba, etc. 

---

### Installing other software

Different pipelines and programs will need diffferent dependencies. Some might be installed already, others you can install yourself, and others you will need to request intallation.

Install requests and general SEDNA help is available via the [SEDNA helpdesk google form](https://docs.google.com/forms/d/e/1FAIpQLSf2tDl9nJjihmHX9hM6ytMI3ToldqERVem1ge25-kp3JHw3tQ/viewform)


### **Example:** dependencies and the order of loading modules

Some software depends on other software and therefore the order of loading things matters. Generally, load a mamba environment before a module. However, there are exceptions to this, for example with `rainbow_bridge`, which is the opposite.

To activate `rainbow_bridge` you need to run two steps:

1. Load the rainbow_bridge module
```
module load bio/rainbow_bridge/202502
```
`rainbow_bridge` uses both `Singularity` and `Nexflow`. The above module already contains both simultaneously. If you try to load these two manually, the second load will replace the first one, and rainbow_bridge will fail because it will be missing one of these dependencies.

2. then activate the mamba environment with
```
mamba activate rainbow_bridge
```
This activates `rainbow_bridge` in your current session. 

---

## SEDNA Usage 

**Running processes using SBATCH Scripts (recommended)**
* It is recommended that you run programs/pipelines using a sbatch/bash/SLURM script.
	* This will help you keep track of your work and help with reproducibility
	* Your job will run safely in the background
 	* You can work on something else while your job is running
  	* The SLURM output can be saved in a log file for troubleshooting, etc 	  
	* See SLURM script examples at the end of this README

Script Components:
1. SLURM request block. This is where you specified the resources you want suchas memory, number of cores, and several other option
2. You do need to include the activation of modules, dependencies, software, etc in your script.
3. Your actual code, program execution, etc.
   
**Running processes straight in terminal**

You are absolutely able to activate modules, dependencies, software and run code straight in the terminal, but **always use srun for anything memory intensive!**. 

More generally, be aware of the advantages and disadvantages:

Some Pros:
* Is very quick! No need to write a script for small computations like listing files, counting files, counting lines in files, searching or modifying files, and many more.
* It is specially useful when you're troubleshooting specific code from a script. For instance, running step by step to find where an error if the offending code is not obvious from the output
* Likewise if you just want to run some code that doesn't take much time, etc.

Some Cons:
* Makes it harder to keep track of your work making reproducibility less efficient.
* Generally when running stratight in terminal, your output will be printed directly in the screen without being saved into a logfile.
* You won't be able to work on something else.
* Your job will be terminated if there are connectivity or other issues with the system.

That being said, there are many ways to avoid all the above cons like using [screens](https://jianjye.medium.com/how-to-use-linux-screen-commands-and-shortcuts-quick-guide-f1a2207d15d3), send jobs to the background, manually generate logs, etc. [see this as example](https://www.scaler.com/topics/how-to-run-process-in-background-linux/). Feel free to explore these options

***IMPORTANT*** Do not run med to heavy processes in the login node. Use a compute node via `srun`.


---

## Sequence Databases

There are a few sequence databases (NCBI and MIDORI2) that are available to all SEDNA users. 

&nbsp;

### NCBI nt Database

I have installed the lastest NCBI nucleotype database (Version 5) in SEDNA's shared directory:
```
/share/all/ncbi_database/2025-04-01_ncbi
```
where the date is the day I installed it.

Here some info:
```
blastdbcmd -db nt -info

Database: Nucleotide collection (nt)
        113,641,112 sequences; 2,853,029,940,118 total bases

Date: Mar 22, 2025  5:12 PM     Longest sequence: 99,994,136 bases

BLASTDB Version: 5
```

**NCBI taxids**

I have also placed the `new_taxdump.zip` file which contains the NCBI taxids in the same directory. This is used by rainbow_bridge and other analyses.
```
/share/all/ncbi_database/new_taxdump.zip
```

&nbsp;

### Midori2 Databases for metabarcoding analyses on SEDNA 

If you are going to be doing any metabarcoding analyses, you might be interested in using the [Midori2 Databse](https://www.reference-midori.info/)

&nbsp;

**Midori2 Databases SEDNA locations**
```
# parent dir
/share/all/midori2_database

# current sub-databases
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/
/share/all/midori2_database/2024-12-14_customblast_sp_uniq_12S/
/share/all/midori2_database/2024-12-14_customblast_sp_uniq_COI/
/share/all/midori2_database/2025-03-08_customblast_sp_uniq_16S/
/share/all/midori2_database/2025-03-08_customblast_sp_uniq_12S/
```
where the date is the release date or when the specific database was curated/uploaded/available.

*if you add addintional databases please add them to the list above*

NCBI GenBank databases are known to have various problems such as erroneous identification of organisms, potential lack of sequence curation, ets.
This is where Midori2 can help. 

[**Midori2**](https://www.reference-midori.info/) is a set of publicly accessable, already curated mitochondrial marker or amino acid databases 
(from NCBI GenBank) that gets updated every few months and are useful for metabarcoding analyses. In addition, these databases have also pre-formatted
 to fit many common metabarcoding pipelines, and raw sequences are also available if your desired format is not included.

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

&nbsp;

**SEDNA MIDORI2 SETUP** 

I went ahead and setup the Midori2 in SEDNA for rainbow_bridge.

I decided to start by setting up the COI species "sp", uniq  "uniq", which retains all haplotypes from all taxonomic labels. For instance, this will include
 all sequences that have been matched to only a genus or a family (see Key features above and Midori2 README)

When you use this, make sure to specify the full path and the basename but do not include the extensions (.ndb|.nhr|.nos etc). For example:
```
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/midori2_customblast_sp_uniq
```
 
***NOTES:***
* The Midori2 database gets updated every few months. Make sure you are using the latest version available and note which version you are using.
* If you want to learn how I made the custom database, update an existing or create a new database see my [midori2 page](https://github.com/ericgarciaresearch/noaa_sedna/blob/main/midori2.md)

* ***UPDATE: as in July 3rd, 2025, the latest release is `2025-03-08`***

---

## SEDNA SLURM script examples

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

## rainbow_bridge at SEDNA

This is an example of one of the pipelines that I have installed in SEDNA. Many other pipelines/modules/software are available.

[rainbow_bridge](https://github.com/mhoban/rainbow_bridge) is a flexible pipeline for eDNA and metabarcoding analyses. It can process raw or already filtered sequences
 from single- or paired-end datasets. This pipeline can be used to create zero-radius operational taxonomic units (zOTUs),
abundance tables, and assign taxonomy (via [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) and/or [insect](https://github.com/shaunpwilkinson/insect))
 along with dropping to the lowest common ancestor (LCA). The pipeline can also help with taxon filtering/remapping,
 decontamination, rarefaction, etc.

Key Features:

* eDAN - Metabarcoding analysese
* Can handle multiple types and states of data
        * Single- or paired-end
        * Raw or filtered
* flexible and open source.
        * Operated openly in commandline
        * Can easily adjust settings, parameters, filters, etc
        * GitHub Repository
        * Developers are very useful with suggestions and changes
* Multiple types of taxonomic classification
* Produces phyloseq object for downstream analyses

To learn how to use this pipeline in SEDNA go to [rainbow_bridge README for SEDNA](https://github.com/ericgarciaresearch/noaa_sedna/blob/main/rainbow_bridge_README.md) or to go the [rainbow_bridge SEDNA subdir](https://github.com/ericgarciaresearch/noaa_sedna/tree/main/rainbow_bridge)

---
