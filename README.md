# Working on SEDNA

This README documents general information and provides a loose guide to help you work on NOAA’s supercomputer **SEDNA**

Please read the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0)

Many of the steps and info in this README were summarised from the above document.

---

## SEDNA info

**SEDNA General Specs:**

* Head (login) node
* NFS storage
* Fast scratch storage (43 Tb and 91 Tb on two different RAID0 arrays)
* Shared storage

**Nodes and Partitions:**

36 standard compute nodes across

* **SLURM PARTITION: standard**
	* node01-28:  96 GB of memory, 12x 8GB
 	* 20 cores/node
	* Default partition; 8hr default time for jobs
* **SLURM PARTITION: medmem** 
	* node29-36: 192 GB of memory, 12x 16GB
 		* SLURM only allows setting --mem to 185G 
 	* 20 cores/node 

4 high memory nodes

* **SLURM PARTITION: himem**
	* himeme01-04: 1.5 TB of memory, 24x 64GB
 	* 24 cores/node	
	* have their own scratch (/data) space

Is possible to run jobs in multiple partitions with”
```
#SBATCH -p standard, medme
```

---

## SEDNA SETUP

**SEDNA Account**

First of all, you need to get an account setup. Talk to your supervisor for this. 

You will need to create an new password:
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

It is ok to do some light processes like navigation, listing, file organization, etc. However, you should NOT do any mid to heavy computations in the login node. You should instead either run a scricp, which will automatically grab and specified computing node, or you can login manually to a computing node (i.e. sdandard, medmem or himem nodes).

The first thing is to see what interactive/computing nodes are available (idle):

```
sinfo
```
at the momment I tried this, I got:
```
sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST 
standard*    up   infinite     17    mix node[10-22,24,26-28] 
standard*    up   infinite      9  alloc node[01-09] 
standard*    up   infinite      2   idle node[23,25] 
himem        up   infinite      4    mix himem[01-04] 
medmem       up   infinite      5    mix node[29-30,32-34] 
medmem       up   infinite      2  alloc node[31,35] 
medmem       up   infinite      1   idle node36 
```
There are a few standdard and medmem nodes idle. Thus, if I pretend I want to run rainbow_bridge which is not a light process I would need a medmem or himem node. I see node36 is available so I snatched it!
```
ssh node36
```

Now my prompt looks like:
```
(base) [egarcia@node36 currentDIR]$
```

You can go back to the login node as needed with
```
exit
```
and another `exit` will kick out of SEDNA completely.

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

## Dependencies activation and other installation

Different pipelines and programs will need diffferent dependencies. Some might be installed already, others you can install yourself, and others you will need to request intallation.

Install requests and general help is available via the [SEDNA helpdesk google form](https://docs.google.com/forms/d/e/1FAIpQLSf2tDl9nJjihmHX9hM6ytMI3ToldqERVem1ge25-kp3JHw3tQ/viewform)


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

**Example:**

### rainbow_bridge dependency installation

To activate the various dependencies and rainbow_bridge you need to run two steps:

1. Load the rainbow_bridge module
```
module load bio/rainbow_bridge/202502
```
Unlike with the manually activation of `Nextflow` and `Singularity`, this module already contains  both simultaneously. For instance, if you try to load the last two manually, the second load will replace the first one, and rainbow_bridge will fail because it will be missing one of these dependencies.

2. then activate the mamba environment with
```
mamba activate rainbow_bridge
```
This activates `rainbow_bridge` in your current session. 

---

## SEDNA Usage 

* It is recommended that you run programs/pipelines using a SLURM script.
	* This will help you keep track of your work and help with reproducibility
	* See SLURM script examples at the end of this README

* If you are going to be throubleshooting, doing analyses, using singularity or nextflow straight from the terminal, etc., you need to log into a computing node (i.e. do not do work/analyses in the login node).

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

* If you are going to execute bash script (recommended), you don’t need to grab a node, the SLURM will automatically place your job in the specified node(s). Just include the activation of singularity and nextflow in your script.
* You can activate straight in terminal singularity or nextflow as shown above. However, these two are not available simultaneously which is what `rainbow_bridge` needs
* You will  need a SLURM script to run `rainbow_bridge`

---

### [Midori2 Databases](https://www.reference-midori.info/) for metabarcoding analyses on SEDNA 

If you are going to be doing any metabarcoding analyses, you might be interested in using the [Midori2 Databse](https://www.reference-midori.info/)

## Midori2 Databases SEDNA locations
```
# parent dir
/share/all/midori2_database

# sub-databases
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/
```
*if you add addintional databases please add them to the list above*

### Setting up the [MIDORI2 database](https://www.reference-midori.info/)

NCBI GenBank databases are known to have various problems such as erroneous identification of organisms, potential lack of sequence curation, ets.
This is where Midori2 can help. 

[**Midori2**](https://www.reference-midori.info/) is a set of publicly accessable, already curated mitochondrial marker or amino acid databases 
(from NCBI GenBank) that get updated every few months and are useful for metabarcoding analyses. In addition, these databases have also pre-formatted
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

**SEDNA SETUP** 

I went ahead and setup the [Midori2 database](https://www.reference-midori.info/) in SEDNA for rainbow_bridge.

I decided to start by setting up the COI species "sp", uniq  "uniq", which retains all haplotypes from all taxonomic labels. For instance, this will include
 all sequences that have been matched to only a genus or a family (see Key features above and Midori2 README)

	* Lastest version as in Feb 6, 2025 `2024-10-13`
	* When you use this, make sure to specify the full path and the basename but do not include the extensions (.ndb|.nhr|.nos etc). For example:
```
/share/all/midori2_database/2024-10-13_customblast_sp_uniq_COI/midori2_customblast_sp_uniq
```

***NOTES:***
* The Midori2 database gets updated every 2 months. Make sure you are using the latest version available and note which version you are using.
* If you want to learn how I made the custom database, update an existing or create a new database see my [midori2 page](https://github.com/ericgarciaresearch/noaa_sedna/blob/main/midori2.md)

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

## rainbow_bridge at SEDNA

This is an example of one of the pipelines that Eric has installed in SEDNA. Many other pipelines/modules/software are available.

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

To learn how to use this pipeline in SEDAN go to [rainbow_bridge README for SEDNA](https://github.com/ericgarciaresearch/noaa_sedna/blob/main/rainbow_bridge_README.md) or to go the [rainbow_bridge SEDNA subdir](https://github.com/ericgarciaresearch/noaa_sedna/tree/main/rainbow_bridge)

---
