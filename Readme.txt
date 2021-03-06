## MicrobiomePipelines Version 1.0 (next improvements and updates will follow)
## Author : cheaib.bachar@gmail.com
## How to Run the Pipeline on your local computer 


Before you run the pipeline you need to install to your HOME PATH the following softwares 
Linux environment (Debian or redhat)
Sickle 
Pandaseq
R language 
VSEARCH version 2.15
USEARCH versions 9 and 10 
Mafft
Fastree
Miniconda2
Qiime2

git clone link
cd Microbiome_Pipelines

## Under the folder Pipelines you see two subfolders : 1) Preprocessing pipeline and 2) OTUs clustering and annotation pipeline 
## The first subfolder contains the Preprocessing pipeline which is a Benchmarking that help you to decide the parameters : Reads merging and the threshold of quality filtration
## The reason of benchmarking is often associated to the bad quality of R2 sequencing by some sequencing platforms, when the R2 is too bad the merging will reduce your reads at 90%
## That is why we want to avoid the massive loss of data, in this case our pipeline suggest an alternative with and without reads merging.

cd Run_Pipelines

########################## Preprocessing and Benchmarking filtration parameters ############################
#### For Paired End Reads 
## Run the preprocessing pipeline with the option of reads merging with different parameters : quality threshold and length of overlapping segment between R1 and R2 

## The following script will run automatically the benchmarking with different patrameters 
## The parameters can be personnalized by editing the following script before you run it [Run_Prepro_Pipeline_Paired_end.sh]

## Run now the script 

./Run_Prepro_Pipeline_Paired_end.sh

## The script that you have just run will call others scripts available in 
## --> The appropriate scripts in ../Pipelines/Prepro_Pipeline 
## --> 00_rename_paths_pipelines.sh
## --> Run_Stats_Benchmarking_Params.R

## Vizualise all the R statistics of benchmarking resumed in plots in pdf outputs 
## the user will decide wether the overlap and quality threshold are fair or unfair regarding the percentage of lost reads 
## You can run the script again with nea parameters by descativating the old code lines corresponding to the old parameters 
## if the overlap seems not good and R2 quality is bad, you can work only with R1 or R2 without merging 
## so you can follow the single scripts 

### For single end reads  :

./Run_Prepro_Pipeline_Single_end.sh
## this script will appply
## --> The appropriate scripts in ../Pipelines/Prepro_Pipeline 
## --> 00_rename_paths_pipelines.sh
## --> Run_Stats_Benchmarking_Params.R

########################## Post- benchamking pipeline : Otus clustering and annotations  ############################


################ Install the Reference databases ################################## 
./../Pipelines/Pipeline_based_Usearch_Vsearch/1D_01_set_references_databases.sh /shared2/salmosim/bachar/Microbiome_Pipelines Programs

## Dreplication and samples size filtration which discard samples having less than 10000 reads after filtration 

/../Pipelines/Pipeline_based_Usearch_Vsearch/1_B_C_run_VSEARCH.sh /shared2/salmosim/bachar/Microbiome_Pipelines/Run_Pipelines/results_Q_30_O_50 All_16s_samples_prefix.txt 10000


## Denovo OTUs clustering and annotations [1D_02_run_overlap_R1_R2_VSEARCH_RDP_SILVAQiime2_last_version.sh]
## This step consists on removing chimeras, cluster otus with different algorithms implemented in vsearch, 
## decntaminate otus using approriate genome reference 
## annotate OTUs against RDP or SILVA databases using Usearch or Qiime2 depeding on the size of your data

./../Pipelines/Pipeline_based_Usearch_Vsearch/1D_02_run_overlap_R1_R2_VSEARCH_RDP_SILVAQiime2_last_version.sh /shared2/salmosim/bachar/Microbiome_Pipelines References_database Run_Pipelines/results_Q_30_O_50 Programs yes










