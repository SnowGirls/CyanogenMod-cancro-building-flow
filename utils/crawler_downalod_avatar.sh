#!/bin/bash

for f in *; do echo mv "$f" "$(openssl rand -hex 17).jpg"; done;
for f in *; do echo mv "${${${f//\(/\\(}//\)/\\)}//\ /\\ }" "$(openssl rand -hex 17).jpg"; done;
for f in *; do echo mv "${${${f//\(/\\(}//\)/\\)}//\ /\\ }" "$(openssl rand -hex 16).jpeg"; done;


for ((i = 0; i <= 320; ++i)) do curl http://www.qqw21.com/nvshengtouxiang/index-$i.html | grep jpeg | xargs -I{} echo {} | awk  '{print $4}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;
for ((i = 0; i <= 320; ++i)) do curl http://www.qqw21.com/qinglvtouxiang/index-$i.html | grep jpeg | xargs -I{} echo {} | awk  '{print $4}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;


i=1
curl -s  https://www.qqtn.com/tx/nvshengtx_$i.html | iconv -f GB2312 -t UTF-8 | grep jpg  | awk '{print $6}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}

for ((i = 1; i <= 300; ++i)) do curl -s  https://www.qqtn.com/tx/nvshengtx_$i.html | iconv -f GB2312 -t UTF-8 | grep jpg  | awk '{print $6}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;
for ((i = 1; i <= 300; ++i)) do curl -s  https://www.qqtn.com/tx/qinglvtx_$i.html | iconv -f GB2312 -t UTF-8 | grep jpg  | awk '{print $6}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;
for ((i = 1; i <= 200; ++i)) do curl -s  https://www.qqtn.com/tx/weimeitx_$i.html | iconv -f GB2312 -t UTF-8 | grep jpg  | awk '{print $6}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;
for ((i = 1; i <= 50; ++i)) do curl -s  https://www.qqtn.com/tx/wanghongtx_$i.html | iconv -f GB2312 -t UTF-8 | grep jpg  | awk '{print $6}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;


for ((i = 1; i <= 144; ++i)) do curl http://www.crcz.com/touxiang/nv/list_$i.html | grep jpg | awk '{print $5}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;
for ((i = 1; i <= 144; ++i)) do curl http://www.crcz.com/touxiang/nv/hot_$i.html | grep jpg | awk '{print $5}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;
for ((i = 1; i <= 6; ++i))  do curl http://www.crcz.com/touxiang/nv/yujie/list_$i.html | grep jpg | awk '{print $5}' | awk -F "=" '{print $2}' | xargs -I{} curl -O {}; done;