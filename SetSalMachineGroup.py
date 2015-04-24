#!/usr/bin/python

#Created by Justin Wolf
#March 20, 2015
# Version 1.00

import os
import subprocess
import sys

def getMachineGroupKey( building, subnet ):
	
	subnet = int(subnet)
	building = int(building)
#These two are used for testing subnets, uncomment to use.
	#subnet = 35
	#building = 234
	
	#Get subnet type	
	if subnet == 99:
		dict_key = "Tech"
	elif 64 <= subnet <= 67:
		dict_key = "Faculty"
	elif 68 <= subnet <= 71:
		dict_key = "Students"
	elif 32 <= subnet <= 63:
		dict_key = "Students"
	else:
		dict_key = ""
	
	if dict_key == "Tech":
		print "Assigned Group: Tech"
		return keys[dict_key]
	elif dict_key == "":
		print "Unregistered Subnet, cannot set machine key. Exiting..."
		sys.exit()
	else:
		while True:
				try:
					bld_name = buildings[building]
					break
				except KeyError:
					sys.exit("Invalid Building Subnet! Exiting...")
		print "Assigned Group: " + bld_name + " " + dict_key
		while True:
			try:
				key = keys[bld_name + " " + dict_key]
				break
			except KeyError:
				sys.exit("Invalid Building/Subnet Combination! Exiting...")
		return key
	


def setPreferences( key ):
	print "Writing Preference Files..."
	subprocess.call(["defaults", "write", "/Library/Preferences/com.salsoftware.sal", "key", key])
	subprocess.call(["defaults", "write", "/Library/Preferences/com.salsoftware.sal", "ServerURL", "http://sal.keansburg.k12.nj.us"])
	print "Done! Exiting..."
	sys.exit()

if not os.geteuid() == 0:
    sys.exit('Script must be run as root')

#Build Dictionaries...
	
buildings = {	21:'BMS',
				22:'CES',
				23:'KHS',
				24:'PRS',
				25:'CES' }	
				
keys = {	"Tech":"5z4wpiwcyc4e6wm61wjmvjcoiqkt84go522srinb4v7eelvne1o5pjv50737o7zpd2h0zgp07zglg81bdertsip70fn7o68o1wpw1m2hdqbdv7th57gbh7d6wixdq4pw",
			"BMS Students":"ixbbxtbx1burbvuhdpiiv1pziq21px3ifzy648dvxkcbmwm0iv87kyz4iadmj8k11orlp9n5oeduw7342fa4zjk0j196z0b6xipghx05oa34hnz44focwegkao2imyn4",
			"BMS Faculty":"tfpxrpw3rt5jdkpi7t71z6g2ntm72721a27zkk6uxhyyntfhmw1414vy99nni90ubk06jy3g35r0w1fjb9b5wfoumipb3bilu0xcutdby424dfw6u0esbjsuu1k8kb7d",
			"CES Students":"2omyuzvxf640t5l7rooqk2tdd0h9gfjm626fo9qm6pavfp4b8kxcpssgfijf5n5alfwe5rvvp516ybtnlmj4vltafjo8sd2drtl58tvrxga7glnjfusjaalv073mpf81",
			"CES Faculty":"uc0augr99t8yy0jdhoa9q0921cnhyu7fzrj7m2cb6blnizqy1mspapj0v1cmehpvkwh0tvhzqmkfomtlqkacj590xrv6cnpjc2rheggowo14kr9qegrpwq2als9pty8p",
			"KHS Students":"iv5eqy6fgn71pdzlebglq4v618isvzh770ijvw4jtpjnoolxytms6b3baz83b9rve3nw80ojr98ocgnmjxgcqz3xfj296y76123xypsxcqvu51wddyhfjv59h187gbd0",
			"KHS Faculty":"qvedshh7rqpx0r1cfp773pm3zibmn49lng50w7dpuddfpno3lfhm9rl7p5bv5plkop0d1i4btvp8m2azcpw7pnggnoo4a4mzt7gt7436vfs360vl5syr65htdyhdno8k",
			"PRS Students":"jtbea5l8q024uqq9oko9r0rzevtilzok5dm45rjr5fp9ohnno7twkztirat3qb9y63k3zfapqwi0s5p00ctsi91r1pgbvupwe6gyrd7sxjttcvotu621bo4x3mk8ysyv",
			"PRS Faculty":"fdtw8jdmxbj94k3ux6zqzl4yg4qailgor4qbbkv6pm7jhi4aemuqx03u11utyp7we7lv127srae7gtkxeg61vgur3geqj94uvmr4s5jwh82ymwh06nu7v4jt83kx58p3"
		}
#Get the active interface of the machine...

print "Determining Active Network Interface..."

the_command = subprocess.Popen(["route","get","8.8.8.8"], stdout=subprocess.PIPE)
output = the_command.communicate()[0]
output = output.split()
index = output.index("interface:") + 1
interface = output[index]

print interface + " is the active interface, retrieving IP Address..."

#Getting the ip address of the active interface
the_command = subprocess.Popen(["ipconfig","getifaddr", interface], stdout=subprocess.PIPE)
output = the_command.communicate()[0]
ip_address = output.strip()

print "Your IP Address is " + ip_address

#remove the last octet of the IP Address
octets = ip_address.split(".")
building_code = octets[1]
subnet_code = octets[2]

key = getMachineGroupKey( building_code, subnet_code )
setPreferences( key )



