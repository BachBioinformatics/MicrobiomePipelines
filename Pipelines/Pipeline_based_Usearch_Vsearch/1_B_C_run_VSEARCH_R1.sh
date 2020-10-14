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
export DATA_FILTRED="$WORK/R1"

cd $WORK
mkdir "$WORK/res_vsearch_R1"
export resvsearch="$WORK/res_vsearch_R1"
#export VSEARCH=$(which vsearch)
export VSEARCH="/home/opt/vsearch/bin/vsearch"

cd $DATA_FILTRED

mkdir "DEREP"
DEREP="$DATA_FILTRED/DEREP"


cat $WORK/$2 | while read prefix

	do 
		#echo "$prefix" 
		i=$prefix*".fasta"
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


