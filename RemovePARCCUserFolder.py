#!/usr/bin/python

#Created By Justin Wolf
#April 24th 2015

import os
import subprocess
import sys

command = subprocess.Popen('users', stdout=subprocess.PIPE)
users = command.communicate()[0]

users = users.strip()
users = users.split(' ')

print "Checking to see if PARCC2015 User is logged in..."
for user in users:
	if user == 'PARCC2015':
		sys.exit("PARCC2015 logged in, cannot remove account directory")

if os.path.isdir("/User/username"):
	print "Removing PARCC2015 Folder"
	sys.exit()

print "PARCC2015 User directory not found, exiting..."
sys.exit()


