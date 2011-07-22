import socket

HOST = 'bigtv.local'
PORT = 6500

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((HOST,PORT))
while 1:
    data = client_socket.recv(4096)
    print "RECIEVED:" , data
