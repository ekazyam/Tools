#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/06/27
# Ver   : 0.9.1
################################

##################
# File Exist Check.
##################
function speakVoice()
{
	# Check Lock File Exist.
	if [ ! -e ${LOCK} ]
	then
		# Create Lock.
		createLock
		
		# Exit
		exit
	fi

	# Check Time.
	if [ `date +%H%M` -lt ${TIME} ]
	then
		exit
	fi

	# Check Day.
	if [ `cat ${LOCK}` -eq `date +%y%m%d` ]
	then
		exit
	fi

	# Check Voice File Exist.
	if [ -e ${VOICE_FILE} ]
	then
		# Speak.
		speakSound
	fi
}

##################
# Create Lock File.
##################
function createLock()
{
	# Set Lock File.
	date +%y%m%d > ${LOCK}
}

##################
# Speak.
##################
function speakSound()
{
	# Speak.
	aplay ${VOICE_FILE}

	# Create and RewriteLock.
	createLock
}
	
##################
# Main Function.
##################
# Path Setting.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Speak Time.
# Execute after AM 08:30 
TIME=2300

# Lock File.
LOCK=/tmp/voice.lock

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
