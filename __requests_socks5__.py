# -*- coding: utf-8

import socks
import socket
import requests

url ='http://myip.ipip.net/'
url = 'https://api.github.com/search/repositories?q=gemini+user:LineageOS+in:name+fork:true'

socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 1090)
socket.socket = socks.socksocket
r = requests.get(url)
print('status code: %s, content: %s ' % (r.status_code, r.content.decode('utf-8')) )
