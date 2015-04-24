#/bin/sh

# This script will add two servers to the Oracle Java Exception Site List. 
# If the servers are already in the whitelist, it will note that in the log, then exit.
# More servers can be added as needed. The existing server entries can also be set to be
# empty (i.e. SERVER2='') as the script will do a check to see if either SERVER value
# is set to be null.

# Server1's address
SERVER1='http://parcctrng.testnav.com'

# Server2's address
SERVER2='https://parcctrng.testnav.com'

LOGGER="/usr/bin/logger"
WHITELIST=$HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites"
SERVER1_WHITELIST_CHECK=`cat $HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites" | grep $SERVER1`
SERVER2_WHITELIST_CHECK=`cat $HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites" | grep $SERVER2`

JAVA_PLUGIN=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

if [[ ${JAVA_PLUGIN} != 'com.oracle.java.JavaAppletPlugin' ]]; then
   ${LOGGER} "Oracle Java browser plug-in not installed"
   exit 0
fi

if [[ ${JAVA_PLUGIN} = 'com.oracle.java.JavaAppletPlugin' ]]; then
 ${LOGGER} "Oracle Java browser plug-in is installed. Checking for Exception Site List."
 if [[ ! -f "$WHITELIST" ]]; then
   ${LOGGER} "Oracle Java Exception Site List not found. Creating Exception Site List."

   # Create exception.sites file
   touch  "$WHITELIST"

   # Add needed server(s) to exception.sites file
   if [[ -n ${SERVER1} ]]; then 
     /bin/echo "$SERVER1" >> "$WHITELIST"
   fi
   if [[ -n ${SERVER2} ]]; then
     /bin/echo "$SERVER2" >> "$WHITELIST"
   fi
   exit 0
 fi

 if [[ -f "$WHITELIST" ]]; then
   ${LOGGER} "Oracle Java Exception Site List Found."

  if [[ -n ${SERVER1_WHITELIST_CHECK} ]]; then

    # Server1 settings are present
	${LOGGER} "${SERVER1_WHITELIST_CHECK} is part of the Oracle Java Exception Site List. Nothing to do here."
    else	    
	# Add Server1 to exception.sites file
    if [[ -n ${SERVER1} ]]; then 
      /bin/echo "$SERVER1" >> "$WHITELIST"
      ${LOGGER} "$SERVER1 has been added to the Oracle Java Exception Site List."
    fi
  fi
  if [[ -n ${SERVER2_WHITELIST_CHECK} ]]; then

    # Server2 settings are present
	${LOGGER} "${SERVER2_WHITELIST_CHECK} is part of the Oracle Java Exception Site List. Nothing to do here."
    else	    
	# Add Server2 to exception.sites file
    if [[ -n ${SERVER2} ]]; then 
      /bin/echo "$SERVER2" >> "$WHITELIST"
      ${LOGGER} "$SERVER2 has been added to the Oracle Java Exception Site List."
    fi  
   fi
 fi
fi

####################################
## SAFARI PLUGINS EXCEPTIONS LIST ##
####################################

theFile="$HOME/Library/Preferences/com.apple.Safari.plist"

${LOGGER} "modifying $theFile"

site="parcctrng.testnav.com"

${LOGGER} "Site: $site"

if [[ ! -f $theFile ]]; then
	  touch $theFile
	${LOGGER} "File not found, creating new"
	  /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies array" $theFile
      /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInHostname string $site" $theFile
      /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInLastVisitedDate date $(date)" $theFile
      /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInPageURL string $site" $theFile
      /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInPolicy string PlugInPolicyAllowNoSecurityRestrictions" $theFile
      /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInRunUnsandboxed bool True" $theFile
else
	${LOGGER} "File found, modifying plist"
	
	#Determine how many dictionary entires there are in the plist
	DICT_COUNT=`/usr/libexec/plistbuddy -c "print ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies" $theFile | grep "Dict" | wc -l | tr -d " "`
	${LOGGER} "DICT_COUNT: $DICT_COUNT"
	
	#Determine if a entry already exists for your server
	SITE_PRESENT=`/usr/libexec/plistbuddy -c "print ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies" $theFile | grep $site | wc -l | tr -d " "`
	
	${LOGGER} "SITE_PRESENT $SITE_PRESENT"

	if [ $DICT_COUNT -gt 0 ] && [ $SITE_PRESENT -gt 0 ]; then
	#Both DICT exists and a vnet entry exists. Set the preferences
	for idx in `seq 0 $((DICT_COUNT - 1))`
	do

   	  val=`/usr/libexec/PlistBuddy -c "Print ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${idx}:PlugInHostname" $theFile`
    
	 if [ $val = $site ]; then
     	 	/usr/libexec/plistbuddy -c "set ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${idx}:PlugInHostname $site" $theFile
    		/usr/libexec/plistbuddy -c "set ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${idx}:PlugInLastVisitedDate $(date)" $theFile
     	 	/usr/libexec/plistbuddy -c "set ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${idx}:PlugInPageURL  $site" $theFile
     	 	/usr/libexec/plistbuddy -c "set ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${idx}:PlugInPolicy PlugInPolicyAllowNoSecurityRestrictions" $theFile
    	  	/usr/libexec/plistbuddy -c "set ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${idx}:PlugInRunUnsandboxed  True" $theFile
    	 fi
	done

	elif [ $DICT_COUNT -gt 0 ] && [ $SITE_PRESENT -eq 0 ]; then
	#Java array has DICT entries, but vnet is not one of them. Add it to the next available array index
     	/usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies array" $theFile
    	/usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${DICT_COUNT}:PlugInHostname string $site" $theFile
    	/usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${DICT_COUNT}:PlugInLastVisitedDate date $(date)" $theFile
    	/usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${DICT_COUNT}:PlugInPageURL string $site" $theFile
    	/usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${DICT_COUNT}:PlugInPolicy string PlugInPolicyAllowNoSecurityRestrictions" $theFile
    	/usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:${DICT_COUNT}:PlugInRunUnsandboxed bool True" $theFile
	else
		 /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies array" $theFile
      	 /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInHostname string $site" $theFile
      	 /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInLastVisitedDate date $(date)" $theFile
     	 /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInPageURL string $site" $theFile
     	 /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInPolicy string PlugInPolicyAllowNoSecurityRestrictions" $theFile
     	 /usr/libexec/plistbuddy -c "add ManagedPlugInPolicies:com.oracle.java.JavaAppletPlugin:PlugInHostnamePolicies:0:PlugInRunUnsandboxed bool True" $theFile
     fi
fi
exit 0