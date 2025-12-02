#!/bin/bash

# __one_key_patch__.sh [path_to_patches_dir] [path_to_aosp_dir]

echo "\$# is: $#"
echo "\$0 is: $0"

# 使用 $# 和 $i 遍历所有参数
for i in $(seq 1 $#); do
  eval arg=\$$i            # arg=$1, $2, $3 ....
  echo "\$$i is: $arg"
done

# 使用 $@ 遍历所有参数
index=1
for arg in "$@"; do
  echo "Argument $index: $arg"
  index=$((index + 1))
done



if [ "$1" = "" ]
then
	echo -e "\033[31m 请带上 git diff 输出目录路径[由 modified_source_to_patch.sh 生成] \033[0m"
	exit 0
fi

if [ "$2" = "" ]
then
	echo -e "\033[31m 请带上需要PATCH的AOSP路径 \033[0m"
	exit 0
fi



path_to_aosp_dir=$2

path_to_patches_dir=$1
pushd ${path_to_patches_dir}

PWD=$(pwd)


echo -e "\033[32m Resting... \033[0m"

for file in *.patch; 
do 
	echo ${file};

	kGitPath=${file//_/\/};
	kGitPath=${kGitPath//.patch/\/};
	echo ${kGitPath}
	kAospGitPath=${path_to_aosp_dir}/${kGitPath}
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
	kAospGitPath=${path_to_aosp_dir}/${kGitPath}
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
	kAospGitPath=${path_to_aosp_dir}/${kGitPath}
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



pushd ${path_to_aosp_dir}/bionic/
echo -e "\033[32m checkout out ing ... bionic/*.map \033[0m"
git checkout *.map
popd


echo -e "\033[32m Done \033[0m"
