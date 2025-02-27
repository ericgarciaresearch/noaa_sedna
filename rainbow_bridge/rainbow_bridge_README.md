# rainbow_bridge README for SEDNA (NOAA's supercomputer)

This guide will help you use [rainbow_bridge](https://github.com/mhoban/rainbow_bridge) in SEDNA. 

Please take a few hours to get familiar witht the rainbow_bridge README (previous link), there is a lot of relevent information that is too long to explain the details in here.

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

### Project Organization and Management

Organization of projects is not a trivial thing. It can be the differnce between failure or increasingly efficient progress. A very popular tool to help organize and manage projects is [GitHub](https://github.com/). If you don't have a github account, I would you highly recommend [openning one ](https://github.com/signup)

**GitHub** is the web interface for ***Git***, which is a version control software that allow multiple people to share and work simultaneously in the same code/document. 

In GitHub you can then have repositories for each of your project. **You should strongly consider having a repo for each of your projects, including rainbow_bridge metabarcoding analyses**. Check with your organization,lab or PI, they might already have a github policy, in which case you can follow that. I personally keep copies of repos in my personal account when the original repo exist under an organization.

***Git*** is automatically available in SEDNA. No need to load it.

---

## rainbow_bridge in SEDNA

The [rainbow_bridge SEDNA Git Subdirectory](https://github.com/ericgarciaresearch/noaa_sedna/tree/main/rainbow_bridge) was created to facilitate researchers to use rainbow_bridge in SEDNA.

This subdir contains this README itself as well as several scripts and resources to this aim. You can explore this subdir and/or follow the guide below

---

**Guide for using rainbow_bridge in SEDNA**

Log into SEDNA. First we will do a test run and then we will run rainbow_bridge in real data using sbatch scripts. You can skip the test if you know rainbow_bridge is already working for you.

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

Additionally, you should now see 3 dirs that are the ouput of a rainbow run:
* work
	* Will hold the real files where symlinks point to if you chose symlink as output
  	* Yet, you can mostly ignore this dir since:
 		* Symlinks will appear in your output dir and,
  		* the rest are a bunch of intermediate files generated by singularity and nextflow
 * preprocess
	* contain all the initial and intermediate processing of your data.
 	* is probably a good idea to get familir with these files as you might have to go here when throubleshooting
  * output
  	* most important directory as it contains the most desired output: zOTU tables, blast results, abundance tables, etc.

*refer the the rainbow_bridge README for more information about the contents of each of these directories*
 
  	  

If you got these results, you are ready to try running rainbow_bridge in a script.

---

### Running `rainbow_bridge` using sbatch scripts

&nbsp;
&nbsp;

**Organization:**

This is the organization I am following at the momment. Feel free to follow this or modify.

From you home directory, create a subdir called "projects"
```
cd ~		# this always takes you home regardless of your current location
mkdir projects
 ```

Here, you can then place projects as a GitHub repositories (You can create repos straight from the command line or at GitHub and then clone it). Currently:
```
mkdir projects/MiFishU-test
```

In here, make the following subdirectories: data, scripts and analyses
```
mkdir projects/MiFishU-test/data		# this is where you'll place your datafiles
mkdir projects/MiFishU-test/scripts		# place your scripts here
mkdir projects/MiFishU-test/analyses		# create subdirectories here for each rainbow run (w/diff. parameters etc)
```

If you have not made a README, make one:
```
nano projects/MiFishU-test/README.md
```
where:
* **nano** is the text editor I like but you can use whatever other one (vim for example). Here is one [nano tutorial](https://www.geeksforgeeks.org/nano-text-editor-in-linux/) of many in the web
* "**md**" stands for markdown, which is the language you will be writing your READMEs on. Here is an online course in [md for GitHub](https://github.com/skills/communicate-using-markdown)

Document all your moves in your README. This is very important because:
* Documents that work you have done
* Allows other to replicate your work
* Allows your future self to understand what you did now
* Might be useful to copy the format from a repo that is fully or semi-complete so you get some structure or you can build upon that format

&nbsp;
&nbsp;

**Setting up your DATA**

Transfer your data files inside your data subdir:
```
mv or cp <files> projects/MiFishU-test/data
```

Take a momment to review your files:
* is your data demultiplexed?
* are the data single- or paired-end?
	* do you have same number of forward and reverse files?
 * Do you have all the files? whas the transfer successful
 * Check the sizes
 	* do you have consistent number of reads across samples? or a biased distribution?


&nbsp;

***Make a sample.map file***

See the rainbow_bridge README for all the different scenarios. In my case, I currently have demultiplexed paired-end files. To run `rainbow_bridge` in this dataset I will need to make a `sample.map` which is a simple text file with the 3 columns: the base name, name of the forward, and reverse files.

Thus, for file names such as:
```
JV183.1_MiFishU_WhitneyJonathan_S040845.1.R1.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040845.1.R2.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040846.1.R1.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040846.1.R2.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040853.1.R1.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040853.1.R2.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040854.1.R1.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040854.1.R2.fastq.gz
...
```

The sample file can be created with the following commands:
```
cd projects/MiFishU-test/data/					#navigate into your data dir
ls *gz | sed 's/\.R[12].fastq.gz//' | sort | uniq > basenames	#get the base names
ls *R1.fastq.gz > R1names					#get the forward names
ls *R2.fastq.gz > R2names					#get the reverse names
paste basenames R1names R2names > sample.map			#puts all of them together
```

Inspect your `sample.map` files and make sure it looks ok. Mine looks like this:
```
JV183.1_MiFishU_WhitneyJonathan_S040845.1       JV183.1_MiFishU_WhitneyJonathan_S040845.1.R1.fastq.gz   JV183.1_MiFishU_WhitneyJonathan_S040845.1.R2.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040846.1       JV183.1_MiFishU_WhitneyJonathan_S040846.1.R1.fastq.gz   JV183.1_MiFishU_WhitneyJonathan_S040846.1.R2.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040853.1       JV183.1_MiFishU_WhitneyJonathan_S040853.1.R1.fastq.gz   JV183.1_MiFishU_WhitneyJonathan_S040853.1.R2.fastq.gz
JV183.1_MiFishU_WhitneyJonathan_S040854.1       JV183.1_MiFishU_WhitneyJonathan_S040854.1.R1.fastq.gz   JV183.1_MiFishU_WhitneyJonathan_S040854.1.R2.fastq.gz
...
```

Once you're satisfied, delete the intermediate files
```
rm basenames R1names R2names
```

&nbsp;

***Making a Barcode file***

The main purpose of the barcode file is to list the barcode that identify each sample as well as the primers used in the sequencing. *rainbow_bridge* uses this file to demultiplex and strip primers as needed. Additional information can also be place in this file.

*A barcode file is necessary except for demultiplexed runs where the PCR primers have already been removed*

See orinigal [rainbow README](https://github.com/mhoban/rainbow_bridge) for details but briefly, here are the examples given:

* **Non-demultiplexed runs:** This format includes forward/reverse sample barcodes and forward/reverse PCR primers to separate sequences into the appropriate samples and remove primer sequences. Barcodes are separated with a colon and combined in a single column while primers are given in separate columns. For example:

unmuxed_barcode.tsv

| #assay | sample | barcodes | forward_primer | reverse_primer | extra_information |
|---|---|---|---|---|---|
|16S-Fish | B001 | GTGTGACA:AGCTTGAC | CGCTGTTATCCCTADRGTAACT | GACCCTATGGAGCTTTAGAC | EFMSRun103_Elib90
|16S-Fish | B002 | GTGTGACA:GACAACAC | CGCTGTTATCCCTADRGTAACT | GACCCTATGGAGCTTTAGAC | EFMSRun103_Elib90

* **Demultiplexed runs:** Since sequences have already been separated into samples, this format omits the barcodes (using just a colon ':' in their place) but includes the primers. For example:

demuxed_barcode.tsv

| #assay | sample | barcodes | forward_primer | reverse_primer | extra_information |
|---|---|---|---|---|---|
|primer | V9_18S | : | GTACACACCGCCCGTC | TGATCCTTCTGCAGGTTCACCTAC | | 


* Place your barcode file in your data subdirectory along with your sample.map and data files


***[PIFSC_Metabarcoding_Primers]()**

We have listed the current list of primers used in PIFSC in the file [PIFSC_Metabarcoding_Primers]() which lives inside
```
/home/egarcia/data
```

This files looks like this:

| Primer Set | JonahVentures_name | Primer Name | Reference | Primer_seq_FWD | Primer_seq_REV | Target Taxa | Amplicon size | | Confirmation_notes |
|---|---|---|---|---|---|---|---|---|
| COI | UniCOI | mlCOIintF; jgHCO2198 | Leray et al. 2013 | GGWACWGGWTGAACWGTWTAYCCYCC | TAIACYTCIGGRTGICCRAARAAYCA | Metazoans | 304-313 | confimed in JVB1836-UniCOI-testmethods.txt |



|Primer Set | JonahVentures_name | Primer Name | Reference | Primer_seq_FWD | Primer_seq_REV | Target Taxa | Amplicon size | | Confirmation_notes |
|---|---|---|---|---|---|---|---|---|
|COI | UniCOI | mlCOIintF; jgHCO2198 | Leray et al. 2013 | GGWACWGGWTGAACWGTWTAYCCYCC | TAIACYTCIGGRTGICCRAARAAYCA | Metazoans | 304-313 | confimed in JVB1836-UniCOI-testmethods.txt, which has a different reverse than what we originally requested
|16S-Fish | 16SDegenerate | 16SF/D; 16S2R-degenerate | Deagle et al. 2007; Berry et al. 2017 | GACCCTATGGAGCTTTAGAC | CGCTGTTATCCCTADRGTAACT | Fish | 178-228 | confirmed in JVB1836-16SDegenerate-testmethods.txt
|12S-MiFish | MiFishU | MiFish-U-F; MiFish-U-R | Miya et al. 2015 | GTCGGTAAAACTCGTGCCAGC | CATAGTGGGGTATCTAATCCCAGTTTG | Fish | 163-185 | confirmed in JVB1836-MiFishU-testmethods.txt
|18S V1-3 | 18S_400 | 18S_1F; 18S_400R | Pochon et al. 2013 | GCCAGTAGTCATATGCTTGTCT | GCCTGCTGCCTTCCTT | Eukaryotes | 336-423 | confirmed in JVB1836-18S_400-testmethods.txt

For PIFSC projects, use the above info to make your ***barcode.tsv*** file. 

Example:

To populate a barcode file for the MiFishU project :

1. ***#assay*** = 12S
2. ***sample*** = I will copy the base name of files from my previous *sample.map* file
3. ***barcodes*** = it will simply be ":" since these files are demultiplexed already
4. ***forward_primer***= GTCGGTAAAACTCGTGCCAGC
5. ***reverse_primer***= CATAGTGGGGTATCTAATCCCAGTTTG
6. ***extra_info***= MiFishU 163-185bp. Confirmed in JVB1836-MiFishU-testmethods.txt (this column is arbitrary)

Thus, this file can be created with:
```
cd /home/egarcia/projects/MiFishU-test/data		#navigate to my project's data subdir 
cut -f1 sample.map > sample	# get your sample basenames
wc -l sample			# count your samples for the next commands. In my case, I have 52 samples
yes 12S | head -n52 > assay	# prints 12S 52 times
yes : | head -n52 > barcodes	# prints : 52 times
yes GTCGGTAAAACTCGTGCCAGC | head -n52 > fp		# prints the fprimer 52 time
yes CATAGTGGGGTATCTAATCCCAGTTTG | head -n52 > rp	# prints the rprimer 52 time
yes MiFishU 163-185bp. Confirmed in JVB1836-MiFishU-testmethods.txt | head -n52		# prints extra info 52 times
paste assay sample barcodes fp rp xinfo > body		# creates the body of the file
echo -e "#assay\tsample\tbarcodes\tforward_primer\treverse_primer\textra_information" > header		# creates the header
cat header body > demuxed_barcodes.tsv	# puts the last two together
rm assay sample barcodes fp rp xinfo body header	# clean up
```

My file then looks like:

|#assay | sample | barcodes | forward_primer | reverse_primer | extra_information
|---|---|---|---|---|---|
|12S | JV183.1_MiFishU_WhitneyJonathan_S040845.1 |   : |   GTCGGTAAAACTCGTGCCAGC | CATAGTGGGGTATCTAATCCCAGTTTG | MiFishU 163-185bp. Confirmed in JVB1836-MiFishU-testmethods.txt
|12S | JV183.1_MiFishU_WhitneyJonathan_S040846.1 |   : |   GTCGGTAAAACTCGTGCCAGC | CATAGTGGGGTATCTAATCCCAGTTTG | MiFishU 163-185bp. Confirmed in JVB1836-MiFishU-testmethods.txt
|12S | JV183.1_MiFishU_WhitneyJonathan_S040853.1 |   : |   GTCGGTAAAACTCGTGCCAGC | CATAGTGGGGTATCTAATCCCAGTTTG | MiFishU 163-185bp. Confirmed in JVB1836-MiFishU-testmethods.txt

&nbsp;

***Making a Parameter yml file***

When running rainbow with a sbatch script, you can either include the complete command in the script using flags such as 
```
--paired --reads ../data/ --barcode '../data/*.tsv'
```

Or you can make a yml parameter file where you specified all the setting used by each run. For example:
```
nano data/pared_demuxed.yml
```
```
paired: true
demultiplexed-by: index
reads: ../data/
sample-map: ../data/sample.map
barcode: ../data/demuxed_barcode.tsv
fastqc: true
...
```
There are several parameters sets available. See rainbow README for all of these.

