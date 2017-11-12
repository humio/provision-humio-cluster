#!/usr/bin/python
import sys

args = sys.argv
if len(args) != 4:
    raise Exception('script requires 3 parameters. 1. the number of total cpus. 2. the number of total cores. 3. the cpu for which to print the cpu string')

numberOfCpus = int(args[1])
numberOfCores = int(args[2])
selectedCpu = int(args[3])

cpuStrings = [ [] for i in range(numberOfCpus)]
#reserve the first core on each cpu to the os - not sure if this is a bad idea
for core in range(numberOfCpus, numberOfCores):
    cpu = core % numberOfCpus
    cpuStrings[cpu].append(str(core))

print(",".join(cpuStrings[selectedCpu - 1]))
