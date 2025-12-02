#!/bin/bash

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
	echo -e "\033[31m 请带上需要PATCH的AOSP路径 \033[0m"
	exit 0
fi



script_path_name=$0
script_dir=$(dirname ${script_path_name})
pushd ${script_dir}





PWD=$(pwd)
aosp_dir=$1


echo -e "\033[32m Stashing... \033[0m"

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
	echo -e "\033[31m git stash \033[0m"
	git stash
	echo "popd"
	popd

done





popd


echo -e "\033[32m Done \033[0m"
