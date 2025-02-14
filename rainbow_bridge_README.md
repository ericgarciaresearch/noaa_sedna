# rainbow_bridge README for SEDNA (NOAA's supercomputer)

This guide will help you use [rainbow_bridge](https://github.com/mhoban/rainbow_bridge) in SEDNA.

`rainbow_bridge` is a flexible pipeline for eDNA and metabarcoding analyses. It can process raw or already filtered sequences
 from single- or paired-end datasets. This pipeline can be used to create zero-radius operational taxonomic units (zOTUs),
abundance tables, and assign taxonomy (via [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) and/or [insect](https://github.com/shaunpwilkinson/insect))
 along with dropping to the lowest common ancestor (LCA). The pipeline can also help with taxon filtering/remapping,
 decontamination, rarefaction, etc.

Key Features:

* eDAN - Metabarcoding analyses
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

Note that `rainbow_bridge` is a fork of [eDNAFlow](https://github.com/mahsa-mousavi/eDNAFlow) with added flexibility, capability,
 and compatibility. Refer to the original documentation and description of eDNAFlow as needed.

---

### Need SEDNA help?

if you are new to SEDNA, have not configured modules and mamba in your SEDNA .bashrc, or still need more info about working on SEDNA, etc., please start by reading the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0) and/or the 
[Working on SEDNA README](https://github.com/ericgarciaresearch/noaa_sedna)

---

## Using rainbow_bridge in SEDNA

Log into SEDNA. First we will do a test run and then we will run rainbow_bridge in real data using sbatch scripts

There are two ways that you are able to run `rainbow_bridge`:

1. Locally, by downloading the main [rainbow_bridge GitHub repo](https://github.com/mhoban/rainbow_bridge):
```
git clone https://github.com/mhoban/rainbow_bridge
```
then using the *rainbow_bridge.nf* in this repo (like the test run below).

or

2. Remotely, by executing `rainbow_bridge` directly from the main Git repo, i.e., using the internet.
* see below

**Note: I would recommend running remotely given that if there are recent updates to the pipeline, which do happen, your local copy of the code might not have these updates which will likely break something down the road**

That being said, I have used the local execution when I had issues running it remotely but I needed to run the data. Yet, this did force me to doublecheck for any potential errors.

---

### TEST-RUN: Checking if rainbow_bridge is working fine and local execution

*You probably only need to do this test the very first time you're trying to use `rainbow_bridge`*

We can easily do this test using the [rainbow_bridge test data](https://github.com/mhoban/rainbow_bridge-test).

The first thing is to see what interactive medmem node is idle (avoid doing any work in the login node):
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
So I see node36 is available. Snatched it!
```
ssh node36
```

Now, download the rainbow_bridge test repo
```
cd <where you want to test this>
git clone https://github.com/mhoban/rainbow_bridge-test.git
```

You should see the dir called `rainbow_bridge-test`. Navigate inside:
```
cd rainbow_bridge-test
```

&nbsp;
&nbsp;

**Activating `rainbow_bridge`**
```
module load bio/rainbow_bridge/202502
```
(or you can just run module load `bio/rainbow_bridge` but it will default to the newest version if there are multiple versions)(if you haven't enable modules go back to the SEDNA REDME)

Unlike with the manually activation of `Nextflow` and `Singularity`, this module already contains  both simultaneously. For instance, if you try to load the last two manually, the second load will replace the first one, and rainbow_bridge will fail because it will be missing one of these dependencies.

Note: At the moment we are using a single node (all 20 cores + all 192 GB of memory) till we can get NextFlow to interface with the scheduler **(Use a medmen node: node29-36)**

Now activate the mamba environment with:
```
mamba activate rainbow_bridge
```
This activates `rainbow_bridge` in your current session. 

If you are running rainbow_bridge in a sbatch script, then **make sure to include the following in your script before any mamba commands:**
```
source ~/.bashrc
```
The above is needed because SEDNA does not automatically sources your bash configuration in scripts.


&nbsp;
&nbsp;

**Running `rainbow_bridge`**
```
rainbow_bridge.nf -params-file single_demuxed.yml --blast-db ./blastdb/single_demuxed
```
You should see something like:
```

 N E X T F L O W   ~  version 24.10.4

Launching `/opt/bioinformatics/bio/rainbow_bridge/rainbow_bridge-202502/rainbow_bridge.nf` [agitated_brahmagupta] DSL2 - revision: c0748103b3

... (many intermediate lines) ...

executor >  local (83)
[-        ] unzip             -
[fd/f15c52] fix_barcodes (1)  | 1 of 1 ✔
[47/d6d59e] filter_merge (12) | 19 of 19 ✔
[84/21d878] ngsfilter (3)     | 19 of 19 ✔
[f9/edcaf7] filter_length (8) | 19 of 19 ✔
[36/123db9] relabel (12)      | 19 of 19 ✔
[dc/1e09f9] merge_relabeled   | 1 of 1 ✔
[5a/626747] dereplicate (1)   | 1 of 1 ✔
[ac/7b3c99] get_taxdb (1)     | 1 of 1 ✔
[75/cce3c0] extract_taxdb (2) | 2 of 2 ✔
[60/8b7491] blast (1)         | 1 of 1 ✔
Pulling Singularity image docker://biocontainers/vsearch:v2.10.4-1-deb_cv1 [cache /home/egarcia/pipelines/rainbow_bridge-test/work/singularity/biocontainers-vsearch-v2.10.4-1-deb_cv1.img]
Pulling Singularity image docker://ncbi/blast:latest [cache /home/egarcia/pipelines/rainbow_bridge-test/work/singularity/ncbi-blast-latest.img]
Completed at: 13-Feb-2025 18:57:00
Duration    : 1m 4s
CPU hours   : 0.1
Succeeded   : 83
```

This prints every step and writes a "✔" when that step was successfull for all the data files.

If you got these results, you are ready to try running rainbow_bridge in a script.

---

### Running `rainbow_bridge` using sbatch scripts




 
    	 



