#!/usr/bin/env python3
"""
解析 Gradle dependencies 输出，提取所有库及其最终版本号
"""

import re
import sys
from collections import OrderedDict

def parse_gradle_dependencies(file_path):
    """
    解析Gradle依赖文件，提取库名和最终版本号
    
    Args:
        file_path: 依赖文件路径
        
    Returns:
        tuple: (dependencies_map, library_migrations, version_changes)
            - dependencies_map: 库名 -> 最终版本号的映射
            - library_migrations: 库迁移映射 (旧库名 -> 新库名:版本)
            - version_changes: 版本变化映射 (库名 -> "旧版本 -> 新版本")
    """
    dependencies_map = {}
    library_migrations = {}  # 存储库迁移映射
    version_changes = {}     # 存储版本变化
    
    # 匹配依赖行的多种格式的正则表达式
    patterns = [
        # 格式1: +--- group:artifact:version -> group2:artifact2:final_version (*)
        re.compile(r'[+|\\]---\s+([^:\s]+:[^:\s]+):([^:\s\->]+)\s*->\s*([^:\s]+:[^:\s]+):([^:\s\(\*]+)'),
        # 格式2: +--- group:artifact:version -> final_version (*)
        re.compile(r'[+|\\]---\s+([^:\s]+:[^:\s]+):([^:\s\->]+)\s*->\s*([^:\s\(\*]+)'),
        # 格式3: +--- group:artifact:version (*)  
        re.compile(r'[+|\\]---\s+([^:\s]+:[^:\s]+):([^:\s\(\*]+)(?:\s*\(\*\))?'),
        # 格式4: +--- group:artifact:version {strictly ...}
        re.compile(r'[+|\\]---\s+([^:\s]+:[^:\s]+):([^:\s\{]+)(?:\s*\{[^}]*\})?'),
        # 格式5: +--- :artifact-version (local artifacts)
        re.compile(r'[+|\\]---\s+:([^:\s]+)-([^:\s\->]+)'),
    ]
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                
                # 跳过空行和非依赖行
                if not line or not any(marker in line for marker in ['+---', '\\---']):
                    continue
                
                # 尝试各种格式的正则表达式
                matched = False
                
                # 格式1: 库迁移映射 (group:artifact:version -> group2:artifact2:final_version)
                match = patterns[0].search(line)
                if match:
                    original_group_artifact = match.group(1)
                    original_version = match.group(2)
                    target_group_artifact = match.group(3)
                    final_version = match.group(4).strip()
                    
                    # 存储库迁移映射（包含原始版本号）
                    original_full = f"{original_group_artifact}:{original_version}"
                    target_full = f"{target_group_artifact}:{final_version}"
                    library_migrations[original_full] = target_full
                    
                    # 同时在主映射表中存储目标库
                    dependencies_map[target_group_artifact] = final_version
                    matched = True
                    continue
                
                # 格式2: 版本变更 (group:artifact:old_version -> new_version)
                match = patterns[1].search(line)
                if match:
                    group_artifact = match.group(1)
                    original_version = match.group(2)
                    final_version = match.group(3).strip()
                    
                    # 检查是否只是版本变更（同一个库）
                    if original_version != final_version:
                        version_changes[group_artifact] = f"{original_version} -> {final_version}"
                        dependencies_map[group_artifact] = final_version
                    else:
                        dependencies_map[group_artifact] = final_version
                    matched = True
                    continue
                
                # 格式3和4: 直接版本号（无变更）
                for pattern in patterns[2:4]:
                    match = pattern.search(line)
                    if match:
                        group_artifact = match.group(1)
                        version = match.group(2).strip()
                        # 清理版本号
                        version = re.sub(r'\s*\([^)]*\).*$', '', version)
                        version = re.sub(r'\s*\{[^}]*\}.*$', '', version)
                        version = version.strip()
                        if version:  # 只有版本号不为空才添加
                            dependencies_map[group_artifact] = version
                        matched = True
                        break
                
                # 格式5: 本地artifacts (如 :lib_wwapi-2.0.12.11)
                if not matched:
                    match = patterns[4].search(line)
                    if match:
                        artifact = match.group(1)
                        version = match.group(2).strip()
                        # 对于本地artifacts，使用特殊格式
                        group_artifact = f"local:{artifact}"
                        dependencies_map[group_artifact] = version
                        matched = True
                        
    except FileNotFoundError:
        print(f"错误: 文件 '{file_path}' 不存在")
        return {}, {}, {}
    except Exception as e:
        print(f"错误: 读取文件时发生异常: {e}")
        return {}, {}, {}
    
    return dependencies_map, library_migrations, version_changes

def compare_versions(version1, version2):
    """
    简单的版本比较函数
    
    Returns:
        1 if version1 > version2
        -1 if version1 < version2  
        0 if version1 == version2
    """
    def normalize_version(v):
        # 将版本号转换为数字列表进行比较
        parts = re.split(r'[.-]', str(v))
        normalized = []
        for part in parts:
            if part.isdigit():
                normalized.append(int(part))
            else:
                # 对于非数字部分，使用ASCII值
                normalized.append(ord(part[0]) if part else 0)
        return normalized
    
    v1_parts = normalize_version(version1)
    v2_parts = normalize_version(version2)
    
    # 补齐长度
    max_len = max(len(v1_parts), len(v2_parts))
    v1_parts.extend([0] * (max_len - len(v1_parts)))
    v2_parts.extend([0] * (max_len - len(v2_parts)))
    
    for a, b in zip(v1_parts, v2_parts):
        if a > b:
            return 1
        elif a < b:
            return -1
    
    return 0

def print_dependencies_map(dependencies_map, library_migrations, version_changes):
    """
    按库名排序打印依赖映射
    
    Args:
        dependencies_map: 库名 -> 版本号的映射
        library_migrations: 库迁移映射
        version_changes: 版本变化映射
    """
    if not dependencies_map and not library_migrations and not version_changes:
        print("没有找到任何依赖项")
        return
    
    print(f"共找到 {len(dependencies_map)} 个依赖库:\n")
    
    # 1. 打印无变更的依赖项
    print("=" * 80)
    print("无变更的依赖库:")
    print("=" * 80)
    print(f"{'库名':<50} {'版本号':<20}")
    print("=" * 80)
    
    # 获取无变更的依赖项（排除有版本变更和库迁移的）
    unchanged_deps = {}
    # 从库迁移映射中提取目标库名（不包含版本号）
    migrated_target_libs = set()
    for target_full in library_migrations.values():
        target_lib = ':'.join(target_full.split(':')[0:2])  # 提取 group:artifact 部分
        migrated_target_libs.add(target_lib)
    
    for lib, version in dependencies_map.items():
        if lib not in version_changes and lib not in migrated_target_libs:
            unchanged_deps[lib] = version
    
    sorted_unchanged = OrderedDict(sorted(unchanged_deps.items()))
    for library, version in sorted_unchanged.items():
        print(f"{library:<50} {version:<20}")
    
    print(f"\n小计: {len(unchanged_deps)} 个无变更依赖库\n")
    
    # 2. 打印版本变更的依赖项
    if version_changes:
        print("=" * 80)
        print("版本变更的依赖库:")
        print("=" * 80)
        print(f"{'库名':<50} {'版本变化':<30}")
        print("=" * 80)
        
        sorted_version_changes = OrderedDict(sorted(version_changes.items()))
        for library, change in sorted_version_changes.items():
            print(f"{library:<50} {change:<30}")
        
        print(f"\n小计: {len(version_changes)} 个版本变更依赖库\n")
    
    # 3. 打印库迁移映射
    if library_migrations:
        print("=" * 80)
        print("库迁移映射:")
        print("=" * 80)
        print(f"{'原库名:版本':<60} {'迁移到库名:版本':<50}")
        print("=" * 80)
        
        sorted_migrations = OrderedDict(sorted(library_migrations.items()))
        for old_library_full, new_library_full in sorted_migrations.items():
            print(f"{old_library_full:<60} {new_library_full:<50}")
        
        print(f"\n小计: {len(library_migrations)} 个库迁移映射\n")
    
    print("=" * 80)
    print(f"总计: {len(dependencies_map)} 个最终依赖库")
    print(f"其中: {len(unchanged_deps)} 个无变更, {len(version_changes)} 个版本变更, {len(library_migrations)} 个库迁移")
    print("=" * 80)
    
    # 4. 总汇总输出 - 所有最终依赖库及其最终版本号
    print("\n" + "=" * 80)
    print("总汇总 - 所有最终依赖库及其版本:")
    print("=" * 80)
    print(f"{'库名':<50} {'最终版本号':<20}")
    print("=" * 80)
    
    # 合并所有最终依赖库
    all_final_dependencies = {}
    
    # 1. 添加无变更的依赖库
    all_final_dependencies.update(unchanged_deps)
    
    # 2. 添加版本变更的依赖库（只保留最终版本号）
    for lib in version_changes:
        if lib in dependencies_map:
            all_final_dependencies[lib] = dependencies_map[lib]
    
    # 3. 添加库迁移后的最终库
    for target_full in library_migrations.values():
        target_lib = ':'.join(target_full.split(':')[0:2])  # 提取 group:artifact
        target_version = target_full.split(':')[2]  # 提取版本号
        all_final_dependencies[target_lib] = target_version
    
    # 按库名排序并输出
    sorted_all_final = OrderedDict(sorted(all_final_dependencies.items()))
    try:
        for library, version in sorted_all_final.items():
            print(f"{library:<50} {version:<20}")
        
        print("=" * 80)
        print(f"总汇总计: {len(all_final_dependencies)} 个最终依赖库")
        print("=" * 80)
    except BrokenPipeError:
        # 当使用管道命令(如 head, tail)时，管道可能提前关闭
        import sys
        sys.exit(0)

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("用法: python3 parse_dependencies.py <gradle_dependencies_file>")
        print("示例: python3 parse_dependencies.py 20251030_DEPS_38856408417c2daf3674af6a9e694590dc1d4174.txt")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    try:
        print(f"正在解析文件: {file_path}")
        print("-" * 50)
        
        dependencies_map, library_migrations, version_changes = parse_gradle_dependencies(file_path)
        print_dependencies_map(dependencies_map, library_migrations, version_changes)
    except BrokenPipeError:
        # 当使用管道命令(如 head, tail)时，管道可能提前关闭
        sys.exit(0)

if __name__ == "__main__":
    main()