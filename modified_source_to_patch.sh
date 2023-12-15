#!/bin/bash

########
# Usage: 
# ./modified_source_to_patch.sh ~/Disk/Workspaces/AOSP/LineageOS/lineage-15.1
# ./modified_source_to_patch.sh ~/Disk/Workspaces/AOSP/LineageOS/lineage-16.0
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
aosp_diff_name="${aosp_name}_git_diff"

if [ "$2" = "" ]
then
  patch_dir=${parent_dir}/CyanogenMod-cancro-modified-sources/${aosp_diff_name}
else  
  patch_dir=$2/${aosp_diff_name}
fi
mkdir -p ${patch_dir}
echo "patch directory is ${patch_dir}"


pushd $aosp_dir
repo_status=`repo status | grep project | awk '{print $2}'`
echo $repo_status


for line in $repo_status
do

	## create the .patch file using git diff
	projcet_dir=$line
	echo ""
	echo ""
	echo "************************** Handling projcet ${projcet_dir} **************************"
	pushd $projcet_dir

	projcet_name=${projcet_dir//\//_}	# / -> _
	projcet_name=${projcet_name%*_}		# delete last _

	echo $projcet_name	

	git diff > ${patch_dir}/${projcet_name}.patch

	## save status to status dir
	mkdir -p ${patch_dir}/status
	git status -s > ${patch_dir}/status/${projcet_name}.status

	## copy the modified files
	mkdir -p ${patch_dir}/sources
	modified_files=`git status -s | awk '{print $2}'`
	for file in $modified_files
	do
		file_name=${projcet_dir}${file}
		# echo $file_name

		if [ "${file_name##*.}" = "gz" ]; then
			echo "omited file -> $file_name"
			continue
		fi

		target_dir=`dirname ${patch_dir}/sources/${file_name}`
		echo "mkdir -p ${target_dir}"
		mkdir -p ${target_dir}

		echo "cp -r $file ${target_dir}/"
		cp -r $file ${target_dir}/
	done

	popd

done



popd
echo "Done"
