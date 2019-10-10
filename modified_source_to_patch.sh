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
parent_dir=`dirname $pwd_dir`
echo "parent directory is ${parent_dir}"
aosp_dir=$1
echo "aosp directory is ${aosp_dir}"
aosp_name=`basename $aosp_dir`
aosp_name="${aosp_name}_git_diff"

patch_dir=$parent_dir/CyanogenMod-cancro-modified-sources/$aosp_name
mkdir -p $patch_dir


pushd $aosp_dir
# repo_status=`repo status | grep project | awk '{print $2}'`
repo_status=`cat ~/Desktop/repo_status.txt`
echo $repo_status


for line in $repo_status
do

	## create the .patch file using git diff
	sub_dir=$line
	echo "Handling projcet ${sub_dir}"
	pushd $sub_dir

	name=${sub_dir//\//_}	# / -> _
	name=${name%*_}		# delete last _

	echo $name	

	git diff > $patch_dir/$name.patch

	## copy the modified files
	mkdir -p $patch_dir/sources
	modified_files=`git status | grep modified | awk '{print $2}'`
	for file in $modified_files
	do
		file_name=${file//\//_}
		file_name=${file_name%*_}
		file_name=${name}_${file_name}
		echo $file_name

		cp $file $patch_dir/sources/${file_name}
	done

	popd

done



popd
echo "Done"
