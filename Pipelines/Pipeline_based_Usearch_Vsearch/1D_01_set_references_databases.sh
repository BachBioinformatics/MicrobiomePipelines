#!/bin/bash

if [ $# -le 1 ]
  then
    echo "No argument supplied .... please add:"
    echo "1)The absolute Path where you want to download you refrence databases"
    echo "2)The absolute Path to software usearch version 9 and 10"
    exit 
fi


export WORK=$1

## set the number of core to use on your machine

THREADS="12"

## set paths

export WORK=$1
export USEARCH_V9="$1/$2/usearch9.2.64_i86linux32"
export USEARCH_V10="$1/$2/usearch10.0.240_i86linux32"
#export VSEARCH=$(which vsearch)
export VSEARCH="/home/opt/vsearch/bin/vsearch"


cd $WORK

mkdir References_database

cd References_database

mkdir silva

export SILVA=$WORK"/References_database/silva"


cd silva

echo "Get silva ref with qiime2 format version of april 2019"

echo "18s and 16s with qiime2 classifiers"

echo "Obtaining Gold reference database for chimera detection or taxonomy classification"


if [ ! -e silva-132-99-nb-classifier.qza ]; then

        echo "getting qiime2 classifier..."
        wget https://data.qiime2.org/2019.4/common/silva-132-99-nb-classifier.qza
fi

if [ ! -e silva-132-99-515-806-nb-classifier.qza ]; then

        echo "getting qiime2 classifier..."
	wget https://data.qiime2.org/2019.4/common/silva-132-99-515-806-nb-classifier.qza

fi


if [ ! -e Silva_132_release.zip ]; then
        
	echo "Decompressing and reformatting..."
	wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip
	unzip Silva_132_release.zip
fi


if [ ! -e silva-99-132-ref.qza ]; then

        echo "build ref taxanomy qiime 2"
	export PATH=/home/opt/miniconda2/bin:$PATH
	source activate qiime2-2019.7
	echo $(pwd)
        #qiime tools import --type 'FeatureData[Taxonomy]' --input-path SILVA_132_QIIME_release/taxonomy/taxonomy_all/99/taxonomy_7_levels.txt --output-path silva_V132_taxonomy_7_levels.qza --input-format HeaderlessTSVTaxonomyFormat
	qiime tools import --type 'FeatureData[Sequence]' --input-path "SILVA_132_QIIME_release/rep_set/rep_set_all/99/silva132_99.fna" --output-path "silva-99-132-ref.qza"

	conda deactivate qiime2-2019.7
fi


if [ ! -e silva.nr_v138.udb ]; then
	if [ ! -e Silva.nr_v138.tgz ]; then
		wget https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.nr_v138.tgz
	fi
	echo "Decompressing and reformatting..."
    	tar -xzvf Silva.nr_v138.tgz
        sed -e "s/[.-]//g" silva.nr_v138.align > silva.nr_v138.fasta
	$VSEARCH -makeudb_usearch $SILVA/silva.nr_v138.fasta -output $SILVA/silva.nr_v138.udb
fi

if [ ! -e silva.nr_v132.udb ]; then
        if [ ! -e silva.nr_v132.tgz ]; then
        	wget https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.nr_v132.tgz        
        fi
        echo "Decompressing and reformatting..."
        tar -zxvf silva.nr_v132.tgz
        sed -e "s/[.-]//g" silva.nr_v132.align > silva.nr_v132.fasta
        $VSEARCH -makeudb_usearch $SILVA/silva.nr_v132.fasta -output $SILVA/silva.nr_v132.udb
fi

if [ ! -e silva_16s_v123.fa ]; then
	if [ ! -e silva_16s_v123.fa.gz ] ; then
                wget https://drive5.com/sintax/silva_16s_v123.fa.gz
        
	fi
        echo "Decompressing and reformatting..."
	gunzip silva_16s_v123.fa.gz
fi

if [ ! -e ltp_16s_v123.udb ]; then
	if [ ! -e ltp_16s_v123.fa.gz ]; then
		
		wget https://drive5.com/sintax/ltp_16s_v123.fa.gz
		gunzip ltp_16s_v123.fa.gz
		$VSEARCH -makeudb_usearch $SILVA/ltp_16s_v123.fa -output $SILVA/ltp_16s_v123.udb

        fi
	
	echo "Decompressing and reformatting..."
        gunzip ltp_16s_v123.fa.gz
	$USEARCH -makeudb_usearch $SILVA/silva_16s_v123.fa -output $SILVA/silva_16s_v123.udb



fi



cd ../


echo "Obtaining RDP reference database for chimera detection or taxonomy classification"

mkdir rdp
cd rdp

echo "Obtaining Gold reference database for chimera detection or taxonomy assignment"
## search rdp databases files : http://drive5.com/usearch/manual/utax_downloads.html ; then http://drive5.com/utax/data/utax_rdp_16s_tainset15.tar.gz

if [ ! -e rdp_v16 ]; then
	if [ ! -e rdp_v16.tar.gz ]; then
        	wget http://drive5.com/utax/data/rdp_v16.tar.gz
	fi
	echo "Decompressing and reformatting..."
	tar -zxvf rdp_v16.tar.gz
fi


if [ ! -e utax_rdp_16s_tainset15.tar.gz ]; then
        wget http://drive5.com/utax/data/utax_rdp_16s_tainset15.tar.gz
	echo "Decompressing and reformatting..."
	tar -zxvf utax_rdp_16s_tainset15.tar.gz
fi

# for more informations please see this link : http://drive5.com/usearch/manual/utax_16s.html

export RDP=$WORK/References_database/rdp

## rebuild a rdp database with UTAX
# $USEARCH_V9 -makeudb_utax $RDP/rdp_v16.fa -output $RDP/rdp_v16.udb -taxconfsin $RDP/utaxref/rdp_16s_trainset15/taxconfs/full_length.tc -report $RDP/16s_report_v16.txt

## for sintax method 

if [ ! -e rdp_16s_v16.fa ]; then
        wget https://drive5.com/sintax/rdp_16s_v16.fa.gz
        echo "Decompressing and reformatting..."
        gunzip rdp_16s_v16.fa.gz
	$USEARCH_V10 -makeudb_sintax $RDP/rdp_16s_v16.fa -output $RDP/rdp_16s_v16.udb

fi

## got  RDP training set with species names with species level

if [ ! -e rdp_16s_v16_sp.fa ]; then
        wget https://drive5.com/sintax/rdp_16s_v16_sp.fa.gz
        echo "Decompressing and reformatting..."
        gunzip rdp_16s_v16_sp.fa.gz
	$USEARCH_V10 -makeudb_sintax $RDP/rdp_16s_v16_sp.fa -output $RDP/rdp_16s_v16_sp.udb
fi

cd ../

mkdir gg
export GG=$WORK"/References_database/gg"
cd $GG

if [ ! -e gg_16s_13.5.fa ]; then
        wget https://drive5.com/sintax/gg_16s_13.5.fa.gz
        echo "Decompressing and reformatting..."
        gunzip gg_16s_13.5.fa.gz
fi

cd ../
mkdir its
export ITS=$WORK"/References_database/its"
cd $ITS

if [ ! -e utax_reference_dataset_22.08.2016.zip ]; then
        wget https://unite.ut.ee/sh_files/utax_reference_dataset_22.08.2016.zip
        echo "Decompressing and reformatting..."
        unzip utax_reference_dataset_22.08.2016.zip
fi

if [ ! -e rdp_its_v2.fa ]; then
        wget https://drive5.com/sintax/rdp_its_v2.fa.gz
        echo "Decompressing and reformatting..."
        gunzip rdp_its_v2.fa.gz
fi

cd ../

