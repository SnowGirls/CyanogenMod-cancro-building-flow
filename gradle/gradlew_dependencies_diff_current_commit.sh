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



# Default values
BRIEF=${1:-"DEPS"}
BASE_DIR=${2:-"${HOME}/Downloads/"}
PROJ_DIR=${3:-"./"}


GIT_REF_CURRENT=$(git rev-parse HEAD)
GIT_NAME_CURRENT=$(git rev-parse --abbrev-ref HEAD)


pushd ${PROJ_DIR}
echo -e "\n"


# Function to generate output file name based on brief and git reference
file_name_of_dependencies_output() {
    local ref="$1"
    TODAY=$(date +"%Y%m%d")
    echo "${BASE_DIR}/${TODAY}_${BRIEF}_${ref}.txt"
}

file_name_of_dependencies_output_filtered() {
    local output_file="$1"
    echo "${output_file%\.*}_filters.txt"
}

OUTPUT_FILE_CURRENT=$(file_name_of_dependencies_output "${GIT_REF_CURRENT}")
echo -e "🥎 Writing dependencies to file: \n${OUTPUT_FILE_CURRENT}\n"


# Function to fetch dependencies for specified configurations
gradle_flush_specific_dependencies() {
    local output_file="$1"

    if [ "$#" -eq 2 ] && [ "$2" == "--all" ]; then
        ./gradlew :app:dependencies > "$output_file"
        return
    fi
    
    # Define configurations to fetch
    local configurations=(
        "productionReleaseCompileClasspath"
        "productionReleaseRuntimeClasspath" 
        "productionReleaseApiDependenciesMetadata"
    )
    
    # Fetch dependencies for each configuration
    for config in "${configurations[@]}"; do
        ./gradlew :app:dependencies --configuration $config >> "$output_file"
    done
}

pushd android/

echo -e "\n"
echo -n "Gradle dependencies running... "
start_time=$(date +%s)

# 启动后台进程显示经过的时间
{
    while true; do
        sleep 1
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        printf "\rGradle dependencies running... ${elapsed}s"
    done
    printf "\n"
} &
timer_pid=$!
printf "\rGradle dependencies timer pid is: ${timer_pid}\n"

gradle_flush_specific_dependencies "${OUTPUT_FILE_CURRENT}" --all 

# 停止计时器
kill $timer_pid >/dev/null 2>&1
current_time=$(date +%s)
elapsed=$((current_time - start_time))
printf "\rGradle dependencies completed in ${elapsed}s\n"

popd


# Function to filter sections from the output files
filter_the_sections() {
    local in_file="$1"
    local out_file="$2"
    local sections=(
        "productionReleaseCompileClasspath"
        "productionReleaseRuntimeClasspath" 
        "productionReleaseApiDependenciesMetadata"
    )
    for section in "${sections[@]}"; do
        echo -e "\n\n${section}=============== START ================\n" >> "${out_file}"
        sed -n "/${section}/,/^$/p" "${in_file}" >> "${out_file}"
        echo -e "\n\n${section}=============== OVER ================\n" >> "${out_file}"
    done
}

OUTPUT_FILTER_FILE_CURRENT=$(file_name_of_dependencies_output_filtered "${OUTPUT_FILE_CURRENT}")
filter_the_sections "${OUTPUT_FILE_CURRENT}" "${OUTPUT_FILTER_FILE_CURRENT}"
echo -e "🥎 Writed filters to file: \n${OUTPUT_FILTER_FILE_CURRENT}\n"


recent_release_branches=$(git for-each-ref --sort=-committerdate refs/remotes/origin/release | head -n 5)
# i.e:
# 327862318a8bbc13a0502726989a7f7e4f24f8ad commit	refs/remotes/origin/release/3.63.0
# fa8d3530da20e075bd4e9071422040eeede10d30 commit	refs/remotes/origin/release/3.62.0
# 38856408417c2daf3674af6a9e694590dc1d4174 commit	refs/remotes/origin/release/3.59.0
# ...
recent_release_refs=$(echo "$recent_release_branches" | awk '{print $1}')
echo "$recent_release_refs" | while read -r ref; do
    echo -e "\n"
    RELEASE_BRANCH=$(git branch -a --sort=-committerdate --contains $ref | grep origin/release/ | head -1)
    RELEASE_BRANCH=${RELEASE_BRANCH//' '/}
    RELEASE_BRANCH=${RELEASE_BRANCH//'remotes/'/}
    echo "Processing release ref: $ref, its branch name is: $RELEASE_BRANCH"

    # 判断 ref 是否相等 GIT_REF_CURRENT 
    if [ "$ref" == "$GIT_REF_CURRENT" ]; then
        echo "Skip release ref: ${ref}, it is equal to current commit."
        continue
    fi

    # 判断 ref 时间是否早于 GIT_REF_CURRENT 的
    if [ "$(git log -1 --format=%ct ${ref})" -gt "$(git log -1 --format=%ct ${GIT_REF_CURRENT})" ]; then
        echo "Skip release ref: ${ref}, its time is later than current commit."
        continue
    fi

    RELEASE_DEPS_FILE=$(file_name_of_dependencies_output "${ref}")
    RELEASE_DEPS_FILTER_FILE=$(file_name_of_dependencies_output_filtered "${RELEASE_DEPS_FILE}")

    if [ -f "${RELEASE_DEPS_FILE}" ] && [ -f "${RELEASE_DEPS_FILTER_FILE}" ]; then
        echo "Dependencies file and its filter file exists: ${RELEASE_DEPS_FILE}"
        diff_result_file_name=${RELEASE_BRANCH//\//_}-${GIT_NAME_CURRENT//\//_}_diff.txt
        diff_result_file="${BASE_DIR}/${diff_result_file_name}"
        now_diff_result=$(git --no-pager diff -U0 "${RELEASE_DEPS_FILTER_FILE}" "${OUTPUT_FILTER_FILE_CURRENT}")
        # 如果 diff_result_file 存在在，则对比内容是否有变化
        if [ -f "${diff_result_file}" ]; then
            echo "Previous diff exists: ${diff_result_file}"
            previous_diff_result=$(cat "${diff_result_file}")
            if [ "$now_diff_result" == "$previous_diff_result" ]; then
                echo "✅ No changes in dependencies diff compared to previous run for ${RELEASE_BRANCH}."
                break
            fi
            cp "${diff_result_file}" "${diff_result_file%.txt}_previous.txt"
        fi
        # 再在标准输出中显示 diff 结果
        echo -e "\n========================================================================="
        git --no-pager diff -U0 "${RELEASE_DEPS_FILTER_FILE}" "${OUTPUT_FILTER_FILE_CURRENT}"
        echo -e "=========================================================================\n"
        echo "$now_diff_result" > "${diff_result_file}"
        echo "✅ Dependencies diff saved to file: ${diff_result_file}"
        break
    fi
done

echo -e "\n"


popd

