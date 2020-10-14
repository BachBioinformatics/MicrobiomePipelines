#!/bin/bash


if [ $# -le 4 ]
  then
    echo "No argument supplied .... please add:"
    echo "1)The absolute Path to Microbiome_Pipelines"
    echo "2)The path to subfolder References_database (might be in Microbiome_Pipelines)"
    echo "3)The Path to the subfolder results"
    echo "4)The Path to subfolder of softwares usearch version 9 and 10"
    echo "5) do you want to decontaminate your OTUs (use ssref for salmo salar ; ask cheaib.bachar@gmail.com for questions) : yes or no?"
    exit
fi


## set the number of core to use on your machine 

THREADS=12

## set paths 

PERL=$(which perl)
PYTHON=$(which python)

export WORK=$1
export SILVA="$1/$2/silva"
export RDP="/$1/$2/rdp"
export RESVSEARCH="$1/$3/res_vsearch_overlap"
#export VSEARCH=$(which vsearch)
export VSEARCH="/home/opt/vsearch/bin/vsearch"
export USEARCH_V10="$1/$4/usearch10.0.240_i86linux32"
export FASTTREE=$(which FastTree)
export MAFFT=$(which mafft)

## Step 2.

## This file All_16s.derep.fasta was already copied into res_vsearch at the end PART-C : 

cd $RESVSEARCH
#rm -rf Cluster_*
#rm all*
#cp $1/$3/overlap/all.dereplicated.nonsingletons.fasta .

if [ ! -e all.dereplicated.nonsingletons.fasta ]; then

	$VSEARCH --threads $THREADS \
	--derep_fulllength all.dereplicated.nonsingletons.fasta \
	--minuniquesize 2 \
	--sizein --sizeout \
	--fasta_width 0 \
	--uc all.derep.uc \
	--output all.derep.fasta
fi

echo Unique non-singleton sequences: $(grep -c "^>" all.dereplicated.nonsingletons.fasta)

echo
echo Precluster at 98% before chimera detection


if [ ! -e all.preclustered.fasta ]; then

	$VSEARCH --threads $THREADS \
	--cluster_size all.dereplicated.nonsingletons.fasta \
	--id 0.98 \
	--strand plus \
	--sizein --sizeout \
	--usersort \
	--fasta_width 0 \
	--uc all.preclustered.uc \
	--centroids all.preclustered.fasta

fi

echo Unique sequences after preclustering: $(grep -c "^>" all.preclustered.fasta)

echo
echo De novo chimera detection

if [ ! -e all.denovo.preclustered.nonchimeras.fasta ]; then

	$VSEARCH --threads $THREADS \
	--uchime_denovo all.preclustered.fasta \
	--sizein --sizeout \
	--fasta_width 0 \
	--nonchimeras all.denovo.preclustered.nonchimeras.fasta

fi

echo Unique sequences after de novo chimera detection: $(grep -c "^>" all.denovo.preclustered.nonchimeras.fasta)

echo
echo Reference chimera detection


if [ ! -e all.ref.denovo.preclustered.nonchimeras.fasta ]; then

	## with RDP use the same in taxa annotations of otus
	$VSEARCH --threads $THREADS --sizein --sizeout --uchime_ref all.denovo.preclustered.nonchimeras.fasta --db "$RDP/rdp_16s_v16_sp.fa" --fasta_width 0 --nonchimeras all.ref.denovo.preclustered.nonchimeras.fasta

	## with silva use the same in taxa annotations of otus
	#$VSEARCH --threads $THREADS --sizein --sizeout --uchime_ref all.denovo.preclustered.nonchimeras.fasta --db "$SILVA/silva.nr_v132.fasta" --fasta_width 0 \ --nonchimeras all.ref.denovo.preclustered.nonchimeras.fasta

fi

echo Unique sequences after reference-based chimera detection: $(grep -c "^>" all.ref.denovo.preclustered.nonchimeras.fasta)


if [ ! -e all.cleanned.fasta ]; then

	## It is up to the user to decontamiate OTUs : if you have a host-associated samples (for salmon ssref ; build the database ref with deconseq if the ref not there)

	if [ "$5" != "no" ]; then

		perl /home/opt/deconseq-standalone-0.4.3/deconseq.pl -dbs percafla -f all.ref.denovo.preclustered.nonchimeras.fasta -i 100 -out_dir .
		mv *clean.fa all.cleanned.fasta
	else
		mv all.no.sing.chim.derep.fasta all.cleanned.fasta 

	fi
fi

echo Sum of unique non-chimeric, non-singleton sequences in each sample: $(grep -c "^>" all.cleanned.fasta)

echo Cluster at 97% and relabel with OTU_n, generate OTU table

mkdir Cluster_fast
mkdir Cluster_size
#mkdir Cluster_unoise

cd Cluster_fast
## Make OTU table 
$VSEARCH --threads $THREADS --cluster_fast ../all.cleanned.fasta --id 0.97 --strand plus --usersort --sizein --sizeout --fasta_width 0 --uc all.clustered.id.97.uc --relabel OTU_ --centroids All_OTU_97_clean.fasta --otutabout OTU_97_table.txt
$VSEARCH --threads $THREADS --cluster_fast ../all.cleanned.fasta --id 0.99 --strand plus --usersort --sizein --sizeout --fasta_width 0 --uc all.clustered.id.99.uc --relabel OTU_ --centroids All_OTU_99_clean.fasta --otutabout OTU_99_table.txt
$VSEARCH --threads $THREADS --cluster_fast ../all.cleanned.fasta --id 0.95 --strand plus --usersort --sizein --sizeout --fasta_width 0 --uc all.clustered.id.95.uc --relabel OTU_ --centroids All_OTU_95_clean.fasta --otutabout OTU_95_table.txt
cd ../

cd Cluster_size
## Make OTU table
$VSEARCH --threads $THREADS --cluster_size ../all.cleanned.fasta --id 0.97 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.id.97.uc --relabel OTU_ --centroids All_OTU_97_clean.fasta --otutabout OTU_97_table.txt
$VSEARCH --threads $THREADS --cluster_size ../all.cleanned.fasta --id 0.99 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.id.99.uc --relabel OTU_ --centroids All_OTU_99_clean.fasta --otutabout OTU_99_table.txt
$VSEARCH --threads $THREADS --cluster_size ../all.cleanned.fasta --id 0.95 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.id.95.uc --relabel OTU_ --centroids All_OTU_95_clean.fasta --otutabout OTU_95_table.txt
cd ../

#cd Cluster_unoise
## Make OTU table
# $VSEARCH --threads $THREADS --cluster_unoise ../all.cleanned.fasta --id 0.97 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.id.97.uc --relabel OTU_ --centroids All_OTU_97_clean.fasta --otutabout OTU_97_table.txt
# $VSEARCH --threads $THREADS --cluster_unoise ../all.cleanned.fasta --id 0.99 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.id.99.uc --relabel OTU_ --centroids All_OTU_99_clean.fasta --otutabout OTU_99_table.txt
# $VSEARCH --threads $THREADS --cluster_unoise ../all.cleanned.fasta --id 0.95 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.id.95.uc --relabel OTU_ --centroids All_OTU_95_clean.fasta --otutabout OTU_95_table.txt
# cd ../
for i in $(ls -d ./Cluster_*) ;

        do

        ## go inside the subdirectory
	echo $i
        cd $i
	echo $(pwd)
	
	## Taxa assignment with RDP database

	$USEARCH_V10 -sintax All_OTU_95_clean.fasta -db $RDP/rdp_16s_v16_sp.udb -tabbedout OTU_rdp_95.sintax -strand both -sintax_cutoff 0.5
	$USEARCH_V10 -sintax All_OTU_97_clean.fasta -db $RDP/rdp_16s_v16_sp.udb -tabbedout OTU_rdp_97.sintax -strand both -sintax_cutoff 0.5
	$USEARCH_V10 -sintax All_OTU_99_clean.fasta -db $RDP/rdp_16s_v16_sp.udb -tabbedout OTU_rdp_99.sintax -strand both -sintax_cutoff 0.5
	## Taxa assignment with SILVA database


	# $USEARCH_V10 -sintax All_OTU_95_clean.fasta -db $SILVA/silva_16s_v123.udb -tabbedout OTU_silva_95.sintax -strand both -sintax_cutoff 0.5
        # $USEARCH_V10 -sintax All_OTU_97_clean.fasta -db $SILVA/silva_16s_v123.udb -tabbedout OTU_silva_97.sintax -strand both -sintax_cutoff 0.5
        # $USEARCH_V10 -sintax All_OTU_99_clean.fasta -db $SILVA/silva_16s_v123.udb -tabbedout OTU_silva_99.sintax -strand both -sintax_cutoff 0.5


	## taxa assignment with SILVA using qiime 
	
	export PATH=/home/opt/miniconda2/bin:$PATH
	source activate qiime2-2019.7
	
	cat All_OTU_95_clean.fasta | tr 'acgt' 'ACGT' > All_OTU_95_clean.fasta
	cat All_OTU_97_clean.fasta | tr 'acgt' 'ACGT' > All_OTU_97_clean.fasta
        cat All_OTU_99_clean.fasta | tr 'acgt' 'ACGT' > All_OTU_99_clean.fasta

	qiime tools import --input-path All_OTU_95_clean.fasta --output-path All_OTU_95_clean --type 'FeatureData[Sequence]'
	qiime tools import --input-path All_OTU_97_clean.fasta --output-path All_OTU_97_clean --type 'FeatureData[Sequence]'
	qiime tools import --input-path All_OTU_99_clean.fasta --output-path All_OTU_99_clean --type 'FeatureData[Sequence]'

	qiime feature-classifier classify-sklearn --p-n-jobs -1 --i-classifier $SILVA/silva-132-99-nb-classifier.qza --i-reads All_OTU_95_clean.qza --o-classification OTU_95_silva_nb_taxonomy.qza --verbose
	qiime feature-classifier classify-sklearn --p-n-jobs -1 --i-classifier $SILVA/silva-132-99-nb-classifier.qza --i-reads All_OTU_97_clean.qza --o-classification OTU_97_silva_nb_taxonomy.qza --verbose
	qiime feature-classifier classify-sklearn --p-n-jobs -1 --i-classifier $SILVA/silva-132-99-nb-classifier.qza --i-reads All_OTU_99_clean.qza --o-classification OTU_99_silva_nb_taxonomy.qza --verbose

	qiime tools export --input-path OTU_95_silva_nb_taxonomy.qza --output-path OTU_95_silva_nb_taxonomy_rep
 	qiime tools export --input-path OTU_97_silva_nb_taxonomy.qza --output-path OTU_97_silva_nb_taxonomy_rep
	qiime tools export --input-path OTU_99_silva_nb_taxonomy.qza --output-path OTU_99_silva_nb_taxonomy_rep

        qiime feature-classifier classify-consensus-blast --i-query All_OTU_95_clean.qza --i-reference-reads $SILVA/silva-99-132-ref.qza --i-reference-taxonomy $SILVA/silva_V132_taxonomy_7_levels.qza --p-evalue 0.0000001 --o-classification OTU_95_silva_blast_taxonomy.qza
 	qiime feature-classifier classify-consensus-blast --i-query All_OTU_97_clean.qza --i-reference-reads $SILVA/silva-99-132-ref.qza --i-reference-taxonomy $SILVA/silva_V132_taxonomy_7_levels.qza --p-evalue 0.0000001 --o-classification OTU_97_silva_blast_taxonomy.qza
	qiime feature-classifier classify-consensus-blast --i-query All_OTU_99_clean.qza --i-reference-reads $SILVA/silva-99-132-ref.qza --i-reference-taxonomy $SILVA/silva_V132_taxonomy_7_levels.qza --p-evalue 0.0000001 --o-classification OTU_99silva_blast_taxonomy.qza


        qiime tools export --input-path OTU_95_silva_blast_taxonomy.qza --output-path OTU_95_silva_blast_taxonomy_rep
        qiime tools export --input-path OTU_97_silva_blast_taxonomy.qza --output-path OTU_97_silva_blast_taxonomy_rep
        qiime tools export --input-path OTU_99_silva_blast_taxonomy.qza --output-path OTU_99_silva_blast_taxonomy_rep
	
	source deactivate qiime2-2019.7
	source deactivate conda

	#### Generate a biom file

	$USEARCH_V10 -otutab2biom OTU_95_table.txt -output otu_table_json_95.biom 
        $USEARCH_V10 -otutab2biom OTU_99_table.txt -output otu_table_json_99.biom
        $USEARCH_V10 -otutab2biom OTU_97_table.txt -output otu_table_json_97.biom


    	# biom convert -i  otu_table_95.biom -o  otu_table_json_95.biom --table-type="OTU table" --to-json
        # biom convert -i  otu_table_97.biom -o  otu_table_json_97.biom --table-type="OTU table" --to-json
        # biom convert -i  otu_table_99.biom -o  otu_table_json_99.biom --table-type="OTU table" --to-json
	
	#### Align all the OTU sequences together to generate a gapped FASTA file for phylogenetic tree generation

	## check the manual: https://mafft.cbrc.jp/alignment/software/manual/manual.html  

	$MAFFT --thread 12 All_OTU_95_clean.fasta  > otus_95.gfa
	$MAFFT --thread 12 All_OTU_97_clean.fasta  > otus_97.gfa
	$MAFFT --thread 12 All_OTU_99_clean.fasta  > otus_99.gfa

	## build OTU tree with usearch (usearch can build a tree but not with a huge number of sequences)
	## $USEARCH_V10 -cluster_agg All_OTU_95_clean.fasta -treeout All_OTU_95_clean.tre
	## $USEARCH_V10 -cluster_agg All_OTU_97_clean.fasta -treeout All_OTU_97_clean.tre
	## $USEARCH_V10 -cluster_agg All_OTU_99_clean.fasta -treeout All_OTU_99_clean.tre
	
	#### build  the phylogenetic tree
	$FASTTREE -nt -gtr < otus_95.gfa > otus_95.tre
        $FASTTREE -nt -gtr < otus_97.gfa > otus_97.tre
        $FASTTREE -nt -gtr < otus_99.gfa > otus_99.tre

	## At this point you have otu_table.biom, otus.tre and otu table.csv

	echo $i
	echo
	echo Number of OTUs: $(grep -c "^>" All_OTU_95_clean.fasta)
	echo
	echo Number of OTUs: $(grep -c "^>" All_OTU_97_clean.fasta)
	echo
	echo Number of OTUs: $(grep -c "^>" All_OTU_99_clean.fasta)

	cd ../

done
