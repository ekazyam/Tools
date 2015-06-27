#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/06/27
# Ver   : 0.9.0
################################

##################
# File Exist Check.
##################
function speakVoice()
{
	# Check Voice File Exist.
	if [ -e ${VOICE_FILE} ]
	then
		aplay ${VOICE_FILE}
	fi
}

##################
# Main Function.
##################
# Path Setting.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Target File.
VOICE_FILE='/tmp/moyamoya.wav'
if [ $# -eq 0 ]
then
	exit 1
fi

if [ ${1} == 'make' ]
then
	# Make Voice File.
	shoukun.sh `check_wether.sh`
elif [ ${1} == 'speak' ]
then
	# Speak.
	speakVoice
fi
