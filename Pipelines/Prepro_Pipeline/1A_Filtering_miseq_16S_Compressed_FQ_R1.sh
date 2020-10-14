#!/bin/bash


if [ $# -le 1 ]
  then
    echo "No argument was supplied .... please add these following arguments :"
    echo "1) Absolute path of folder name containing your fastq.gz sequenced data"
    echo "2) The threshold of quality sanger filtering : 20, 22, 23, 25, 30, 33"
    exit
fi


# 1. Firt step 
# INPUT FOLDER
# Set here the directory PATH which contains your FASTQ files change it accordingly ...
export WORK="/home/bacharcheaib/PIPELINES_GITHUB/Microbiome_Pipelines/Run_cripts_Prepro_Pipeline"
export DATA="$1"
echo $DATA

# Set the directory PATH of results"_Q_"$2"  change it accordingly ...

RESULTS="$WORK/results"_Q_"$2"
#set Software 
#export FASTQTOFASTA=$(which fastq_to_fasta)
export FASTQTOFASTA=$(which fastq_to_fasta_fast)

export SICKLE=$(which sickle)
echo $SICKLE

#Set the threshold for quality filtering 
## sequencing tecnology : sanger, illumina, etc

export tech="sanger"

export QT=$2

#2. Second step 

if [ ! -d "$RESULTS" ]
then mkdir "$RESULTS"
fi

export DATAWORK="$RESULTS"

cd $DATAWORK

# SET OUPUT FOLDERS FOR EACH STEP

export STAT="stats_R1"
mkdir ./$STAT

export FORWARD="R1"
mkdir ./$FORWARD	


cd $DATA

ls *_R1_001.fastq.gz > $DATAWORK/All_16s_R1_samples.txt
## ls *_R2_001.fastq.gz > $DATAWORK/All_16s_R2_samples.txt

cd $DATAWORK

sed -i 's/_R1_001.fastq.gz//g' All_16s_R1_samples.txt
## sed -i 's/_R2_001.fastq.gz//g' All_16s_R2_samples_prefix.txt

sed -i 's/ /\n/g' All_16s_R1_samples.txt

# MAIN CODE BLOCK
#----------------------------------------------------------------------

cat "All_16s_R1_samples.txt" 
cat "All_16s_R1_samples.txt" | while read i

do
	# Count reads and average read length BEFORE trimming
	echo "Count reads and average read length BEFORE trimming for $i..."

        ##For R1
        awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' <(zcat "$DATA/$i"_R1_001.fastq.gz) > "$DATAWORK/$STAT/$i"_R1_before_QC_trim_stats
        awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' <(zcat "$DATA/$i"_R1_001.fastq.gz) > "$DATAWORK/$STAT/$i"_R1_before_QC_trim_distrib.txt
        ## For R2
        # awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' <(zcat "$DATA/$i"_R2_001.fastq.gz) > "$DATAWORK/$STAT/$i"_R2_before_QC_trim_stats
        # awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' <(zcat "$DATA/$i"_R2_001.fastq.gz) > "$DATAWORK/$STAT/$i"_R2_before_QC_trim_distrib.txt

	#Quality trimming with Sickle, select a threshold of base pair quality
	echo "Trimming reads of sample $i ..."
 	
	$SICKLE se -f "$DATA/$i"_R1_001.fastq.gz -t $tech -o "$DATAWORK/$FORWARD/$i"_R1.trim.fastq -q $QT -l 100

	### Delete space from fastq headers
	perl -i -p -e 's/ 1:N/:1:N/g' "$DATAWORK/$FORWARD/$i"_R1.trim.fastq
	### perl -i -p -e 's/ 1:N/:1:N/g' "$DATAWORK/$FORWARD/$i"_R2.trim.fastq
	#Count reads and average read length AFTER trimming		
	echo "Count reads and average read length AFTER trimming /$i..."
	awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' "$DATAWORK/$FORWARD/$i"_R1.trim.fastq > "$DATAWORK/$STAT/$i"_R1_after_QC_trim_stats
	awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' "$DATAWORK/$FORWARD/$i"_R1.trim.fastq > "$DATAWORK/$STAT/$i"_R1_after_QC_trim_distrib.txt
	### awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' "$DATAWORK/$TRIM/$i"_R2.trim.fastq > "$DATAWORK/$STAT/$i"_R2_after_QC_trim_stats
	### awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' "$DATAWORK/$TRIM/$i"_R2.trim.fastq > "$DATAWORK/$STAT/$i"_R2_after_QC_trim_distrib.txt
	
	#$FASTQTOFASTA -i "$DATAWORK/$FORWARD/$i"_R1.trim.fastq -o "$DATAWORK/$FORWARD/$i"_R1.trim.fasta
	$FASTQTOFASTA "$DATAWORK/$FORWARD/$i"_R1.trim.fastq > "$DATAWORK/$FORWARD/$i"_R1.trim.fasta

	### Compile stats for each sample	

	cd $DATAWORK/$STAT
	tail "$i"_*_stats > "$i"_Q_"$QT"_stats_summary.txt
	cd ..

done

