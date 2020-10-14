#!/bin/bash

## If you want to rename all files in a directory
# do this to test how it looks like 
# rename -n 's/\_Q\.txt/\.txt/' *
#then remove -n option to do it


if [ $# -le 1 ]
  then
    echo "No argument was supplied .... please add these following arguments:"
    echo "1) What was the overlap length?"
    echo "2) What was the threshold of quality control?"

    exit
fi

used_overlap=$1
used_q_filter=$2

### see at the end that the name of the final file is "all.Stats.Filtation.O."$used_overlap".Q."$used_q_filter".R1.csv"


## Change the path accordingly 
export WORK="/home/bacharcheaib/PIPELINES_GITHUB/Microbiome_Pipelines/Run_cripts_Prepro_Pipeline"
export STATS="$WORK/results"_Q_"$2"/stats_R1"

cd $STATS


############# R1 ############################

## Get R1 sequence number before trimming 

for i in $(ls *_stats_summary.txt) ;
	do echo $(basename $i "_stats_summary.txt") ":" $(grep "R1_before" -A 1 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d') >> all.size.samples.R1.before.trim.csv ;
done;

## Get R1 average lengths before trimming 

for i in $(ls *_stats_summary.txt) ;
	do echo $(basename $i "_stats_summary.txt") ":" $(grep "R1_before" -A 2 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d' |tail -n 1) >> all.len.samples.R1.before.trim.csv;
done;


## Get R1 sequence number after trimming 

for i in $(ls *_stats_summary.txt) ;
	do echo $(basename $i "_stats_summary.txt") ":" $(grep "R1_after" -A 1 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d') >> all.size.samples.R1.after.trim.csv;
done;

## Get R1 average lengths after trimming 

for i in $(ls *_stats_summary.txt) ;

	do echo $(basename $i "_stats_summary.txt") ":" $(grep "R1_after" -A 2 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d' |tail -n 1) >> all.len.samples.R1.after.trim.csv ; 
done;

awk '{a[FNR]=a[FNR]":"$0} END{for(x in a) { print a[x]}}' all.size.samples.R1.before.trim.csv all.len.samples.R1.before.trim.csv all.size.samples.R1.after.trim.csv all.len.samples.R1.after.trim.csv > All.Stats.tempo


echo "Samples:R1.bf.size:R1.bf.len:R1.af.size:R1.af.len" >> "all.Stats.Filtation.O."$used_overlap".Q."$used_q_filter".R1.csv"
cut -d ":" -f2,3,5,7,9 All.Stats.tempo >> "all.Stats.Filtation.O."$used_overlap".Q."$used_q_filter".R1.csv"

rm All.Stats.tempo


## Now you can vizualise your results"_Q_"$2" "all.Stats.Filtation.Overlapping.csv" in excel 
## and you can decide whether your selected parameters in filtration and merging were satisfactory
## You can re-run the PART A and do no forget to rename your outpouts directory with the already used parameters in order to distinguish between old from new results"_Q_"$2".

## End of part A 

