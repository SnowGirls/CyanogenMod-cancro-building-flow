#!/bin/bash

r42_AOSP_PATH=/home/ubuntu/Disk6T/Workspaces/AOSP/Google/android-9.0.0_r42/
r42_PATCH_PATH=/home/ubuntu/Downloads/Works/android-9.0.0_r42_git_diff/

cp -r $r42_PATCH_PATH/external/* $r42_AOSP_PATH/external/
cp -r $r42_PATCH_PATH/frameworks/base/core/java/android/os/* $r42_AOSP_PATH/frameworks/base/core/java/android/os/
cp -r $r42_PATCH_PATH/frameworks/base/core/jni/* $r42_AOSP_PATH/frameworks/base/core/jni/

pushd $r42_PATCH_PATH

for f in *.patch
do 
	project_dir=${f/.patch/}
	project_dir=${project_dir/_/\/}
	echo '===================== git apply ${project_dir} ====================='

	full_patch_path=$r42_PATCH_PATH/$f

	pushd $r42_AOSP_PATH/$project_dir
		git reset --hard HEAD
		git apply $full_patch_path
	popd

done

echo '===================== APPLY DONE ====================='

popd



pushd $r42_AOSP_PATH

echo ''
echo '===================== REPO STATUS START ====================='

repo status

echo '===================== REPO STATUS END ====================='
echo ''

popd

