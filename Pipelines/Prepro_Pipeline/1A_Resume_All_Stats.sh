#!/bin/bash

## If you want to rename all files in a directory
# do this to test how it looks like 
# rename -n 's/\_Q\.txt/\.txt/' *
#then remove -n option to do it

if [ $# -le 1 ]
  then
    echo "No argument was supplied .... please add these following arguments:"
    echo "1) What was the threshold of quality control?"
    echo "2) What was the overlap length?"

    exit
fi

used_overlap=$2
used_q_filter=$1

### see at the end that the name of the final file is "all.Stats.Filtation.O."$used_overlap".Q."$used_q_filter".Overlapping.csv"


## Change the path accordingly 
export WORK="/home/bacharcheaib/PIPELINES_GITHUB/Microbiome_Pipelines/Run_cripts_Prepro_Pipeline"
export STATS="$WORK/results"_Q_"$1"_O_"$2/stats"
export SINGLES="$WORK/results"_Q_"$1"_O_"$2/singles"

############ Treat Singles seperatly #############
cd $SINGLES

grep -c "^@.* 1:N:" *.fastq > "all.Singles.R1.Q."$used_q_filter".O."$used_overlap".csv"
grep -c "^@.* 2:N:" *.fastq > "all.Singles.R2.Q."$used_q_filter".O."$used_overlap".csv"

############# R1 + R2 ############################

cd $STATS

## Get average lengths after overlap

for i in $(ls *_stats_summary.txt) ;
	
	do echo $(basename $i "_stats_summary.txt") ":" $(grep "overlap" -A 2 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d' |tail -n 1) >> all.len.samples.ovelap.csv;
done;


## Get sequence number after overlap

for i in $(ls *_stats_summary.txt) ;
        
        do echo $(basename $i "_stats_summary.txt") ":" $(grep "overlap" -A 1 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d') >> all.size.samples.ovelap.csv;
done;


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



############# R2 ############################


## Get R2 sequence number before trimming 

for i in $(ls *_stats_summary.txt) ;

        do echo $(basename $i "_stats_summary.txt") ":" $(grep "R2_before" -A 1 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d') >> all.size.samples.R2.before.trim.csv ;
done;

## Get R2 average lengths before trimming 

for i in $(ls *_stats_summary.txt) ;

        do echo $(basename $i "_stats_summary.txt") ":" $(grep "R2_before" -A 2 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d' |tail -n 1) >> all.len.samples.R2.before.trim.csv ;
done;


## Get R2 sequence number after trimming 

for i in $(ls *_stats_summary.txt) ;

        do echo $(basename $i "_stats_summary.txt") ":" $(grep "R2_after" -A 1 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d') >> all.size.samples.R2.after.trim.csv;
done;

## Get R2 average lengths after trimming 

for i in $(ls *_stats_summary.txt) ;

        do echo $(basename $i "_stats_summary.txt") ":" $(grep "R2_after" -A 2 $i | grep -v "=" | sed -e s/\_stats\_summary\.txt\-/\\t/ | sed -e '/--/d' |tail -n 1) >>all.len.samples.R2.after.trim.csv ;
done;


## Now concatenate horizontally all files in one file


awk '{a[FNR]=a[FNR]":"$0} END{for(x in a) { print a[x]}}' all.size.samples.R1.before.trim.csv all.len.samples.R1.before.trim.csv all.size.samples.R2.before.trim.csv all.len.samples.R2.before.trim.csv all.size.samples.R1.after.trim.csv all.len.samples.R1.after.trim.csv all.size.samples.R2.after.trim.csv all.len.samples.R2.after.trim.csv all.size.samples.ovelap.csv all.len.samples.ovelap.csv > All.Stats.tempo


echo "Samples:R1.bf.size:R1.bf.len:R2.bf.size:R2.bf.len:R1.af.size:R1.af.len:R2.af.size:R2.af.len:size.ovelap.avg:len.overlap.avg" >> "all.Stats.Filtation.Q."$used_q_filter".O."$used_overlap".Overlapped.csv"
cut -d ":" -f2,3,5,7,9,11,13,15,17,19,21 All.Stats.tempo >> "all.Stats.Filtation.Q."$used_q_filter".O."$used_overlap".Overlapped.csv"


rm All.Stats.tempo


## Now you can vizualise your results"_Q_"$2"_O_"$3 "all.Stats.Filtation.Overlapping.csv" in excel 
## and you can decide whether your selected parameters in filtration and merging were satisfactory
## You can re-run the PART A and do no forget to rename your outpouts directory with the already used parameters in order to distinguish between old from new results"_Q_"$2"_O_"$3.

## End of part A 


