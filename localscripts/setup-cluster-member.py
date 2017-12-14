#!/usr/bin/python

import sys
import os
import re

lines = [ line.rstrip() for line in open('config.conf') if not line.startswith('#') and line.rstrip()]
configs = dict(line.strip().split('=') for line in lines)

ipStrings = configs["IPS"].split(',')
ips = map(lambda str: str.strip(), ipStrings)


args = sys.argv
if len(args) != 3:
    raise Exception('script requires the ip-address of the host as first parameter and the number of CPUs as the second parameter')

ip = args[1]
if ip not in ips:
    raise Exception('supplied parameter ' + ip + ' was not an ip in the supplied config file. ' + str(ips))

cpus = int(args[2])

def createFromTemplate( template, dictionary, filename=None):
    if filename is None:
        filename = template

    with open('templates/' + template, 'r') as templateFile:
        string = templateFile.read()

    if not os.path.exists('output'):
        os.makedirs('output')

    for key, value in dictionary.iteritems():
        string = string.replace(key, value)

    with open('output/' + filename, "w") as text_file:
        text_file.write(string)

    return;

def findID( ip, ips ):
    return str(ips.index(ip) + 1)

def createZookeeperProperties( ip, ips ):
    zookeeperServers = ['server.' + str(index +1) + '=' + serverIp + ':2888:3888' for index,serverIp in enumerate(ips)]
    mapping = {'<servers>':('\n'.join(zookeeperServers)), '<ip>':ip}
    createFromTemplate('zookeeper.properties', mapping)
    return;

def createZookeeperMyID( ip, ips ):
    myID = findID(ip, ips)
    mapping = {'<myID>':myID}
    createFromTemplate('zookeeper-myid', mapping)
    return;

def createKafkaProperties( ip, ips ):
    brokerID = findID(ip, ips)
    listeners = 'PLAINTEXT://'+ ip + ':9092'
    zookeeperConnect = ','.join(map(lambda ip: ip + ':2181', ips))
    mapping = {
        '<brokerID>':brokerID,
        '<listeners>': listeners,
        '<zookeeperConnect>': zookeeperConnect}
    createFromTemplate('kafka.properties', mapping)
    return;

def createHumioConfigEnv( ip, ips, numberOfCpus):
    kafkaServers = ','.join(map(lambda ip: ip + ':9092', ips))
    zookeeperUrls = ','.join(map(lambda ip: ip + ':2181', ips))

    for index in range(0, numberOfCpus):
        filename = 'humio-config' + str(index + 1) + '.env'
        port = 8080 + index
        url = 'http://' + ip + ':' + str(port)

        mapping = {'<port>':str(port), '<url>':url, '<kafkaServers>':kafkaServers, '<zookeeperUrls>':zookeeperUrls}
        createFromTemplate('humio-config.env', mapping, filename)
    return;

def createNginxConfig(ips, numberOfCpus):
    servers = ['server ' + ip + ':' + str(8080 + port) + ';'  for ip in ips for port in range(0, numberOfCpus)]
    mapping = {'<ip-addresses>':('\n'.join(servers))}
    createFromTemplate('nginx.conf', mapping)
    return;


createZookeeperProperties(ip, ips)
createZookeeperMyID(ip, ips)
createKafkaProperties(ip, ips)
createHumioConfigEnv(ip, ips, cpus)
createNginxConfig(ips, cpus)
