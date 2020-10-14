# MicrobiomePipelines Version 1.0 (semi-automatized pipelines for microbiome data processing, tutorial, improvements and updates will be added)
## Author: bachar.cheaib@glasgow.ac.uk
## How to run the Pipeline on your local computer 

## Before you run the pipeline you need to install to your HOME PATH the following softwares in your Linux environment (Debian or Redhat)
### --0-Miniconda2
### --1-Sickle 
### --2-Pandaseq
### --3-R language 
### --4-VSEARCH version 2.15
### --5-USEARCH versions 9 and 10 
### --6-Deconseq
### --7-bwa mem
### --8-Mafft
### --9-Fastree
### --10-Qiime2


> cd MicrobiomePipelines
## 
> mkdir Programs
##

###In the folder Programs you can add the executable softwares like userach 9 and 10
##
### Under the folder Pipelines you see two subfolders 
## 1) Preprocessing pipeline [Prepro_Pipeline]
## 2) OTUs clustering and annotation pipeline [Pipeline_based_Usearch_Vsearch]

##The first subfolder contains the Preprocessing pipeline which is a benchmarking for helping users to decide the parameters of reads merging and the threshold of quality filtration
###The reason of benchmarking is often associated to the bad quality of R2 sequencing by some sequencing platforms, when the R2 is too bad the merging will reduce your reads at 90%
###That is why we want to avoid the massive loss of data, in this case our pipeline suggest an alternative with and without reads merging.

> cd Run_Pipelines

## 1) Preprocessing and Benchmarking reads filtration parameters
## For paired-end reads 
###Run the preprocessing pipeline with the option of reads merging with different parameters : 
###quality threshold and length of overlapping segment between R1 and R2 

###The following script will run automatically the benchmarking with different patrameters 
###You need to edit your filtration parametaers before you the script [Run_Prepro_Pipeline_Paired_end.sh]

### Run now the script 
> ./Run_Prepro_Pipeline_Paired_end.sh

### This script will call
## --> The appropriate scripts in ../Pipelines/Prepro_Pipeline 
## --> 00_rename_paths_pipelines.sh
## --> Run_Stats_Benchmarking_Params.R

###Vizualise all the R statistics of benchmarking resumed in plots in pdf outputs 
###the user will decide wether the overlap and quality threshold are fair or unfair regarding the percentage of lost reads 
###You can run the script again with nea parameters by descativating the old code lines corresponding to the old parameters 
###if the overlap seems not good and R2 quality is bad, you can work only with R1 or R2 without merging 
###so you can follow the single scripts 

### For single end reads:

> ./Run_Prepro_Pipeline_Single_end.sh
## This script will call :
#--> The appropriate scripts in ../Pipelines/Prepro_Pipeline 
#--> 00_rename_paths_pipelines.sh
#--> Run_Stats_Benchmarking_Params.R

## 2) Post-benchamking pipeline : Otus clustering and annotations

##After statistics overview we select for example Q=30 bp ; Overlap= 50 bp, so we work in the next steps with this folder: results_Q_30_O_50

## Dreplication and samples size filtration which discard samples having less than 10000 reads after filtration [1_B_C_run_VSEARCH.sh]

> ./../Pipelines/Pipeline_based_Usearch_Vsearch/1_B_C_run_VSEARCH.sh /home/bach/Microbiome_Pipelines/Run_Pipelines/results_Q_30_O_50 All_16s_samples_prefix.txt 10000

## Install the Reference databases [1D_01_set_references_databases.sh ]
> ./../Pipelines/Pipeline_based_Usearch_Vsearch/1D_01_set_references_databases.sh /home/bach/Microbiome_Pipelines Programs


## Denovo OTUs clustering and annotations for paired-end results [1D_02_run_overlap_R1_R2_VSEARCH_RDP_SILVAQiime2_last_version.sh]
### This step consists on removing chimeras, cluster otus with different algorithms implemented in vsearch, 
### in case of host micorbiome decontaminattion of otus ir recommended :the user  have to set right host reference genome in the script
### annotate OTUs against RDP or SILVA databases using Usearch or Qiime2 depeding on the size of your data

> ./../Pipelines/Pipeline_based_Usearch_Vsearch/1D_02_run_overlap_R1_R2_VSEARCH_RDP_SILVAQiime2_last_version.sh /home/bach/Microbiome_Pipelines References_database Run_Pipelines/results_Q_30_O_50 Programs decontam


## Denovo OTUs clustering and annotations for single-end results [1D_02_run_R1_VSEARCH_RDP_SILVAQiime2_last_version.sh]
### This step consists on removing chimeras, cluster otus with different algorithms implemented in vsearch, 
### in case of host micorbiome decontaminattion of otus ir recommended :the user  have to set right host reference genome in the script
### annotate OTUs against RDP or SILVA databases using Usearch or Qiime2 depeding on the size of your data

> ./../Pipelines/Pipeline_based_Usearch_Vsearch/1D_02_run_overlap_R1_R2_VSEARCH_RDP_SILVAQiime2_last_version.sh /home/bach/Microbiome_Pipelines References_database Run_Pipelines/results_Q_30_O_50 Programs decontam



