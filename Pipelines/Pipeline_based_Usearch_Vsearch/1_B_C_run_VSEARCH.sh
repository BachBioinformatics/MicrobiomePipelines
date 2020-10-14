#!/bin/bash

## set your PATH to your work directory 
## Set your PATH to your overlaped reads 


if [ $# -le 2 ]
  then
    echo "No argument supplied .... please add:"
    echo "1)The Path to the results folder"
    echo "2)The specific file for sample BEFORE analysis"
    echo "3)The thershold of sample size filtration !!!"
    exit 
fi


export WORK=$1
export DATA_FILTRED="$WORK/overlap"
cd $WORK
mkdir "$WORK/res_vsearch_overlap"
export resvsearch="$WORK/res_vsearch_overlap"
#export VSEARCH=$(which vsearch)
export VSEARCH="/home/opt/vsearch/bin/vsearch"

## If you want to filter samples with size cutoff reads number desactivate the following line 
## use "Final_good_list_samples_names_prefix.txt" $DATA_FILTRED
## If not, use this "Prefix_All_samples_after_Q20_filter.txt" $DATA_FILTRED

cd $DATA_FILTRED

mkdir "DEREP"
DEREP="$DATA_FILTRED/DEREP"


cat $WORK/$2 | while read prefix

	do 
		echo "$prefix" 
		i=$prefix*"_overlap.fasta"
		echo $i
    		size=$(grep -e "^>" -c $i)
		
		if [ $size -ge $3 ]
			then
			echo Dereplicate at sample level and relabel with sample_n
    			$VSEARCH --threads 12 --derep_fulllength $i --strand plus --output $prefix.derep.fasta --sizeout --uc $prefix.derep.uc --relabel $prefix. --fasta_width 0
			cat $prefix.derep.fasta >> "all.dereplicated.nonsingletons.fasta"
			mv $prefix.derep.fasta $DEREP
			mv $prefix.derep.uc $DEREP
		else
			 echo $i "Did not pass the filter its size : " $size
		fi
done;	

cp "all.dereplicated.nonsingletons.fasta" $resvsearch

cd $resvsearch


