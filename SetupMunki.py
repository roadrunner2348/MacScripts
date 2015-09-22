#!/usr/bin/env python

import urllib2
from tempfile import mkstemp
from shutil import move, rmtree
from os import remove, close, path, rename, umask, symlink, unlink, walk, makedirs
import subprocess
import math
import time
import argparse
import re
import sys

parser = argparse.ArgumentParser(description='Installs and configures Munki on OS X')
parser.add_argument('--server', help='The URL of the Munki Server. Defaults to http://munki.keansburg.k12.nj.us')
parser.add_argument('--manifest', help='The name of the Manifest or ClientIdentifier that the client should use')
args = vars(parser.parse_args())

if args['server']:
    munkiserver = args['server']
else:
    munkiserver = 'http://munki.keansburg.k12.nj.us:8080'
    
if args['manifest']:
   manifest = args['manifest']
else:
   sys.exit('Must provide a manifest name!')
   
def downloadChunks(url):
    """Helper to download large files
        the only arg is a url
       this file will go to a temp directory
       the file will also be downloaded
       in chunks and print out how much remains
    """

    baseFile = path.basename(url)

    #move the file to a more uniq path
    umask(0002)

    try:
        temp_path='/tmp'
        file = path.join(temp_path,baseFile)

        req = urllib2.urlopen(url)
        total_size = int(req.info().getheader('Content-Length').strip())
        downloaded = 0
        CHUNK = 256 * 10240
        with open(file, 'wb') as fp:
            while True:
                chunk = req.read(CHUNK)
                downloaded += len(chunk)
                print math.floor( (downloaded / total_size) * 100 )
                if not chunk: break
                fp.write(chunk)
    except urllib2.HTTPError, e:
        print "HTTP Error:",e.code , url
        return False
    except urllib2.URLError, e:
        print "URL Error:",e.reason , url
        return False

    return file

def forget_pkg(pkgid):
    cmd = ['/usr/sbin/pkgutil', '--forget', pkgid]
    proc = subprocess.Popen(cmd, bufsize=1,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    (output, unused_err) = proc.communicate()
    return output

def internet_on():
    try:
        response=urllib2.urlopen(munkiserver,timeout=1)
        return True
    except urllib2.URLError as err: pass
    return False

def chown_r(path):
    makedirs(path)
    the_command = "chown -R root:wheel "+path
    serial = subprocess.Popen(the_command,shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE).communicate()[0]
    the_command = "chmod -R 777 "+path
    serial = subprocess.Popen(the_command,shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE).communicate()[0]

if internet_on:
    import platform
    v, _, _ = platform.mac_ver()
    v = float('.'.join(v.split('.')[:2]))
    print v

    print "Downloading Munki"
    the_pkg = downloadChunks("https://github.com/munki/munki/releases/download/v2.3.1/munkitools-2.3.1.2535.pkg")
    #install it
    print "Installing Munki"
    the_command = "/usr/sbin/installer -pkg /tmp/munkitools-2.3.1.2535.pkg -target /"
    p=subprocess.Popen(the_command,shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    p.wait()
    time.sleep(20)
    #set munki configuration settings
    print "Configuring Munki"
    the_command = "/usr/bin/defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "+munkiserver
    p=subprocess.Popen(the_command,shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    p.wait()
    time.sleep(2)
   
    the_command = "/usr/bin/defaults write /Library/Preferences/ManagedInstalls IconURL "+munkiserver+"/icon"
    p=subprocess.Popen(the_command,shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    p.wait()
    time.sleep(2)
   
    the_command = "/usr/bin/defaults write /Library/Preferences/ManagedInstalls ClientIdentifier "+manifest
    p=subprocess.Popen(the_command,shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    p.wait()
    time.sleep(2)
    
    print "All done!"
