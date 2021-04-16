#!/bin/bash

if [ "$1" = "" ]
then
	echo -e "\033[31m 请带上需要PATCH的AOSP路径 \033[0m"
	exit 0
fi



script_path_name=$0
script_dir=$(dirname ${script_path_name})
pushd ${script_dir}





PWD=$(pwd)
aosp_dir=$1


echo -e "\033[32m Resting... \033[0m"

for file in *.patch; 
do 
	echo ${file};

	kGitPath=${file//_/\/};
	kGitPath=${kGitPath//.patch/\/};
	echo ${kGitPath}
	kAospGitPath=${aosp_dir}/${kGitPath}
	echo ${kAospGitPath}

	patch_path=${PWD}/${file}
	echo ${patch_path}

	echo "pushd ${kAospGitPath}"
	pushd ${kAospGitPath}
	echo -e "\033[31m git reset --hard HEAD \033[0m"
	git reset --hard HEAD
	echo "popd"
	popd

done



echo -e "\033[32m Patching... \033[0m"

for file in *.patch; 
do 
	echo ${file};

	kGitPath=${file//_/\/};
	kGitPath=${kGitPath//.patch/\/};
	echo ${kGitPath}
	kAospGitPath=${aosp_dir}/${kGitPath}
	echo ${kAospGitPath}

	patch_path=${PWD}/${file}
	echo ${patch_path}

	echo "pushd ${kAospGitPath}"
	pushd ${kAospGitPath}
	echo -e "\033[33m git apply ${patch_path} \033[0m"
	git apply ${patch_path}
	echo "popd"
	popd

done




echo -e "\033[32m Copying... \033[0m"

for file in ./status/*.status; 
do 

	echo ${file};

	kGitPath=$(basename ${file});

	kGitPath=${kGitPath//_/\/};
	kGitPath=${kGitPath//.status/\/};
	echo ${kGitPath}
	kAospGitPath=${aosp_dir}/${kGitPath}
	echo ${kAospGitPath}

	echo "cat ${file} | grep ??"
	kNewFiles=`cat ${file} | grep ??`
	echo "${kNewFiles}"
	array=(${kNewFiles//\?\?/ })
	for var in ${array[@]}
	do
	   echo -e "\033[45;37m ${var} \033[0m" 
	   fromPath=./sources/${kGitPath}${var}
	   toPath=${kAospGitPath}${var}

	   FINAL=${var: -1}
	   if [[ $FINAL == "/" ]]; then
	   		echo "复制目录"
	   		echo "mkdir -p ${toPath}"
	   		mkdir -p ${toPath}

	   		echo -e "\033[42;37m cp -r ${fromPath}* ${toPath} \033[0m" 
	   		cp -r ${fromPath}* ${toPath}

	   else
			echo "复制文件"
			echo -e "\033[42;37m cp -r ${fromPath} ${toPath} \033[0m" 
			cp -r ${fromPath} ${toPath}
	   fi
	   
	done 

done





popd



pushd ${aosp_dir}/bionic/
git checkout *.map
popd


echo -e "\033[32m Done \033[0m"
