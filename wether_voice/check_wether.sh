#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/07/04
# Ver   : 0.9.3
################################

##################
# Send Msg.
##################
function sendMsg()
{
	echo ${MSG_HEAD}${MSG_VOICE}
}

##################
# Get Wether File
##################
function getWether()
{
	# Wether File Download.
	wget ${URL} -O ${FILE} -t ${RETRY} -q
	
	# File Exist Check.
	if [ ! -e ${FILE} ]
	then
		# Wether File is not found from bb exite
		MSG_VOICE=${MSG_ERR}

		# Send Message.
		sendMsg

		exit
	fi
}

##################
# setWetherdata to array
##################
function setWetherdata()
{
	# Get Rain Meter.
	array_rain=(`grep -E '(-+|[[:digit:]]+)mm' ${FILE_TEMP} | sed -e 's/[<td>m]//g' -e 's/-./0/g'`)

	# Get Temp Time.
	array_time=(`grep -E -o '([1-2]{1}[2581]{1}|[0369]{1})+:0{2}' ${FILE_TEMP}`)

	# Get Temp Wether.
	array_wether=(`grep -E -o '([1-4]+0{2}.png|1pt.gif)' ${FILE_TEMP}`)

	# Set Result.
	setResult		
}


#################
# Set Wether Count.
#################
function setWetherCount()
{
	WETHER_COUNT=`grep -E '[1-4]{1}0{2}.png' ${FILE_RESULT} | wc -l`
}

#################
# Set Wether Result at CSV.
#################
function setResult()
{
	# Delete Result File.
	test -e ${FILE_RESULT} && rm ${FILE_RESULT}
	test -e ${FILE_TEMP} && rm ${FILE_TEMP}

	# Set Data.
	for (( I = 0; I < ${#array_rain[@]}; ++I ))
	do
		echo ${array_time[$I]},${array_rain[$I]},${array_wether[$I]} >> ${FILE_RESULT}
	done
}

#################
# Create Wether Msg.
#################
function createWethermsg()
{	
	# Snow
	if [ `grep ${WE_SNOW} ${FILE_RESULT} | wc -l` -ge 1 ]
	then
		MSG_VOICE=${MSG_SNOW}
	# Rainny at all days
	elif [ `grep ${WE_RAIN} ${FILE_RESULT} | wc -l` -eq ${WETHER_COUNT}  ]
	then
		# Rainny All Days.
		MSG_VOICE=${MSG_RAIN_ALL}
	
		# check rain meter
		checkRainmeter
	# Rainny
	elif [ `grep ${WE_RAIN} ${FILE_RESULT} | wc -l` -ge 1 ]
	then
		MSG_VOICE=`cat ${FILE_RESULT} \
		| grep ${WE_RAIN} \
		| cut -d ',' -f 1 \
		| sed \
		-e s/0:00/深夜/g \
		-e s/3:00/深夜/g \
		-e s/6:00/午前中/g \
		-e s/9:00/午前中/g \
		-e s/12:00/昼間/g \
		-e s/15:00/午後/g \
		-e s/18:00/午後/g \
		-e s/21:00/夜/g \
		| uniq \
		| sed s/$/、/g  \
		| tr -d '\n' \
		| sed 's/,$//g'`

		MSG_VOICE=${MSG_VOICE}${MSG_RAIN} 

		# check rain meter
		checkRainmeter
	# Sunny
	elif [ `grep ${WE_SUNNY} ${FILE_RESULT} | wc -l` -ge `grep ${WE_CLOUD} ${FILE_RESULT} | wc -l` ]
	then
		MSG_VOICE=${MSG_SUNNY}
	else
	# Cloudy
		MSG_VOICE=${MSG_CLOUD}
	fi
}

##################
# Rain Meter Function
##################
function checkRainmeter()
{
	# Set Today Max Rain Level 0~999
	TODAY_MAX_RAIN_LEVEL=`echo ${array_rain[@]} | sed 's/ /\n/g' | sed 's/mm//g' | grep -E [[:digit:]] | sort -r | head -n 1`

	# Check Rain Level from Template
	for (( X = 0; X < ${#INDEX_RAIN_LEVEL[@]}; ++X ))
	do
		# check rain meter
		if [ ${TODAY_MAX_RAIN_LEVEL} -le ${INDEX_RAIN_LEVEL[$X]} ]
		then
			# Set Rain Level. and Return function.
			INDEX_RAIN_LEVEL_TODAY=${X}
			MSG_VOICE=${MSG_VOICE}${MSG_RAIN_METER_MSG[$INDEX_RAIN_LEVEL_TODAY]}
			return 0
		fi
	done
}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Get Wether file from bb excite wether site.

# Check your Address.
# http://weather.excite.co.jp/spot/
# 東京都 大手町
URL='http://weather.excite.co.jp/spot/zp-1006801/'

# 愛知県 名古屋
#URL='http://weather.excite.co.jp/spot/zp-4516001/'

# 大阪府 大阪
#URL='http://weather.excite.co.jp/spot/zp-5400002/'

# Temp Files
FILE='/tmp/spot-wether.html'
FILE_TEMP='/tmp/spot-wether.html.temp'
FILE_RESULT='/tmp/spot-wether.html.result'

# Wget Retry Counter
RETRY='3'

# News Key words
WE_SUNNY='100.png'
WE_CLOUD='200.png'
WE_RAIN='300.png'
WE_SNOW='400.png'

# Message
MSG_HEAD='今日の天気をお伝えするっす。'
MSG_SUNNY='今日は天気いいみたいっす。'
MSG_CLOUD='今日は曇りみたいっす。'
MSG_RAIN='に雨が降るので注意。'
MSG_RAIN_ALL='今日はずっと雨みたいっす。'
MSG_SNOW='今日は雪が降るみたいですよ。'
MSG_ERR='お天気サーバが落ちてるかも。'
MSG_VOICE=''

# Message from Version 1.5
MSG_RAIN_METER_MSG=( \
"ダッシュでなんとかなるかもね。" \
"折りたたみで大丈夫かも。" \
"ちゃんとした傘を持って行こう。" \
"かっぱが無いとダメかもね。" \
)

# Rain Meter Level.
INDEX_RAIN_LEVEL=( 0 1 2 999)
INDEX_RAIN_LEVEL_TODAY=0
TODAY_MAX_RAIN_LEVEL=0

# Get Wether
getWether

# Create Temp Wether File.
cat ${FILE} | sed -n `grep -n title-spot ${FILE} | head -n 1 | cut -d ":" -f 1`,`grep -n title-spot ${FILE} | tail -n 1 | cut -d ":" -f 1`p > ${FILE_TEMP}

# SetWetherdata
setWetherdata

# Set Wether Count.
setWetherCount

# Create Wether Msg.
createWethermsg

# sendMsg.
sendMsg

# Delete Temp Files.
test -e ${FILE_RESULT} && rm ${FILE_RESULT}
test -e ${FILE_TEMP} && rm ${FILE_TEMP}
test -e ${FILE} && rm ${FILE}

