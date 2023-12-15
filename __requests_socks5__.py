# -*- coding: utf-8

import socks
import socket
import requests

socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 1090)
socket.socket = socks.socksocket

url ='http://myip.ipip.net/'
r = requests.get(url)
print('status code: %s, content: %s ' % (r.status_code, r.content.decode('utf-8')) )

url = 'https://api.github.com/search/repositories?q=gemini+user:LineageOS+in:name+fork:true'
# if error occur:
# ValueError: Unable to determine SOCKS version from socks://127.0.0.1:1090/
# please issue command in terminal below: 
# unset all_proxy && unset ALL_PROXY
r = requests.get(url)
print('status code: %s, content: %s ' % (r.status_code, r.content.decode('utf-8')) )
