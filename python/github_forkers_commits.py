# -*- coding: utf-8 -*-

import os
import re
import sys
import pdb
import time
import math
import zlib
import json
import ctypes
import pickle
import random
import urllib
import urllib2
import inspect
import datetime
import urlparse
import threading
import traceback
import multiprocessing


def main():

    try:

        link = "https://github.com/panhongwei/AndroidMethodHook/network/members"
        userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
        request = urllib2.Request(link, headers={'user-agent': userAgent})
        response = urllib2.urlopen(request)
        content = response.read()
        pattern = re.compile(r'<div class="repo">.*?<a href="(.*?)".*?</a>.*?</div>', re.S)
        
        hrefList = pattern.findall(content)

        # pdb.set_trace()

        array = []
        for href in hrefList:

            print(href)
            gitURL = "https://github.com" + href + ".git"
            print(gitURL + "\r\n")

            repoName = os.path.basename(href)
            userName = os.path.dirname(href)[1:]

            repoPath = repoName + "/" + userName;

            # os.system("git clone " + gitURL + " " + repoPath) 
            os.system("git clone -b master --single-branch " + gitURL + " " + repoPath) 

            array.append(repoPath)


            # array = ['AndroidMethodHook/panhongwei', 'AndroidMethodHook/751643992', 'AndroidMethodHook/AckywOw', 
            # 'AndroidMethodHook/AndroidHookStudio', 'AndroidMethodHook/AndSource', 'AndroidMethodHook/AnluTong', 
            # 'AndroidMethodHook/badboy3000', 'AndroidMethodHook/Burningfix', 'AndroidMethodHook/chago', 
            # 'AndroidMethodHook/chihiroim', 'AndroidMethodHook/cloudvisionx', 'AndroidMethodHook/CrackerCat', 
            # 'AndroidMethodHook/Cuiyunpeng1314', 'AndroidMethodHook/dcjniwota', 'AndroidMethodHook/diankuangliuxu', 
            # 'AndroidMethodHook/flywingsky', 'AndroidMethodHook/gitcore', 'AndroidMethodHook/gitQqqHs', 
            # 'AndroidMethodHook/Guolei1130', 'AndroidMethodHook/HiWong', 'AndroidMethodHook/jinkg', 
            # 'AndroidMethodHook/KangCaijun', 'AndroidMethodHook-1/killvxk', 'AndroidMethodHook-1/wxz1989', 
            # 'AndroidMethodHook/labdong801', 'AndroidMethodHook/Lesmm', 'AndroidMethodHook/LFYG', 
            # 'AndroidMethodHook/limpoxe', 'AndroidMethodHook/markjian', 'AndroidMethodHook/passengerxlt', 
            # 'AndroidMethodHook/RealityAbb', 'AndroidMethodHook/reinhardtken', 'AndroidMethodHook/RyanFu', 
            # 'AndroidMethodHook/shuixi2013', 'AndroidMethodHook/softer435', 'AndroidMethodHook/sshhsun-code', 
            # 'AndroidMethodHook/st-rnd', 'AndroidMethodHook/sudami', 'AndroidMethodHook/loveezu', 
            # 'AndroidMethodHook/vki', 'AndroidMethodHook/WindySha', 'AndroidMethodHook/wondertwo', 
            # 'AndroidMethodHook/xuuhaoo', 'AndroidMethodHook/xyz442', 'AndroidMethodHook/yang123vc', 
            # 'AndroidMethodHook/yunshouhu', 'AndroidMethodHook/yylyingy', 'AndroidMethodHook/ZhangLang001', 
            # 'AndroidMethodHook/zhuotong', 'AndroidMethodHook/zjw-swun', 'AndroidMethodHook/zoutaov']

        print(array)

        for repoPath in array:

            print(repoPath + "\r\n")
            os.system("cd " + repoPath + " && " + " git log --oneline --graph --abbrev-commit && cd ..")
            print("\r\n")

    except Exception as e:
	    print('%s\n' % traceback.format_exc())
	    print(e)


if __name__ == '__main__':

    main()
