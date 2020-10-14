#!/bin/bash

current_path=$(pwd)
old_path=$(perl -ne 'if (/^export\sWORK\=\"(.*)\"/){print $1,"\n"; }' ../Pipelines/Prepro_Pipeline/1A_Resume_All_Stats.sh)


echo $old_path
echo $current_path

for file in $(ls ../Pipelines/*/*.sh)
	do
	echo $file	
	sed -i "s|$old_path|$current_path|" $file
	
done

