#!/bin/bash

#### Pipeline 2 execution ####
#### step 0 : set path of pipelines scripts on your local environment  ####

bash 00_rename_paths_pipelines.sh

#### step 1 : Filtration with different parameters : First is Quality control threshold ; second the reads merging overlap length in base pairs ####

### how to decide an overlap adapted to your data ?  
### In theory : (Length R1 + Length R2) - Length of amplified gene(or region if the gene, ex V1; or V3-V4 in 16S rDNA)

## What is the script to run ?

## if your data are uncompressed, execute : 1A_Filtering_miseq_16S_Uncompressed_merge_reads.sh
## if your data are compressed, execute : 1A_Filtering_miseq_16S_Compressed_merge_reads.sh

#./../Pipelines/Prepro_Pipeline/1A_Filtering_miseq_16S_Compressed_merge_reads.sh /shared2/salmosim/bachar/Microbiome_Pipelines/fastq_files_example 33 130
#./../Pipelines/Prepro_Pipeline/1A_Filtering_miseq_16S_Compressed_merge_reads.sh /shared2/salmosim/bachar/Microbiome_Pipelines/fastq_files_example 33 95
#./../Pipelines/Prepro_Pipeline/1A_Filtering_miseq_16S_Compressed_merge_reads.sh /shared2/salmosim/bachar/Microbiome_Pipelines/fastq_files_example 33 75
./../Pipelines/Prepro_Pipeline/1A_Filtering_miseq_16S_Compressed_merge_reads.sh /shared2/salmosim/bachar/Microbiome_Pipelines/fastq_files_example 30 50



### Run a script to resume the statistics of reads number and length after and before the filtration, aand the merging 
#./../Pipelines/Prepro_Pipeline/1A_Resume_All_Stats.sh 33 130
#./../Pipelines/Prepro_Pipeline/1A_Resume_All_Stats.sh 33 95
#./../Pipelines/Prepro_Pipeline/1A_Resume_All_Stats.sh 33 75
./../Pipelines/Prepro_Pipeline/1A_Resume_All_Stats.sh 30 50


## move all the necessary files of statistics summaries to your the working directory file 
cp results*/stats/all.Stats* .
cp results*/singles/all.Singles* .

## Optimize you choice of QC and overlap parameters by assessing the integrity of your data through benchmarking graphs and barplots
R CMD BATCH Run_Stats_Benchmarking_Params.R

