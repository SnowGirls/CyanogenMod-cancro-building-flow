#!/bin/bash

backup_dir_path="${HOME}/Workspaces/Github/CM-11-Modified-Sources"
aosp_path="${HOME}/Workspaces/AOSP/CyanogenMod/android_cm-11.0/"
# aosp_path="${HOME}/Downloads/Test"


pushd $backup_dir_path

restore_files=`find . -mindepth 2 -maxdepth 100 -type f | grep -v git`

for file in $restore_files
do
	echo -e "\n"
	echo $file
	directory_path=`dirname $file`

	destination_path=$aosp_path/$directory_path

	# mkdir -p $destination_path	## Do not create directory now, we do not use legend now ...

	cp $file $destination_path

	echo "cp $file $destination_path"

done

popd

echo "Done"
