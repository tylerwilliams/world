import json
import socket
from contextlib import closing
from pprint import pprint

HOST = 'bigtv.local'
PORT = 6500

with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
    s.connect((HOST,PORT))
    with closing(s.makefile()) as f: #NOTE: closed independently
        for line in f:
            print line
            try:
                d = json.loads( line.strip('\n') )
                pprint(d)
            except:
                pass