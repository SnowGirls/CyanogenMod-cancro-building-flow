#!/bin/bash


# Usage: ./xcode16_patch.sh $HOME/Workspaces/YOUR_FLUTTER_PROJECT/


# 丢弃多余输出
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}


# 使用for循环遍历所有参数
for arg in "$@"; do
  echo "Argument: $arg"
done


# 获取脚本及项目路径
CURRENT_DIR=$(pwd)
echo "Current directory is: $CURRENT_DIR"

SCRIPT_DIR=$(dirname $0)
echo "Script directory is: $SCRIPT_DIR"

PROJECT_DIR=$1
if [ -z $PROJECT_DIR ]; then PROJECT_DIR=$CURRENT_DIR; fi
echo "Project directory is: $PROJECT_DIR"

cd $PROJECT_DIR

if [ -e "pubspec.yaml" ]; then echo "✅ Dart/Flutter project"; else echo "Exit: not in dart/flutter project direcory."; exit 1; fi;
if [ -d "ios" ]; then echo "✅ Supported iOS platform"; else echo "Exit: not in project direcory."; exit 1; fi;


# 为 Podfile 打补丁
if grep -q "fix_clang_16_compile_include_issue" ios/Podfile ; then 
	echo "✅ Already patched podfile before"; 
else 
	echo "applying podfile patch ..."
	git apply ${SCRIPT_DIR}/xcode16_podfile_ios.patch
	result=$?
	if [ $result -ne 0 ]; then
		echo "❌ Podfile patch failed: $result"; 
	else
		echo "✅ Podfile patch success"; 
	fi
fi


# 为 inappwebview库 打补丁
pushd ios/.symlinks/plugins/flutter_inappwebview_ios/
if grep -q "#if compiler(>=6.0)" ios/Classes/InAppWebView/InAppWebView.swift ; then 
	echo "✅ Already patched inappwebview before"; 
else 
	echo "applying inappwebview patch ..."
	git apply ${SCRIPT_DIR}/xcode16_flutter_inappwebview_ios.patch
	result=$?
	if [ $result -ne 0 ]; then
		echo "❌ Inappwebview patch failed: $result"; 
	else
		echo "✅ Inappwebview patch success"; 
	fi
fi
popd
