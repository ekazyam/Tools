#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/07/11
# Ver   : 1.0.1
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
# Tweet.
##################
function twWether()
{
	# Check Exist Tw Command.
	type tw >/dev/null 2>&1 || exit

	# Check Exist Voice Text and Set Twitter User Account.
	if [ ! ${VOICE_TEXT} == '' ] && [ ! ${TW_USER} == '' ]
	then
		# Set Date.
		DATE=`date "+%m/%d(%a) "`

		# Tweet Wether.
		yes | tw --dm:to=${TW_USER} ${DATE}${VOICE_TEXT}
	fi
}

##################
# Create Sound.
##################
function createSound()
{
	# Create Sound.	
	VOICE_TEXT=`check_wether.sh`
	shoukun.sh ${VOICE_TEXT}
}

##################
# Delete Old File.
##################
function deleteOld()
{
	# Create Old Sound File.
	if [ -e ${VOICE_FILE} ]
	then
		rm ${VOICE_FILE}
	fi
}
	
##################
# Main Function.
##################
# Path Setting.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Umask Setting.
umask 000

# Speak Time.
# Execute after AM 08:30 
TIME=0900

# Twitter User.
TW_USER='Rumcoke77'

# Voice Text Data.
VOICE_TEXT=''

# Lock File.
LOCK=/tmp/voice.lock

# Target File.
VOICE_FILE='/tmp/moyamoya.wav'

# Delete old File.
deleteOld
	
# Make Voice File.
createSound

# Speak.
speakVoice

# Twitter.
twWether
