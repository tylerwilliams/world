#!/usr/bin/env python
import sys
import json
import socket
from contextlib import closing
from pprint import pprint

if not len(sys.argv) == 2:
    print "%s HOST:PORT" % sys.argv[0]
    sys.exit(1)

server = tuple(sys.argv[1].split(":"))
server = (server[0], int(server[1]))

def linesplit(s):
    # untested
    buffer = s.recv(4096)
    done = False
    while not done:
        if "\n" in buffer:
            (line, buffer) = buffer.split("\n", 1)
            yield line+"\n"
        else:
            more = s.recv(4096)
            if not more:
                done = True
            else:
                buffer = buffer+more
    if buffer:
        yield buffer

def clean_line(line):
    return line.replace("\n", "").replace("'", '"')

with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
    s.connect(server)
    for line in linesplit(s):
        try:
            d = json.loads( clean_line(line) )
            pprint(d)
        except Exception, e:
            print e

