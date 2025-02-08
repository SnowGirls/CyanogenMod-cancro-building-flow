import requests
from bs4 import BeautifulSoup
import subprocess
import re

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
            
            print(f"\n视频 #{index}:")
            print(f"名称: {name}")
            print(f"时长: {duration}")
            print(f"大小: {size_mb}MB" if size_mb else "大小: 未知")
            print(f"URL: {base_url}")
            print("-" * 80)
            
        except Exception as e:
            print(f"Error processing item #{index}: {e}")
            continue

try:
    # 读取HTML文件内容
    with open('videos.html', 'r', encoding='utf-8') as file:
        html_content = file.read()

    # 解析HTML
    parse_html(html_content)
    
except Exception as e:
    print(f"Error reading or parsing HTML file: {e}")