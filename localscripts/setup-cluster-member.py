#!/usr/bin/python

import sys
import os
import re

configs = dict(line.strip().split('=') for line in open('config.conf'))

ipStrings = configs["IPS"].split(',')
ips = map(lambda str: str.strip(), ipStrings)

args = sys.argv
if len(args) != 2:
    raise Exception('script requires the ip-address of the host as parameter')

ip = args[1]
if ip not in ips:
    raise Exception('supplied parameter ' + ip + ' was not an ip in the supplied config file. ' + str(ips))


def createFromTemplate( template, dictionary ):
    with open('templates/' + template, 'r') as templateFile:
        string = templateFile.read()

    if not os.path.exists('output'):
        os.makedirs('output')

    for key, value in dictionary.iteritems():
        string = string.replace(key, value)

    with open('output/' + template, "w") as text_file:
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

def createHumioConfigEnv( ip, ips ):
    hostID = findID(ip, ips)
    url = 'http://' + ip + ':8080'
    kafkaServers = ','.join(map(lambda ip: ip + ':9092', ips))
    zookeeperUrls = ','.join(map(lambda ip: ip + ':2181', ips))

    mapping = {'<hostID>':hostID, '<url>':url, '<kafkaServers>':kafkaServers, '<zookeeperUrls>':zookeeperUrls}
    createFromTemplate('humio-config.env', mapping)
    return;

createZookeeperProperties(ip, ips)
createHumioConfigEnv(ip, ips)
createKafkaProperties(ip, ips)
createZookeeperMyID(ip, ips)
