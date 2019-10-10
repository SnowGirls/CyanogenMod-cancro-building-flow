#!/bin/bash

########
# Usage: ./modified_source_to_patch.sh ~/Disk/Workspaces/AOSP/LineageOS/lineage-15.1
########

# repo status | grep project 
# project build/make/                             (*** NO BRANCH ***)
# project device/oneplus/oneplus3/                (*** NO BRANCH ***)
# project frameworks/base/                        (*** NO BRANCH ***)
# project libcore/                                (*** NO BRANCH ***)

# repo status | grep project | awk '{print $2}'
# build/make/
# device/oneplus/oneplus3/
# frameworks/base/
# libcore/


pwd_dir=`pwd`
echo "pwd directory is ${pwd_dir}"
aosp_dir=$1
echo "aosp directory is ${aosp_dir}"
aosp_name=`basename $aosp_dir`
aosp_name="${aosp_name}_git_diff"
mkdir $aosp_name

pushd $aosp_dir
# repo_status=`repo status | grep project | awk '{print $2}'`
repo_status=`cat ~/Desktop/repo_status.txt`
echo $repo_status


for line in $repo_status
do

	echo "Handling projcet ${line}"
	pushd $line

	name=${line//\//_}	# / -> _
	name=${name%*_}		# delete last _

	echo $name	

	git diff > $pwd_dir/$aosp_name/$name.patch

	popd

done



popd
echo "Done"
