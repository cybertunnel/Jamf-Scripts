#!/bin/sh

# DownloadBuildingsList.sh
# By William Smith
# Professional Services Engineer
# JAMF Software
# July 9, 2016
# bill@talkingmoose.net

# Except where otherwise noted, this work is licensed under
# http://creativecommons.org/licenses/by/4.0/

# INSTRUCTIONS

# 1) Modify URL, USERNAME and PASSWORD below to access your JSS.
# 2) Save and run this script via Terminal or an editor with a "run script" feature.
# 3) Review the "Buildings List.txt" file in the JSS_Output folder.

URL="https://jss.talkingmoose.net:8443"
USERNAME="casperadmin"
PASSWORD="password"

# create the output directory and log file
# in the same directory as this script

# path to this script
CURRENTDIRECTORY=$( /usr/bin/dirname "$0" )

# name of this script
CURRENTSCRIPT=$( /usr/bin/basename -s .sh "$0" )

# create the JSS_Output directory in the same directory as script
OUTPUTDIRECTORY="$CURRENTDIRECTORY/JSS_Output"

# create log file in same directory as script
LOGFILE="$CURRENTDIRECTORY/$CURRENTSCRIPT - $( /bin/date '+%y-%m-%d' ).log"

# functions
function logresult()	{
	if [ $? = 0 ] ; then
	  /bin/date "+%Y-%m-%d %H:%M:%S	$1" >> "$LOGFILE"
	else
	  /bin/date "+%Y-%m-%d %H:%M:%S	$2" >> "$LOGFILE"
	fi
}

# the time right now
STARTTIME=$( /bin/date '+%s' )

# start the log
logresult "--------------------- Begin Script ---------------------"

# create the output directory if necessary
mkdir -p "$OUTPUTDIRECTORY"
logresult "Created $OUTPUTDIRECTORY directory." "Failed creating $OUTPUTDIRECTORY directory or it already exists."

# download building XML file from JSS
BUILDINGXML=$( /usr/bin/curl -k $URL/JSSResource/buildings --user "$USERNAME:$PASSWORD" -H "Content-Type: text/xml" -X GET  | xmllint --format - )

logresult "Downloaded building XML information." "Failed downloading building XML information."

# parse the list for just building names
BUILDINGSLIST=$( /bin/echo "$BUILDINGXML" | /usr/bin/perl -lne 'BEGIN{undef $/} while (/<name>(.*?)<\/name>/sg){print $1}' )

logresult "Parsed building XML information for building names." "Failed parsing building XML information for building names."

# write the list to the output file
echo "$BUILDINGSLIST" > "$OUTPUTDIRECTORY/Buildings List.txt"

logresult "Wrote building information to JSS_Output directory." "Failed to write building information to JSS_Output directory."

# count the buildings
BUILDINGCOUNT=$( echo "$BUILDINGSLIST" | grep -c ^ )

logresult "Counted number of buildings." "Failed to count number of buildings."

# stop the timer
# calculate how long the script ran

logresult "Completing script."
logresult "Listed $BUILDINGCOUNT buildings."

# the time right now
STOPTIME=$( /bin/date '+%s' )

# subtract start time from stop time and log the time in seconds
DIFF=$(($STOPTIME-$STARTTIME))
logresult "Script operations took $DIFF seconds to complete."

logresult "---------------------- End Script ----------------------

"

exit 0
