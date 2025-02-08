import requests
from bs4 import BeautifulSoup
import subprocess
import re
import sys
from tabulate import tabulate

def get_content_length(url):
    try:
        # 使用subprocess执行curl命令，并指定bytes输出
        result = subprocess.run(['curl', 'HEAD', '-i', url], capture_output=True)
        
        # 使用errors='ignore'来处理无法解码的字符
        headers = result.stdout.decode('utf-8', errors='ignore')
        
        # 查找Content-Length
        match = re.search(r'Content-Length: (\d+)', headers)
        if match:
            size_bytes = int(match.group(1))
            size_mb = round(size_bytes / (1024 * 1024), 2)  # 转换为MB并保留2位小数
            return size_mb
        return None
    except Exception as e:
        print(f"Error getting content length for URL: {url}")
        print(f"Error details: {e}")
        return None

def parse_html(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    media_items = soup.find_all('div', class_='media-item')
    
    # 准备表格数据
    table_data = []
    headers = ["序号", "名称", "时长", "大小(MB)", "URL"]
    
    for index, item in enumerate(media_items, 1):
        try:
            # 获取视频源URL
            source = item.find('source')
            if not source:
                continue
                
            url = source.get('src', '')
            # 替换 &amp; 为 &
            url = url.replace('&amp;', '&')
            
            # 获取视频名称
            name_div = item.find('div', class_='media-name')
            name = name_div.text if name_div else 'Unknown'
            
            # 获取视频时长
            duration_div = item.find('div', class_='media-duration')
            duration = duration_div.text if duration_div else 'Unknown'
            
            # 获取文件大小
            size_mb = get_content_length(url)
            
            # 截取URL中?之前的部分
            base_url = url.split('?')[0]
            
            # 添加到表格数据
            table_data.append([
                index,
                name,
                duration,
                size_mb if size_mb else "未知",
                base_url
            ])
            
        except Exception as e:
            print(f"Error processing item #{index}: {e}")
            continue
    
    # 打印表格
    print("\n" + tabulate(table_data, headers=headers, tablefmt="grid"))

def main():
    # 检查是否提供了文件路径参数
    if len(sys.argv) < 2:
        print("使用方法: python script.py <html文件路径>")
        print("例如: python script.py generated/videos.html")
        sys.exit(1)
        
    file_path = sys.argv[1]
    
    try:
        # 读取HTML文件内容
        with open(file_path, 'r', encoding='utf-8') as file:
            html_content = file.read()

        # 解析HTML
        parse_html(html_content)
        
    except FileNotFoundError:
        print(f"错误: 找不到文件 '{file_path}'")
        sys.exit(1)
    except Exception as e:
        print(f"错误: 读取或解析文件时出错: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()