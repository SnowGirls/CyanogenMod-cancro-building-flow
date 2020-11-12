# -*- coding: utf-8

import requests
url = 'https://api.github.com/search/repositories?q=language:python&sort=starts'
url = 'https://api.github.com/'
url = 'https://api.github.com/search/repositories?q=gemini+user:LineageOS+in:name+fork:true'
url = 'http://myip.ipip.net/'
# 解决“Max retries exceeded with url”问题
s = requests.session()

s.keep_alive = False

s.proxies = {    
"http" : "127.0.0.1:1090",
"https": "127.0.0.1:1090",
}

s.proxies = {    
"http" : "127.0.0.1:41091",
"https": "127.0.0.1:41091",
}

r = s.get(url)

print('---------------- dir ----------------')
print(dir(r))
print('\n')
print('---------------- __dict__ ----------------')
print(r.__dict__)
print('\n')

# status code 200 转态码 200表示成功
print('status code: %s, content: %s ' % (r.status_code, r.content.decode('utf-8')) )

# response_dict = r.json()


