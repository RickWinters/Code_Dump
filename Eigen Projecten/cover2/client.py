import socket
import time
import threading

def tostr(data):
    data = str(data)
    data = data[2:]
    data = data[:-1]

    return data

def chatloop(socket):
    while True:
        while True:
            data = tostr(sock.recv(512))
            if data == 'ok':
                sock.sendall(bytes('ok', 'utf-8'))
                break
            else:
                data = data
                sock.sendall(bytes(data, 'utf-8'))
                data1 = data
        if data1 == 'stop':
            time.sleep(0.05)
            socket.sendall(bytes('stop received','utf-8'))
            break
        if data1 != '':
            if data1[0:9] == 'request: ':
                data1 = data1[9:]
                answer = input(data1 + ' :')
                socket.sendall(bytes(answer,'utf-8'))
            else:
                print(data1)
        else:
            pass

if __name__ == "__main__":
    sock1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    test = 0
    active = False

    ip_address = input('Enter Ip adress --> ')
    port = int(input('Port --> '))

    server_address = (ip_address, port)
    print('connection to ' + server_address[0] + ' on ' + str(server_address[1]))
    sock1.connect(server_address)

    data = tostr(sock1.recv(512))
    newport = int(data[10:])
    server_address = (ip_address, newport)

    sock1.close()
    sock.connect(server_address)



    chatloop(sock)
    print('closing socket')
    sock.close()