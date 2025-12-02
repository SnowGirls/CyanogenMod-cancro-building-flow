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
BRIEF=${1:-"BEE"}
GIT_REF_START=${2:-"master"}
GIT_REF_OVER=${3:-"develop"}
BASE_DIR=${4:-"${HOME}/Downloads/"}
PROJ_DIR=${5:-"./"}

pushd ${PROJ_DIR}


# Function to generate output file name based on brief and git reference
file_name_of_dependencies_output() {
    local brief="$1"
    local ref="$2"
    TODAY=$(date +"%Y%m%d%M")
    echo "${BASE_DIR}/${TODAY}_${brief}_${ref}.txt"
}

OUTPUT_FILE_START=$(file_name_of_dependencies_output "${BRIEF}_start" "${GIT_REF_START}")
OUTPUT_FILE_OVER=$(file_name_of_dependencies_output "${BRIEF}_over" "${GIT_REF_OVER}")
echo -e "Fetching dependencies to files: \n${OUTPUT_FILE_START} \n${OUTPUT_FILE_OVER}"


check_gradlew_if_exists_or_not() {
    if [ ! -f "./gradlew" ]; then
        echo "🚫 Error: ./gradlew not found in the current directory."
        exit 1
    fi
    # Try to restore gradlew from gradle wrapper properties
    if [ ! -f "./gradlew" ]; then
        echo "./gradlew not found in the current directory."
        # Read the file gradle/wrapper/gradle-wrapper.properties to get the distributionUrl
        if [ -f "./gradle/wrapper/gradle-wrapper.properties" ]; then
            distribution_url=$(grep 'distributionUrl' ./gradle/wrapper/gradle-wrapper.properties | cut -d'=' -f2)
            # Replace all \ with nothing
            distribution_url=${distribution_url//\\/}
            echo "Gradle wrapper properties found. You can download Gradle from the following URL:"
            echo "🔗🔗🔗 ${distribution_url}\n"
            # Then read the version from the URL
            gradle_version=$(basename ${distribution_url} ".zip")
            echo "Detected Gradle version: ${gradle_version}"
            user_cached_gradle_dir="${HOME}/.gradle/wrapper/dists/${gradle_version}"
            if [ -d "${user_cached_gradle_dir}" ]; then
                echo "Gradle version ${gradle_version} is already cached at: ${user_cached_gradle_dir}"
                # Find the directory bin/ and the executable file gradle in this bin/ directory
                gradle_bin_dir=$(find "${user_cached_gradle_dir}" -type d -name "bin")
                gradle_executable_file="${gradle_bin_dir}/gradle"
                if [ -f "${gradle_executable_file}" ]; then
                    echo "Gradle wrapper binary file found at: ${gradle_executable_file}"
                else
                    echo "Error: Gradle wrapper binary file not found."
                    exit 1
                fi
                echo "Copying Gradle wrapper binary file to current directory..."
                cp "${gradle_executable_file}" ./gradlew
                echo "✅ Gradle wrapper binary file copied."
            else
                echo "⚠️ Gradle version ${gradle_version} is not cached. You may need to download it manually."
                # Get the system temporary directory
                TEMP_DIR="${TMPDIR:-/tmp}"
                echo "Using temporary directory: ${TEMP_DIR}"
                # Download Gradle from the distribution URL
                zip_file_path="${TEMP_DIR}/${gradle_version}.zip"
                unzip_file_path="${TEMP_DIR}/${gradle_version}-unzip/"
                echo "Downloading Gradle from 【${distribution_url}】..."
                echo -e "Saving to \n🔗🔗🔗 ${zip_file_path}\n \nUnzipping to \n🔗🔗🔗 ${unzip_file_path}\n"
                wget -O "${zip_file_path}" "${distribution_url}"
                unzip "${zip_file_path}" -d "${unzip_file_path}"
                # Copy the gradle binary to current directory's directory
                gradle_bin_dir=$(find "${unzip_file_path}" -type d -name "bin")
                gradle_executable_file="${gradle_bin_dir}/gradle"
                echo "Copying ${gradle_executable_file} to current directory..."
                cp "${gradle_executable_file}" ./gradlew
                echo "✅ Gradle wrapper binary file downloaded and copied to current directory."
                exit 1
            fi
        else
            echo "🚫 Error: gradle/wrapper/gradle-wrapper.properties not found."
            exit 1
        fi
    fi
}


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


# Function to checkout a specific git reference and fetch dependencies
git_checkout_and_gradle_dependencies() {
    local ref="$1"
    local file="$2"
    local flag_all="$3"
    git checkout ${ref}; flutter pub get; pushd android/; gradle_flush_specific_dependencies "${file}" "${flag_all}" ; popd
}


git_checkout_and_gradle_dependencies "${GIT_REF_START}" "${OUTPUT_FILE_START}" --all
git_checkout_and_gradle_dependencies "${GIT_REF_OVER}" "${OUTPUT_FILE_OVER}" --all
# code --diff ${OUTPUT_FILE_START} ${OUTPUT_FILE_OVER}


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
        sed -n "/${section}/,/^$/p" "${in_file}" >> "${out_file}"
    done
}
filter_the_sections "${OUTPUT_FILE_START}" "${OUTPUT_FILE_START}_filters.txt"
filter_the_sections "${OUTPUT_FILE_OVER}" "${OUTPUT_FILE_OVER}_filters.txt"
code --diff ${OUTPUT_FILE_START}_filters.txt ${OUTPUT_FILE_OVER}_filters.txt


popd



: <<'COMMENT'
# developmentDebugCompileClasspath
# developmentDebugImplementationDependenciesMetadata
# developmentDebugRuntimeClasspath

# productionReleaseCompileClasspath
# productionReleaseImplementationDependenciesMetadata
# productionReleaseRuntimeClasspath


# i.e.
dependencies {
    api 'com.google.gson:gson:2.10.1'           // 三者都包含
    implementation 'androidx.core:core:1.10.1'  // 只在Runtime中
    compileOnly 'javax.annotation:jsr250-api'   // 只在Compile中  
    runtimeOnly 'mysql:mysql-connector-java'    // 只在Runtime中
}


# 方法一：指定具体配置

# 只输出 CompileClasspath
./gradlew :app:dependencies --configuration productionReleaseCompileClasspath

# 只输出 DependenciesMetadata  
./gradlew :app:dependencies --configuration productionReleaseApiDependenciesMetadata

# 只输出 RuntimeClasspath
./gradlew :app:dependencies --configuration productionReleaseRuntimeClasspath


# 方法二：输出到文件并过滤

# 输出所有依赖到文件，然后过滤特定配置
./gradlew :app:dependencies > dependencies.txt

# 提取特定配置段落
sed -n '/productionReleaseCompileClasspath/,/^$/p' dependencies.txt
sed -n '/productionReleaseRuntimeClasspath/,/^$/p' dependencies.txt  
sed -n '/productionReleaseApiDependenciesMetadata/,/^$/p' dependencies.txt
COMMENT
