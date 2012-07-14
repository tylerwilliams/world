from tornado import ioloop
from tornado import iostream
import socket
import json
import functools
import errno
import random

ENAV_SERVER = ('localhost', 6500)
LISTENING_PORT = 5000

global stream

connections = []

last_segment = {}
msgs = [
{'action':'beat'},
{'action':'bar'},
{'action': 'flash'},
{'action':'section'},
{'action':'segment'},
]

def handle_data(data_block):
    # send segment
    return random.choice(msgs)
    # whwn to send bar, beat, flash?
    
    
def on_data(data):
    for c in connections:
        try:
            c.write(data)
        except IOError:
            connections.remove(c)
    stream.read_until('\n', on_data)

def handle_connection(connection, address):
    print 'opening new connection on %s:%s' % address

def connection_ready(sock, fd, events):
    while True:
        try:
            connection, address = sock.accept()
        except socket.error, e:
            if e.args[0] not in (errno.EWOULDBLOCK, errno.EAGAIN):
                raise
            return
        connection.setblocking(0)
        connections.append(iostream.IOStream(connection))
        handle_connection(connection, address)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
stream = iostream.IOStream(s)
stream.connect(ENAV_SERVER)
stream.read_until('\n', on_data)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.setblocking(0)
sock.bind(("", LISTENING_PORT))
sock.listen(128)

io_loop = ioloop.IOLoop.instance()
callback = functools.partial(connection_ready, sock)
io_loop.add_handler(sock.fileno(), callback, io_loop.READ)

ioloop.IOLoop.instance().start()
