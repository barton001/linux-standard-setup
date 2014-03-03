#!/usr/bin/python

import os

do = os.system

print "Getting group list..."

lines = os.popen("yum grouplist").readlines()

started = False
grouplist = []

for line in lines:
    if line.find("Available Groups:") != -1:
        started = True
    elif started and line[0:2] != "  ":
        break
    elif started:
        grouplist.append(line.strip())
        
wanted = []
for group in grouplist:
    answer = raw_input("Install %s [n]? " % group)
    if answer and answer in "yY":
        wanted.append(group)
        print "Added", group, "to install list"

if not wanted:
    print "No groups selected."
    sys.exit(0)
            
print
print
for i, group in enumerate(wanted):
    print i+1, group
    
ok = raw_input("Install these %d groups? " % len(wanted))
if ok and ok in "yY":
    for i, group in enumerate(wanted):
        print """
        *************************************************************
        ***  %d)  Installing %s
        *************************************************************
        """ % (i+1, group)
        
        do("yum -y groupinstall '%s'" % group)
        
    
    
