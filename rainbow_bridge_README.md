# rainbow_bridge for SEDNA (NOAA's supercomputer)

This guide will help you use [rainbow_bridge](https://github.com/mhoban/rainbow_bridge) in SEDNA. 

The pipeline was been cloned in the share directory:
```
/share/all/rainbow_bridge_unzipfix
```
*Note (May, 2025): currently running a modified script in "rainbow_bridge_unzipfix" as there was a problem with singularity container that was updated and did not contain unzip. The online version has yet been updated*

Additionally,  in-house scripts for pre-processing, running rainbow and post-processing have also available in:
```
/share/all/rainbow_bridge_in-house-scripts
```

Please take a few hours to get familiar with the rainbow_bridge README (previous link), there is a lot of relevent information that is too long to explain here.

---

## Before Starting Read This

<details><summary>rainbow_bridge General Info</summary>
<p>

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

</p>
</details>

<details><summary>Need Help with SEDNA?</summary>
<p>

if you are new to SEDNA, have not configured modules and mamba in your SEDNA .bashrc, or still need more info about working on SEDNA, etc., please start by reading the [SEDNA information and best practices](https://docs.google.com/document/d/1nn0T0OWEsQCBoCdaH6DSY69lQSbK3XnPlseyyQuU2Lc/edit?tab=t.0) and/or the 
[Working on SEDNA README](https://github.com/ericgarciaresearch/noaa_sedna)

---

</p>
</details>


<details><summary>Project Organization and Management (Git)</summary>
<p>
	
Organization of projects is not a trivial thing. It can be the difference between failure or increasingly efficient progress. A very popular tool to help organize and manage projects is [GitHub](https://github.com/). If you don't have a github account, I would you highly recommend [openning one ](https://github.com/signup)

**GitHub** is the web interface for ***Git***, which is a version control software that allow multiple people to share and work simultaneously in the same code/document/projects. 

In GitHub you can then have repositories for each of your projects. **You should strongly consider having a repo for each of your projects, including rainbow_bridge metabarcoding analyses**. This will aloow you to save and share your work everything you do any analyses. Check with your organization,lab or PI, they might already have a github policy, in which case you can follow that. I personally keep copies of repos in my personal account when the original repo exist under an organization.

***Git*** is automatically available in SEDNA. No need to load it.

---

</p>
</details>

<details><summary>rainbow_bridge Running Modes</summary>
<p>

There are two ways that you are able to run `rainbow_bridge`:

**1. Locally**

You can run rainbow locally by using the copy already downloaded in the share dir which already has the necesary adjustments to make it functional:
```
/share/all/rainbow_bridge_unzipfix
```
To use this, you would copy the following script in your project's dir
```
/share/all/rainbow_bridge_in-house-scripts/run_rainbow_bridge_locally_sedna.sh
```
*This script is already setup to run the version that is currently working*

You can also download the main [rainbow_bridge GitHub repo](https://github.com/mhoban/rainbow_bridge) again but as in May 7th 20205, this won't work as needed adjustment have not been implemented online:
```
# if you need to download again
git clone https://github.com/mhoban/rainbow_bridge
```
then using the *rainbow_bridge.nf* script with an `srun` or a sbatch script (like the test run below).


**2. Remotely**

You also execute `rainbow_bridge` directly from the main Git repo, i.e., using the in-house script for running rainbow:
```
/share/all/rainbow_bridge_in-house-scripts/run_rainbow_bridge_remotely_sedna.sh
```

**Note: I would normally recommend running remotely given that if there are recent updates to the pipeline, which do happen, your local copy of the code might not have these updates which will likely break something down the road. HOWEVER, as in May 2025, some needed adjustments have not been implemented online so the only version currently working is running /share/all/rainbow_bridge_unzipfix locally**

Use local execution when there are issues running it remotely but ultimately you should be able to run remotely.

---

</p>
</details>

<details><summary>TEST-RUN: Checking if rainbow_bridge is working fine</summary>
<p>

**Note (May 2025): I had done the test already and rainbow is currently working correctly (using the rainbow_bridge_unzipfix version). Feel free to skip the test. Yet if rainbow is not working for you, this is a good test to see if your set up or rainbow itself is causing the issue(s)**

*You only need to do this test the very first time you're trying to use `rainbow_bridge` or if you suspect the pipeline is not working at all*

We can easily do this test using the [rainbow_bridge test data](https://github.com/mhoban/rainbow_bridge-test).

We'll do the test using `srun` so we avoid doing any medium or heavy work in the login node:

First, download the rainbow_bridge test repo
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
srun rainbow_bridge.nf -params-file single_demuxed.yml --blast-db ./blastdb/single_demuxed
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

</p>
</details>

---

## Running `rainbow_bridge` 


We will be running rainbow using sbatch scripts. In this case, it is not necessary to use `srun` as a node will be automatically deployed by the script. Furthermore, rainbow can still be executed locally (see above) or remotely using a batch script. We will be runnig /share/all/rainbow_bridge_unzipfix locally as this is the version that is currently working in SEDNA (May 2025), but eventually we will be running remotely to ensure we are using the lastest version of the pipeline.

<details><summary>Organization and Directories</summary>
<p>

### Organization
This is the organization I am following at the momment. Feel free to follow this or modify.

From you home directory, create a subdir called "projects"
```
cd ~		# this always takes you home regardless of your current location
mkdir projects
 ```

We give every project a separate GitHub repository that can be treated a stand alone product. For example, for multi-marker projects, we are setting up a separate repo for each marker and then an additional repo for the multi-marker analyses that will combine them.

### Initiate Git Repo

Now create a git repo for your specific project. One way to do this is:

1. Go to your persoal or organization's Git. Click "Repositories", and click in the green "New" bottom
2. Give a descriptive name without making it too long (example:"pifsc_p224_16S_fish"), click "Add a README file", then "Create repository"
* This will take you to the webpage of your new repo.
3. Now, click in the green "Code" bottom and copy the displayed HTTPS link
4. In SEDNA, navigate to your projects dir and `git clone <your new repo's HTTPS link>`
```
cd /home/egarcia/projects/
git clone https://github.com/ericgarciaresearch/pifsc_p224_16S_fish.git
```
* This will make a copy in SEDNA where you can start working

**Copy the gitignore specific for rainbow_bridge.**

This hidden file tell git what large files to ignore so you don't have issues pushing to git
```
cp /share/all/rainbow_bridge_in-house-scripts/.gitignore pifsc_p224_16S_fish
```

Next, cd into your cloned repo and make the following subdirectories: data, scripts and analyses
```
cd /home/egarcia/projects/pifsc_p224_16S_fish
mkdir data		# this is where you'll place your datafiles
mkdir scripts		# place your scripts here
mkdir analyses		# create subdirectories here for each rainbow run (w/diff. parameters etc)
```

If you did not make a README, make one now:
```
nano projects/pifsc_p224_16S_fish/README.md
```
where:
* **nano** is the text editor I like but you can use whatever other one (vim for example). Here is one [nano tutorial](https://www.geeksforgeeks.org/nano-text-editor-in-linux/) of many in the web
* "**md**" stands for markdown, which is the language you will be writing your READMEs on. Here is an online course in [md for GitHub](https://github.com/skills/communicate-using-markdown)

You can use **nano** to modify files as needed.

Document all your moves in your README. This is very important because:
* Documents the work you have done
* Allows other to replicate your work
* Allows your future self to understand what you did now


***You have created a new README but it might be useful to copy a README from another project is has been semi- or complete so you get some structure or you can build upon that format***

---

</p>
</details>

<details><summary>Get your Data</summary>
<p>


Transfer your data files inside your data subdir:
```
mv or cp <files> projects/pifsc_p224_16S_fish/data
```
---

</p>
</details>

<details><summary>Rename Files</summary>
<p>

Renaming files to something manageable

Script

* rename_fastqs.sh < --dry-run | --rename >

All the PIFSC eDNA data I have seen comes from the same sequencing facility [Jonah Ventures](https://jonahventures.com/), 
which has a common naming scheme for data files that looks like:
```
JV190_16SDegenerate_WhitneyJonathan_S045173.1.R1.fastq.gz
```
Where the `S045173` is the actual sample name, the `.1` after that represent a duplicate of the same file, the `R1` represent foward reads, and the rest is repeated information. 

Thus, I created the script `rename_fastqs.sh` to truncate files to just the sample name by recognizing files matching the regex 
`*_S0*.fastq.gz` and using `sed` to modify the name to something like `S045173_1.R1.fastq.gz`. That is, it  keeps only the sample name and changes the "." to a "_" before the duplicate information because the extra point can cause issues later on.

* Importantly, this script can give you a preview of the resulting names (`--dry-run`) before actually renamning files (`--rename`).

If your data files look similar to the described above, try the dry run below. Otherwise, to use this script you will need to:
* find a regex that recognizes all the files to rename and use that to replace `*_S0*.fastq.gz` in Line 9
* and find a sed command that makes the necessary changes and use that to replace `sed -e 's/.*_S0/S0/' -e 's/\./_/'` in Line 10
* Alternatively, change the files names manually, using a loop or another script


Renaming my files now. Lets do a dry run first
```
cd /home/egarcia/projects/pifsc_p224_16S_fish/data
srun /share/all/scripts/egarcia/rename_fastqs.sh --dry-run
```
The printed output looks like this:
```
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045173.1.R1.fastq.gz  ->  S045173_1.R1.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045173.1.R2.fastq.gz  ->  S045173_1.R2.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045223.1.R1.fastq.gz  ->  S045223_1.R1.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045223.1.R2.fastq.gz  ->  S045223_1.R2.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045236.1.R1.fastq.gz  ->  S045236_1.R1.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045236.1.R2.fastq.gz  ->  S045236_1.R2.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045294.1.R1.fastq.gz  ->  S045294_1.R1.fastq.gz
[DRY RUN] JV190_16SDegenerate_WhitneyJonathan_S045294.1.R2.fastq.gz  ->  S045294_1.R2.fastq.gz
```
That looks good!

Ok, going for it:
```
srun /share/all/scripts/egarcia/rename_fastqs.sh --rename
```
This worked as expected, moving on.

---

</p>
</details>

<details><summary>Check your Sequence Files</summary>
<p>

Take a momment to review your files:
* is your data demultiplexed?
* are the data single- or paired-end?
	* do you have same number of forward and reverse files?
 * Do you have all the files? whas the transfer successful
 * Check the sizes
 	* do you have consistent number of reads across samples? or a biased distribution?

For convinience, I have created the script `check_fastq_awk.sh` which checks the:

A) FASTQ format
* Checks that line 1 of each record starts with @
* Checks that line 3 starts with +
* Verifies that the sequence (line 2) and quality (line 4) have equal length.
* Confirms the total number of lines is a multiple of 4 and that the file is not empty

B) GZ format
* Checks that compression (gz) is correct. Problems with this could indicate faulty file downloads or transfers

C) Paired-End (PE) format
* Checks that every sample has the set forward and reverse files, and these have the same number of reads.

D) Creates Read summaries
* Report with read numbers per file
* Summary with read numbers
* Summary with read lengths.

This scripts lives at
```
/share/all/scripts/egarcia/check_fastq_awk.sh
```

to execute with
```
srun bash /share/all/scripts/egarcia/check_fastq_awk.sh "<path_to_seq_files>"
```

You will see a summary of the results printed straight in the standard output, stdout, that looks like this (example using 4 files):
```
🧪 FASTQ Validation Summary
----------------------------
✅ Passed: 4
❌ Failed: 0
📊 Total:  4
🎉 All files passed FASTQ validation.

🧪 GZIP Compression Check
----------------------------
✅ GZIP OK: 4
❌ GZIP Fail: 0
📦 Total Checked: 4
🎉 All files are valid GZIP compressed files.

🧪 Paired-End FASTQ Validation (awk-only)
------------------------------------------

✅ Pairs OK: 2
❌ Pairs Fail: 0
🔢 Total Pairs Checked: 2
🎉 All paired FASTQ files look properly matched and formatted.

🧪 Generating raw read counts (file, read_count)
-----------------------------------------------
📄 Read counts written to: fq_format_check_logs/raw_read_count.tsv

📄 Read length summary written to: fq_format_check_logs/raw_read_length_summary.tsv
```

All the output of the check script is saved into the subdir `fq_format_check_logs`, including lists of "good" and "bad" files, logs of file properties, a read count of both paired-end files in `paired_end_check.log`, and a summary of the counts as well as read lenghts.

In addition, if any file is found to have issues in the format, the script will generated a detailed log for that file as well.

Check all the output for read flags.

Note: this script should work with *[R1|r1].[fastq|fq].gz and *[R2|r2].[fastq|fq].gz file extensions. Other extensions will need modification. Should you need to modify it, make a copy in your home dir and modify as needed.

---

**Potentially Fixing Format Issuess**

I have also generated the script `fix_bad_fastq.sh` which attempts to fix faulty files by:
1. Removing empty lines
2. Removing partial/incomplete records
3. Truncating excess lines so the total is divisible by 4
4. Ensuring @ and + headers exist where expected

***Yet, I have not have the chance to test the script to use with caution.***

```
/share/all/scripts/egarcia/fix_bad_fastq.sh
```

---

</p>
</details>

<details><summary>Create Supporting Files (barcode, sample_map, and params.yml files)</summary>
<p>

See the [rainbow documentation](https://github.com/mhoban/rainbow_bridge) for details

&nbsp;
&nbsp;

***Making a Barcode file***

The barcode file is used by rainbow to strip barcodes and primer sequences form reads.

*A barcode file is always necessary except for demultiplexed runs where both barcodes and PCR primers have already been removed*

Non- and demultiplexed brief examples:

* Non-demultiplexed runs: This format includes forward/reverse sample barcodes and forward/reverse PCR primers to separate sequences into the appropriate samples. Barcodes are separated with a colon and combined in a single column while primers are given in separate columns. For example:

unmuxed_barcode.tsv

| #assay | sample | barcodes | forward_primer | reverse_primer | extra_information |
|---|---|---|---|---|---|
|16S-Fish | B001 | GTGTGACA:AGCTTGAC | CGCTGTTATCCCTADRGTAACT | GACCCTATGGAGCTTTAGAC | EFMSRun103_Elib90
|16S-Fish | B002 | GTGTGACA:GACAACAC | CGCTGTTATCCCTADRGTAACT | GACCCTATGGAGCTTTAGAC | EFMSRun103_Elib90

* Demultiplexed runs: Since sequences have already been separated into samples, this format omits the barcodes (using just a colon, ':' in their place) but includes the primers. For example:

demuxed_barcode.tsv

| #assay |  sample |  barcodes | forward_primer |  reverse_primer | extra_information |
| --- | --- | --- | --- | --- | --- |
| 16S_fish | S040713_1 | : | GACCCTATGGAGCTTTAGAC | CGCTGTTATCCCTADRGTAACT |  confirmed in JVB1836-16SDegenerate-testmethods.txt|


&nbsp;
&nbsp;

### PIFSC Primers

To make this file I need the forward and reverse sequences of the primer that was used. For PIFSC data, we stored this information in the file:
```
/home/egarcia/data/PIFSC_Metabarcoding_Primers.tsv
```

In this case, I am calling my barcode file `demuxed_barcodes.tsv` because my samples are already demultiplexed. This file then looks like this:

| #assay |  sample |  barcodes | forward_primer |  reverse_primer | extra_information |
| --- | --- | --- | --- | --- | --- |
| 16S_fish | S040713_1 | : | GACCCTATGGAGCTTTAGAC | CGCTGTTATCCCTADRGTAACT |  confirmed in JVB1836-16SDegenerate-testmethods.txt|

Where the header line has to start with #, "S040713_1" is the name of a random sample, and ":" is the 
character that must separate the barcodes use to idenfity samples. Since my samples are already 
demultiplex I need only ":". If you don't have demultiplexed samples, your barcode file needs 
one line per sample with unique combinations of barcodes. See rainbow documentation for more details.

You can copy the block below and just change the content for future runs/primers (but make sure you maintain a tsv format). You can also copy the file in SEDNA
```
#assay	sample	barcodes	forward_primer	 reverse_primer	extra_information
16S_fish	S040713_1	:	GACCCTATGGAGCTTTAGAC	CGCTGTTATCCCTADRGTAACT	confirmed in JVB1836-16SDegenerate-testmethods.txt
```

&nbsp;
&nbsp;

***Make a sample.map file***

A `sample.map` file is only needed if you want `rainbow_bridge` to midify the file names. In this case I am using an in-house script to rename files so I don't need a sample map. If you do need to make one then a `sample.map` is a simple text file with the 3 columns: the base name, name of the forward, and reverse files.

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
&nbsp;

***Making a Parameter yml file***

When running rainbow, you can either include the complete command using flags such as 
```
--paired --reads ../data/ --barcode '../data/*.tsv'
```

Or you can make a yml parameter file where you specified all the setting used by each run. In this file, each flag is place in a new line, removing the initial "--" and placing a column after the name of the flag. Additionally, for flags that do not have an additional argument such as "--paired", you should use "True" or "False". For example:
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

Normally, I would recommend using a params yml file but currently `NEXTFLOW` in SEDNA is not parsing params files so we have to directly modify the flags in the script running `rainbow` for now.

---

</p>
</details>

<details><summary>Script Setup</summary>
<p>

First copy the base script 
```
cd /home/egarcia/projects/pifsc_p224_16S_fish/
cp /share/all/rainbow_bridge_in-house-scripts/run_rainbow_bridge_locally_sedna.sh scripts
```

Now make a subdirectory inside analyses for each run you do. That is, you might have 
multiple run with different parameters

I am naming my subdirs with a few paramaters which I know I might modify in the future. 
This way I can recognize individual runs immediately.

Make a subdir for my run and copy the run script there:
```
mkdir analyses/blast_0_0_lca_70_70_1000hits_midori2
cp scripts/run_rainbow_bridge_locally_sedna.sh analyses/blast_0_0_lca_70_70_1000hits_midori2
```

Normally I would make a config file (params file) and run rainbow_bridge by passing this config. 
Yet, currently NEXTFLOW in SEDNA is not parsing config files. Thus, we have to modify the script directly

Now modify the script directly with the desired parameters. Base script has:
```
nextflow run /home/egarcia/pipelines/rainbow_bridge_unzipfix/rainbow_bridge.nf \
  --maxMemory '185 GB' \
  --paired \
  --demultiplexed-by index \
  --reads ../../data/ \
  --barcode ../../data/demuxed_barcodes.tsv \
  --blast \
  --blast-db '/share/all/midori2_database/2025-03-08_customblast_sp_uniq_16S/midori2_customblast_sp_uniq' \
  --publish-mode copy \
  --alpha 2 \
  --zotu-identity 1 \
  --max-query-results 1000 \
  --primer-mismatch 2 \
  --qcov 0 \
  --percent-identity 0 \
  --evalue 0.1 \
  --lulu \
  --fastqc \
  --collapse-taxonomy \
  --dropped "LCA_dropped" \
  --lca-qcov 70 \
  --lca-pid 70 \
  --lca-diff 1 \
  --taxdump /share/all/ncbi_database/new_taxdump.zip
```
modify these as needed.

I like to document the settings used in a `params.txt` file:
```
grep -E '^nextflow run | ^  --' run_rainbow_bridge_locally_sedna.sh > params.txt
```

---

</p>
</details>

<details><summary>Execute rainbow_bridge</summary>
<p>

Now that you have everything ready you can execute  `rainbow_bridge` with:
```
cd analyses/blast_0_0_lca_70_70_1000hits_midori2
sbatch run_rainbow_bridge_locally_sedna.sh
```
*Can take multiple hours depending on the size of your dataset*

---

</p>
</details>

---

## Reviewing Results

<details><summary>Check your Run</summary>
<p>
	
Once your job is done, the first thing to do is to review the slurm out file and see if your run worked or there were issues.

Use `less` to open your slurm out file. Rainbow will report work done step by step. Thus I would recommend going straigth to the bottom (shirt + G) which will have the report for all the steps. If the run was successfull, you should see a checkmark in every step. Similar to:
```
executor >  local (4081)
[d7/f7024d] unzip (1011)          | 1016 of 1016 ✔
[78/a72092] fix_barcodes (1)      | 1 of 1 ✔
[cf/83c064] first_fastqc (433)    | 508 of 508 ✔
[71/56f697] first_multiqc (1)     | 1 of 1 ✔
[62/eec206] filter_merge (501)    | 508 of 508 ✔
[ac/bf1d37] second_fastqc (508)   | 508 of 508 ✔
[53/4adf8a] second_multiqc (1)    | 1 of 1 ✔
[cf/514d07] ngsfilter (499)       | 508 of 508 ✔
[ea/13025b] filter_length (508)   | 508 of 508 ✔
[c9/d20aeb] relabel (507)         | 508 of 508 ✔
[b2/ce8fbd] merge_relabeled       | 1 of 1 ✔
[26/63bbb8] dereplicate (1)       | 1 of 1 ✔
[3d/2b966b] get_taxdb (1)         | 1 of 1 ✔
[3c/3e86ab] extract_taxdb (2)     | 2 of 2 ✔
[5f/94dd14] blast (1)             | 1 of 1 ✔
[19/843fe8] lulu_blast (1)        | 1 of 1 ✔
[48/a65f44] lulu (1)              | 1 of 1 ✔
[82/f919ea] extract_lineage (1)   | 1 of 1 ✔
[6c/0eaf02] extract_ncbi (3)      | 3 of 3 ✔
[38/7badd5] collapse_taxonomy (1) | 1 of 1 ✔
[54/b238b2] finalize (1)          | 1 of 1 ✔
Completed at: 30-Apr-2025 20:56:03
Duration    : 32m 50s
CPU hours   : 9.4
```

If your slurm looks like this and you can't find errors, then your run probably work fine!

Thus, you should see the directories:
* work
* preprocess
* output

&nbsp;
&nbsp;

**ERRORS**

`rainbow_bridge` will hault when encounter an error, so I usually go straight to the bottom of the 
slurm out file and see if I got all checkmarks or there is some error(s).

If you see an error at the bottom, there is likely another error before this (one error causes others downstream). 

* Scroll up till you locate the first error and throubleshoot that one and then rerun rainbow
	* rainbow does have the ability to run certain steps independently (like collapse_taxonomy).
 	* NEXFLOW also have the `-resume` flag/option which would pick up the processing where the previous run left. **YET, this has not been tested in SEDNA**
* Document your error(s) in the "Error Logging" below

</p>
</details>

<details><summary>rainbow_bridge Output</summary>
<p>

Read the [rainbow_bridge](https://github.com/mhoban/rainbow_bridge) documentation for a full description of the ouput.

Briefly, rainbow will create 3 main subdirectories:
* **work**
  * These are files created by NEXTFLOW (genrally, you don't need to look at these).
  * If you use symlinks, these will direct to one directory withing `work`
* **preprocess**
  * Various intermediate files as filters, trims, etc, are applied to sequence files
  * Here, you can analyze the quality of your dataset and see what filters remove more reads, etc.
  * We summarise these at a later step in this pipeline     
* **output (this is what you want)**
  * blast
    * reports all the hits per zotu (within given parameters) in the file `blast_result_merged.tsv`
  * fastqc
    * creates individual qc and multiqc reports before (initial) and after (filtered) preprocessing
  * zotus
    * creates zOTUs and reports abundances across samples in the file `zotu_table.tsv`
    * Provides zOTUs actual blasted sequences in the file `*_zotus.fasta`  
    * Provide a list of all unique sequences across samples in the file `*_unique.fasta`
   * lulu
     * Filters dubious zOTUs and creates a new filtered abundance table in `lulu_zotu_table.tsv`
   * taxonomy
     * Puts taxonomic labels to the previous zotu table
     * Provides all the hits per zOTU that pass your setting in `lca_intermediate.tsv`
     * Chooses the top hit for each zOTU base in a lowest common ancestor (**LCA**) or phylogenetic (**phyloseq**) algorithm
     * If a single zOTU has multiple hits with equal blast results, LCA will collapse the label to the taxonomic level where the assignations are the same for all hits, reported in `lca_taxonomy.tsv` 
    * final
      * puts the various zotu tables and taxonomy together (and other reports if demanded)
      * `zotu_table_raw.tsv` same as `zotu_table.tsv`
      * `zotu_table_final.tsv` combines `zotu_table.tsv` and `lca_taxonomy.tsv`
      * `zotu_table_final_curated.tsv` combines `lulu_zotu_table.tsv` and `lca_taxonomy.tsv`
     
</p>
</details>

<details><summary>Error Logging</summary>
<p>

If you got an error please document it here so that future users can get a head start if they encounter the same or similar error.

* Populate an row in the error_summary_table
* Place a copy of your slurm out in

</p>
</details>

<details><summary>Read fate in preprocess</summary>
<p>

Is time to analyze your results!!! 

First, we'll see how did your dataset fared in the filtering and preprocessing steps.

&nbsp;
&nbsp;

**Make a Preprocess README**

We will make a readme to document the preprocess results separately from the main readme for better organization.

Navigate to the preprocess directory:
```
cd preprocess
nano README_preprocess.md
```
or you can use the following README as a template and modify as needed.
```
/home/egarcia/projects/pifsc_p224_16S_fish/analyses/blast_0_0_lca_70_70_1000hits_midori2/preprocess/README_preprocess.md
```
This readme can also be downloaded from git [here](https://github.com/ericgarciaresearch/pifsc_p224_16S_fish/blob/main/analyses/blast_0_0_lca_70_70_1000hits_midori2/preprocess/README_preprocess.md)

&nbsp;
&nbsp;

**Generate Read Count Summary**


Copy the scripts for analyzing the read number and loss during preprocessing:
```
cp /share/all/rainbow_bridge_in-house-scripts/read_calculator_rainbow_preprocess.sh ../../../scripts/
```

Execute the `read_calculator_rainbow_preprocess.sh` script 
```
srun ../../../scripts/read_calculator_rainbow_preprocess.sh
```
* This script creates **read_count_preprocessing.tsv** file that reports the number of reads remaning after each step is run as well as the percent of reads loss in each step relative to the previous
* We will then visualize the read fate processing this tsv file with the R script **plot_rainbow_preprocess.R**

If your read calculator worked ok you should see a tsv file that looks like this:

|sample | raw_F | raw_R | trim_merge  |  ngsfilter  |   l_filtered  |  relabeled  |   %_loss_trim_merge  |  %_loss_ngsfilter | %_loss_l_filtered  |   %_loss_relabeled| 
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|S040713_1  |   84476 | 84476 | 83435 | 83381 | 83381 | 83381 | 1.23 | 0.06 | 0.00 | 0.00| 
|S040713_2  |   69722 | 69722 | 68909 | 68851 | 68851 | 68851 | 1.17 | 0.08 | 0.00 | 0.00| 
|S040715_1  |   76527 | 76527 | 75781 | 75753 | 75753 | 75753 | 0.97 | 0.04 | 0.00 | 0.00| 
|S040715_2  |   48762 | 48762 | 48407 | 48381 | 48381 | 48381 | 0.73 | 0.05 | 0.00 | 0.00|

Review your table and look for read flags or disernable patterns. 

&nbsp;
&nbsp;

**Ploting Read Summary**

Now that you have `read_count_preprocessing.tsv` you can use the following custom Rscript to make plots to visualize and easily identify patterns.
```
/share/all/rainbow_bridge_in-house-scripts/plot_rainbow_preprocess.R
```

Either:
1. Download both `plot_rainbow_preprocess.R` and `read_count_preprocessing.tsv`, and run in your local computer
  * Upload plots into the `preprocess` dir
  * Push all files
  * Embed plot inside the README. 
    * Example: ![anyname](actual name of file)
      * ```
        ![plot1](barplot_preprocess_read_summary.png)
        ```
    * Full example [here](https://github.com/ericgarciaresearch/pifsc_p224_16S_fish/edit/main/analyses/blast_0_0_lca_70_70_1000hits_midori2/preprocess/README_preprocess.md)
2. Run the Rscript in SEDNA
  * Coming soon

--- 

</p>
</details>

<details><summary>Output (Main Metabarcoding Results)</summary>
<p>
	
Time to digest the main dish, the metabarcoding results :)

Navigate to your run directory:
```
cd /home/egarcia/projects/pifsc_p224_16S_fish/analyses/blast_0_0_lca_70_70_1000hits_midori2
```
Again, the metabarcoding results will be in the `output` directory. 

&nbsp;

**FASTQC Quality Reports**

Review and make the initial (before preprocessing) and filtered (after preprocessing) FASTQC reports available in your README. 
```
output/fastqc/initial/multiqc_report.html
output/fastqc/filtered/multiqc_report.html
```
Push these files if you haven't done so already. Then provide the https link to them. You can use the following for reporting
```
* [Initial](linkt_to_inial_report)
* [Filtered](linkt_to_filtered_report)
```
See the [pifsc_p224_16S/README](https://github.com/ericgarciaresearch/pifsc_p224_16S_fish/edit/main/README.md) as an example

To view these files, you will have to download them and open them with a web browser.

* Provide a general description of the condition of your data and/or
* Note any read flags
  
**Analyse Metabarcoding Results**

I have created an R script that can read the main files from output and analyze the main metarbarcoding results:

* summarize_rainbow_output.R 

This script lives in the shared rainbow_bridge_in-house-scripts dir:
```
share/all/rainbow_bridge_in-house-scripts/summarize_rainbow_output.R
````

First copy the R script that analyzes the rainbow output
```
cp /share/all/rainbow_bridge_in-house-scripts/summarize_rainbow_output.R ../../scripts/
```

Just as before, you can run this script locally or directly in SDENA

1. Locally
   
1.1 Download the following main files
```
../../scripts/summarize_rainbow_output.R
preprocess/read_count_loss_preprocess.tsv
output/zotus/zotu_table.tsv
lulu/lulu_zotu_table.tsv 
output/blast/*/blast_result_merged.tsv 
output/taxonomy/lca/*/lca_intermediate.tsv
output/taxonomy/lca/*/lca_taxonomy.tsv 
output/final/zotu_table_final_curated.tsv
```
1.2 Place all files in the same directory then open and run `summarize_rainbow_output.R`

This script will generate the following plots:
* p1_reads_per_init-final_samples.png
* p2_number_of_hits.png
* p3_eval_before_after_filters.png
* p4_pident_qcov.png
* p5_number_of_zotus.png
* p6_final_taxonomic_diversity.png
* p7_number_of_lca_drops.png
* p8_spread_taxonomic_diversity.png
* p9_top10_species.png
* p10_top10_genera.png
* p11_top10_families.png
* p12_top10_orders.png
* p13_top10_classes.png
* p14_top10_phyla.png

1.3 Upload all these plots into `output` and push them

1.4 Embed the plots into your main README. See the [pifsc_p224_16S/README](https://github.com/ericgarciaresearch/pifsc_p224_16S_fish/edit/main/README.md) as an example

2. Run the Rscript in SEDNA
  * Coming soon
