#!/bin/bash

# ubuntu@ubuntu:~/Workspaces/AOSP/CyanogenMod/android$ repo status | grep -B 1 " -"
# project build/                                  branch development
#  -m	tools/roomservice.py
# --
# project frameworks/base/                        branch development
#  -m	api/current.txt
#  -m	core/java/android/app/ActivityThread.java
#  -m	core/java/android/app/LoadedApk.java
#  --	core/java/android/os/Hook.java
#  -m	core/java/android/os/SystemProperties.java
#  -m	core/java/android/provider/Settings.java
#  --	core/java/com/lody/legend/Hook.java
#  --	core/java/com/lody/legend/HookManager.java
#  --	core/java/com/lody/legend/Platform.java
#  --	core/java/com/lody/legend/art/ArtMethod.java
#  --	core/java/com/lody/legend/art/ArtMethodStructV19.java
#  --	core/java/com/lody/legend/art/ArtMethodStructV22.java
#  --	core/java/com/lody/legend/art/ArtMethodStructV22_64Bit.java
#  --	core/java/com/lody/legend/art/ArtMethodStructV23.java
#  --	core/java/com/lody/legend/art/ArtMethodStructV23_64Bit.java
#  --	core/java/com/lody/legend/dalvik/DalvikConstants.java
#  --	core/java/com/lody/legend/dalvik/DalvikHelper.java
#  --	core/java/com/lody/legend/dalvik/DalvikMethodStruct.java
#  --	core/java/com/lody/legend/interfaces/Restoreable.java
#  --	core/java/com/lody/legend/utility/LegendNative.java
#  --	core/java/com/lody/legend/utility/Logger.java
#  --	core/java/com/lody/legend/utility/Memory.java
#  --	core/java/com/lody/legend/utility/Runtime.java
#  --	core/java/com/lody/legend/utility/Struct.java
#  --	core/java/com/lody/legend/utility/StructMapping.java
#  --	core/java/com/lody/legend/utility/StructMember.java
#  -m	core/jni/Android.mk
#  -m	core/jni/AndroidRuntime.cpp
#  --	core/jni/legend_native.cpp
#  --	core/jni/legend_native.hpp
#  -m	preloaded-classes
#  -m	services/java/com/android/server/am/ActivityManagerService.java
# --
# project libcore/                                branch development
#  -m	dalvik/src/main/java/dalvik/system/DexFile.java



backup_dir_path="${HOME}/Workspaces/Github/CM-11-Modified-Sources"
mkdir -p ${backup_dir_path}
aosp_path="${HOME}/Workspaces/AOSP/CyanogenMod/android_cm-11.0/"



pushd $aosp_path
repo_status=`repo status | grep -B 1 " -"`
popd

# for line in $repo_status; do echo $line; done;

# project
# build/
# branch
# development
# -m
# tools/roomservice.py
# --
# project
# frameworks/base/
# branch
# development
# -m
# api/current.txt
# -m
# core/java/android/app/ActivityThread.java
# ...


isNextLineProject=0
isNextLineSourceFile=0

projectPath=""
sourceFilePath=""

for line in $repo_status
do

	if [[ $line == project* ]]; then
		isNextLineProject=1
		isNextLineSourceFile=0

	elif [[ $line == -* ]]; then
		isNextLineProject=0
		isNextLineSourceFile=1

	else

		if [[ $isNextLineProject == 1 ]]; then
			projectPath=$line
			isNextLineProject=0

			pushd $aosp_path
			pushd $projectPath

				patchName=${projectPath:0:-1}
				patchName=${patchName/\//_}.patch
				git diff > $backup_dir_path/$patchName

			popd
			popd

		elif [[ $isNextLineSourceFile == 1  ]]; then
			sourceFilePath=$line
			isNextLineSourceFile=0

			projectFilePath=${projectPath}/${sourceFilePath}
			srcProjectFilePath=${aosp_path}/${projectFilePath}

			directoryPath=`dirname ${projectFilePath}`
			destDirectoryPath=${backup_dir_path}/${directoryPath}

			mkdir -p ${destDirectoryPath}
			cp ${srcProjectFilePath} ${destDirectoryPath}

			echo "cp ${srcProjectFilePath} ${destDirectoryPath}"			
		fi

	fi


done


echo "Done"
