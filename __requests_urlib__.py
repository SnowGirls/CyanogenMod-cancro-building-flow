# -*- coding: utf-8

import sys

if sys.version_info[0] == 3:
  import urllib.request
  import urllib.error
else:
  import imp
  import urllib2
  urllib = imp.new_module('urllib')
  urllib.request = urllib2
  urllib.error = urllib2

# url = "127.0.0.1:41091"
# urllib.request.install_opener(urllib.request.build_opener(urllib.request.ProxyHandler({'http': url, 'https': url})))
# urllib.request.install_opener(urllib.request.build_opener(urllib.request.ProxyHandler({'socks': '127.0.0.1:1090'})))

url = 'http://myip.ipip.net/'
r = urllib.request.urlopen(url)
print('content: %s ' % ( r.readlines() ))
