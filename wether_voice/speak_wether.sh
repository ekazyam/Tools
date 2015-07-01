#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/07/01
# Ver   : 0.9.4
################################

##################
# File Exist Check.
##################
function speakVoice()
{
	# Check Lock File Exist.
	if [ ! -e ${LOCK} ]
	then
		# Create Lock File.
		createLock
		
		# Make Voice File.
		createSound

		# Exit.
		exit
	fi

	# Check Time.
	if [ `date +%H%M` -le ${TIME} ]
	then
		# Exit.
		exit
	fi

	# Check Day.
	if [ `cat ${LOCK}` -eq `date +%y%m%d` ]
	then
		# Exit.
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
	date -d yesterday +%y%m%d > ${LOCK}
}

##################
# Rewrite Lock File.
##################
function rewriteLock()
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

	# Rewrite Lock File.
	rewriteLock
}

##################
# Create Sound.
##################
function createSound()
{
	# Create Sound.	
	shoukun.sh `check_wether.sh`
}
	
##################
# Main Function.
##################
# Path Setting.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Speak Time.
# Execute after AM 08:30 
TIME=0830

# Lock File.
LOCK=/tmp/voice.lock

# Target File.
VOICE_FILE='/tmp/moyamoya.wav'
if [ $# -eq 0 ]
then
	# Exit.
	exit
fi

if [ ${1} == 'make' ]
then
	# Make Voice File.
	createSound

elif [ ${1} == 'speak' ]
then
	if [ $# -ge 2 ] && [ ${2} == 'force' ]
	then
		# Speak force.
		speakSound
	else
		# Speak.
		speakVoice
	fi
fi
