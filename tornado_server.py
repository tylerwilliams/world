from tornado import ioloop
from tornado import iostream
import socket
import json
import functools
import errno

HOST = 'bigtv.local'
PORT = 6500

global stream

connections = []

def on_data(data):
    #j = json.loads(data)
    j = data
    print data
    for c in connections:
        c.write(json.dumps(j))
    stream.read_until('\n', on_data)

def handle_connection(connection, address):
    print 'got a connection'

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
        #handle_connection(connection, address)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
stream = iostream.IOStream(s)
stream.connect((HOST, PORT))
stream.read_until('\n', on_data)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.setblocking(0)
sock.bind(("", 5000))
sock.listen(128)

io_loop = ioloop.IOLoop.instance()
callback = functools.partial(connection_ready, sock)
io_loop.add_handler(sock.fileno(), callback, io_loop.READ)

ioloop.IOLoop.instance().start()
