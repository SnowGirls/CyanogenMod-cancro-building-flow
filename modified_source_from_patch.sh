#!/bin/bash

########
# Usage: 
# ./modified_source_from_patch.sh ~/Disk/Workspaces/AOSP/LineageOS/lineage-15.1 ~/CyanogenMod-cancro-modified-sources/lineage-15.1_git_diff
# ./modified_source_from_patch.sh ~/Disk/Workspaces/AOSP/LineageOS/lineage-16.0 ~/CyanogenMod-cancro-modified-sources/lineage-16.0_git_diff
########


if [ "$1" = "" ]
then
	exit
fi

if [ "$2" = "" ]
then
	exit
fi

aosp_dir=$1
patch_dir=$2
echo "aosp directory is ${aosp_dir}"
echo "patch directory is ${aosp_dir}"

pushd ${patch_dir}/sources
echo -e "\n"

for dir in `ls ./`
do
	echo $dir
	echo "cp -r ${patch_dir}/sources/${dir} ${aosp_dir}/"
	## or using git apply __path_to_patch_file__ but need to reset first
done

echo -e "\n"
popd

echo "Done"
