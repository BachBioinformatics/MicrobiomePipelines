#!/bin/bash


if [ $# -le 2 ]
  then
    echo "No argument was supplied .... please add these following arguments :"
    echo "1) Absolute path of folder name containing your fastq.gz sequenced data"
    echo "2) The threshold of quality sanger filtering : 20, 22, 23, 25, 30, 33"
    echo "3) The threshold of ovelaping length of R1 and R2 : 15, 20, 25, 50, higer more confidence : R1 + R2 should cover the length of your amplified DNA"
    exit
fi


##### PLEASE PAY attention of the name of fastq file ########
##### They should be end up with R1_001.fastq or R2_001.fastq

#1. Firt step

# INPUT FOLDER
# Set here the directory PATH which contains your FASTQ files change it accordingly ...

export WORK="/home/bacharcheaib/PIPELINES_GITHUB/Microbiome_Pipelines/Run_cripts_Prepro_Pipeline"
## where are the programs 

export SICKLE=$(which sickle)
## where is Pandaseq 
PANDASEQ="/home/opt/pandaseq_new2/pandaseq/pandaseq"

#export PANDASEQ=$(which pandaseq)
export $PANDASEQ

echo $SICKLE

export DATA="$1"
echo $DATA
# Set the directory PATH of results"_Q_"$2"_O_"$3  change it accordingly ...
RESULTS="$WORK/results"_Q_"$2"_O_"$3"


#Set the threshold for quality filtering 
## sequencing tecnology : sanger, illumina, etc

export tech="sanger"
export min_overlap="$3"
# Set the threshold for quality filtering 
export QT="$2"

#2. Second step 

if [ ! -d "$RESULTS" ]
then mkdir "$RESULTS"
fi

export DATAWORK="$RESULTS"

cd $DATAWORK

# OUPUT FOLDERS

export STAT="stats"
mkdir ./$STAT

export TRIM="trimming"
mkdir ./$TRIM

export OVERLAP="overlap"
mkdir ./$OVERLAP	

export SINGLE="singles"
mkdir ./$SINGLE

# CREATE LIST

cd $DATA

ls *_R1_001.fastq > $DATAWORK/All_16s_R1_samples_prefix.txt

cd $DATAWORK

cat All_16s_R1_samples_prefix.txt > All_16s_samples_prefix.txt

sed -i 's/_R1_001.fastq//g' All_16s_samples_prefix.txt

sed -i 's/ /\n/g' All_16s_samples_prefix.txt

# MAIN CODE BLOCK
#----------------------------------------------------------------------

cat "All_16s_samples_prefix.txt" | while read i

do
	# Count reads and average read length BEFORE trimming
	echo "Count reads and average read length BEFORE trimming for $i..."
	##For R1
	cat "$DATA/$i"_R1_001.fastq | awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' > "$DATAWORK/$STAT/$i"_R1_before_QC_trim_stats
	cat "$DATA/$i"_R1_001.fastq | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' > "$DATAWORK/$STAT/$i"_R1_before_QC_trim_distrib.txt
	## For R2
    	cat "$DATA/$i"_R2_001.fastq | awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' > "$DATAWORK/$STAT/$i"_R2_before_QC_trim_stats
    	cat "$DATA/$i"_R2_001.fastq | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' > "$DATAWORK/$STAT/$i"_R2_before_QC_trim_distrib.txt

	# Quality trimming
	echo "Trimming reads of sample $i ..."
	### sickle se -f "$DATA/$i"_R2.fastq.gz -t sanger -o "$DATAWORK/$TRIM/$i"_R2.trim.fastq -q 23 -l 100
	

	$SICKLE pe -f "$DATA/$i"_R1_001.fastq -r "$DATA/$i"_R2_001.fastq -t $tech -o "$DATAWORK/$TRIM/$i"_R1.trim.fastq -p "$DATAWORK/$TRIM/$i"_R2.trim.fastq -s "$DATAWORK/$SINGLE/$i".singles.fastq -q $QT -l 100

	# Retirer espace du header fastq
    	perl -i -p -e 's/ 1:N/:1:N/g' "$DATAWORK/$TRIM/$i"_R1.trim.fastq
    	perl -i -p -e 's/ 2:N/:2:N/g' "$DATAWORK/$TRIM/$i"_R2.trim.fastq

	# Count reads and average read length AFTER trimming		
	echo "Count reads and average read length AFTER trimming /$i..."
	awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' "$DATAWORK/$TRIM/$i"_R1.trim.fastq > "$DATAWORK/$STAT/$i"_R1_after_QC_trim_stats
	awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' "$DATAWORK/$TRIM/$i"_R1.trim.fastq > "$DATAWORK/$STAT/$i"_R1_after_QC_trim_distrib.txt
	awk '{if(NR%4==2) b+=length($1)} END{print NR/4; print b/(NR/4)}' "$DATAWORK/$TRIM/$i"_R2.trim.fastq > "$DATAWORK/$STAT/$i"_R2_after_QC_trim_stats
	awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' "$DATAWORK/$TRIM/$i"_R2.trim.fastq > "$DATAWORK/$STAT/$i"_R2_after_QC_trim_distrib.txt
	
	# Assemblage des sequences paired-end avec PANDASEQ	
	echo "Assembling PE reads of sample $i..."
	$PANDASEQ -T 12 -f "$DATAWORK/$TRIM/$i"_R1.trim.fastq -r "$DATAWORK/$TRIM/$i"_R2.trim.fastq -A pear -B -d bfsrk -o $min_overlap -w "$DATAWORK/$OVERLAP/$i"_overlap.fasta -g "$DATAWORK/$STAT/$i"_overlap.fasta.log
	
	# Count reads and average read length of final output	
	## echo "Count reads and average read length for $i final output..."
	awk '{if(/^[A-Z]/) b+=length($1)} END{print NR/2; print b/(NR/2)}' "$DATAWORK/$OVERLAP/$i"_overlap.fasta > "$DATAWORK/$STAT/$i"_after_overlap_stats
	awk '/^[A-Z]/ {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' "$DATAWORK/$OVERLAP/$i"_overlap.fasta > "$DATAWORK/$STAT/$i"_after_overlap_distrib.txt
	
	# Compile stats for each sample	

	cd $DATAWORK/$STAT
	tail "$i"_*_stats > "$i"_Q_"$QT"_stats_summary.txt
	cd ..

done
