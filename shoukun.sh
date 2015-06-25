#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/06/25
# Ver   : 0.9.1
################################

#####################
# Check Arg.
#####################
function checkArg()
{
	if [ $1 -eq '' ]
	then
		TEXT=$1
	fi
}

#####################
# Init Command.
#####################
function initCommand()
{
	# Set Command.
	CMD='curl ${URL} 
        -o ${SOUND_NAME}.${SOUND_FORMAT} 
        -u ${AUTH_KEY}: 
        -d text=${TEXT} 
        -d speaker=${SPEAKER} 
        -d emotion_level=${EMOTION_LEVEL}
        -d pitch=${PITCH} 
        -d speed=${SPEED}'

	if [ "${SPEAKER}" != "show" ]
	then
		CMD="${CMD} -d emotion=${EMOTION}"
	fi
}

#####################
# Speak.
#####################
function doSpeak()
{
	# Execute Speak.
	eval ${CMD} >/dev/null 2>&1 
}

#####################
# Main Function. 
#####################
AUTH_KEY=your_auth_key

# Kind of Speaker.
# show : man
# haruka : woman
# hikari : woman
# takeru : man
# santa : santa?
# bear : ferocious bear !?
SPEAKER=show

# Url.
URL="https://api.voicetext.jp/v1/tts"

# Sound File.
SOUND_NAME=/tmp/moyamoya

# Sound File Format. 
# default : wav
SOUND_FORMAT=wav

# Emotion
# happiness or anger or sadness 
EMOTION=happiness

# Emotion Level. from 1 to 4.
# default : 2
EMOTION_LAVEL=2

# Pitch. from 50 to 200.
# default : 100
PITCH=100

# Speed. from 50 to 400.
# default : 100
SPEED=95

# Volume. from 50 to 200.
# default : 100
VOLUME=200

# Check Arg.
if [ $# -eq 0 ]
then
	# Text.
	TEXT='引数が何もないっす'
else
	# Text.
	TEXT=${1}
fi

# Init Command.
initCommand

# Speak.
doSpeak

