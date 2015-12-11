#/bin/sh

#Set System Time settings
#Set timezone to America/New_York
systemsetup -settimezone America/New_York

#Set Time Server
systemsetup -setnetworktimeserver ntp.keansburg.k12.nj.us

#Enable network time
systemsetup -setusingnetworktime on

#
