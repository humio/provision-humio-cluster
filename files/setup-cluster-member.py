#!/usr/bin/python

import sys
import os
import re

configs = dict(line.strip().split('=') for line in open('config.conf'))

ipStrings = configs["ips"].split(',')
nameStrings = configs["names"].split(',')
ips = map(lambda str: str.strip(), ipStrings)
names = map(lambda str: str.strip(), nameStrings)

args = sys.argv
if len(args) != 2:
    raise Exception('script requires the name of the host as parameter')

currentName = args[1]
if currentName not in names:
    raise Exception('supplied parameter ' + currentName + ' was not a name in the supplied config file. ' + str(names))


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

def findID( currentName, names ):
    myIDMatch = re.search('(\d+)$', currentName)
    myID = myIDMatch.group() if myIDMatch else str(names.index(currentName) + 1)
    return myID

def createZookeeperProperties( currentName, names ):
    zookeeperServers = ['server.' + str(index +1) + '=' + name + ':2888:3888' for index,name in enumerate(names)]
    mapping = {'<servers>':('\n'.join(zookeeperServers)), '<name>':currentName}
    createFromTemplate('zookeeper.properties', mapping)
    return;

def createZookeeperMyID( currentName, names ):
    myID = findID(currentName, names)
    mapping = {'<myID>':myID}
    createFromTemplate('zookeeper-myid', mapping)
    return;

def createKafkaProperties( currentName, names ):
    brokerIDMatch = re.search('(\d+)$', currentName)
    brokerID = brokerIDMatch.group() if brokerIDMatch else str(names.index(currentName) + 1)
    listeners = 'PLAINTEXT://'+ currentName + ':9092'
    zookeeperConnect = ','.join(map(lambda name: name + ':2181', names))
    mapping = {
        '<brokerID>':brokerID,
        '<name>':currentName,
        '<listeners>': listeners,
        '<zookeeperConnect>': zookeeperConnect}
    createFromTemplate('kafka.properties', mapping)
    return;

def createHumioConfigEnv( currentName, names ):
    hostIDMatch = re.search('(\d+)$', currentName)
    hostID = hostIDMatch.group() if hostIDMatch else str(names.index(currentName) + 1)
    url = 'http://' + currentName + ':8080'
    kafkaServers = ','.join(map(lambda name: name + ':9092', names))
    zookeeperUrls = ','.join(map(lambda name: name + ':2181', names))

    mapping = {'<hostID>':hostID, '<url>':url, '<kafkaServers>':kafkaServers, '<zookeeperUrls>':zookeeperUrls}
    createFromTemplate('humio-config.env', mapping)
    return;

def createHostsFileAdditions( ips, names ):
    entries = [ip + '\t\t' + name for ip, name in zip(ips, names)]
    mapping = {'<entries>':'\n'.join(entries)}
    createFromTemplate('hosts', mapping)
    return;

createZookeeperProperties(currentName, names)
createHumioConfigEnv(currentName, names)
createKafkaProperties(currentName, names)
createZookeeperMyID(currentName, names)
createHostsFileAdditions(ips, names)
