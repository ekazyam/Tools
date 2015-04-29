#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/29
# Ver   : 1.6
################################

##################
# Tweet.
##################
function sendTwitter()
{
	# Tweet!
	test -z ${TW_USER} && yes | tw ${MSG_BOT}${MSG_TWEET}
	test -z ${TW_USER} || yes | tw --user=${TW_USER} ${MSG_BOT}${MSG_TWEET}
}

##################
# Get Wether File
##################
function getWether()
{
	# Wether File Download.
	wget ${URL} -O ${FILE} -t ${RETRY}
	
	# File Exist Check.
	if [ ! -e ${FILE} ]
	then
		# Wether File is not found from bb exite
		MSG_TWEET=${MSG_ERR}
		sendTwitter
		exit
	fi
}

##################
# setWetherdata to array
##################
function setWetherdata()
{
	# Create Temp Rain File.
	array_rain=(`grep -A 8 ${KEY_1} ${FILE_TEMP} | tail -n 8 | sed -e 's/<\/*td>//g'`)

	# Create Temp Time File.
	array_time=(`grep -A 8 ${KEY_2} ${FILE_TEMP} | tail -n 8 | sed -e 's/<td class="ti">//g' -e 's/<td class="target">//g' -e 's/<\/td>//g'`)

	# Create Temp News File.
	array_news=(`grep -A 8 ${KEY_3} ${FILE_TEMP} | tail -n 8 | sed -e 's/<\/*td>//g' -e 's/<br>/ /g' | cut -d " " -f 1`)

	# Create Temp Wind File.
	array_wind=(`grep -A 8 ${KEY_3} ${FILE_TEMP} | tail -n 8 | sed -e 's/<\/*td>//g' -e 's/<br>/ /g' | cut -d " " -f 2`)

	# Create Temp Wether File.
	array_wether=(`grep "<img src" ${FILE_TEMP} | cut -d " " -f 3`)
}

##################
# check wind
##################
function checkWind()
{
	# Message for News. at Rainny.
	grep ${WE_R} ${FILE_RESULT} | grep -q ${ROOM_NEWS} && MSG_TWEET=${MSG_TWEET}${MSG_NEWS}
}

#################
# Create Wether Msg.
#################
function createWethermsg()
{	
	# Snow
	if [ `grep ${WE_SN} ${FILE_RESULT} | wc -l` -gt 0 ]
	then
		MSG_TWEET=${MSG_SNOW}

	# Rainny at all days
	elif [ `grep ${WE_R} ${FILE_RESULT} | wc -l` -eq 5 ]
	then
		# Rainny All Days.
		MSG_TWEET=${MSG_RAIN_ALL}
	
		# check wind
		checkWind
		
		# check rain meter
		checkRainmeter
	# Rainny
	elif [ `grep ${WE_R} ${FILE_RESULT} | wc -l` -gt 0 ]
	then
		MSG_TWEET=`cat ${FILE_RESULT} \
		| grep ${WE_R} \
		| sed 's/ /,/g' \
		| cut -d ',' -f 1 \
		| sed \
		-e s/9:00/午前中/g \
		-e s/12:00/昼間/g \
		-e s/15:00/おやつ時/g \
		-e s/18:00/夕方/g \
		-e s/21:00/夜/g \
		| sed s/$/,/g  \
		| tr -d '\n' \
		| sed 's/,$//g'`
		MSG_TWEET=${MSG_TWEET}${MSG_RAIN} 
		
		# msg short
		msgShort
		
		# check wind
		checkWind
		
		# check rain meter
		checkRainmeter
	# Sunny
	elif [ `grep ${WE_S} ${FILE_RESULT} | wc -l` -ge `grep ${WE_C} ${FILE_RESULT} | wc -l` ]
	then
		MSG_TWEET=${MSG_SUNNY}
	# Cloudy
	else
		MSG_TWEET=${MSG_CLOUDY}
	fi
}

##################
# Rain Meter Function
##################
function checkRainmeter()
{
	# Set Today Max Rain Level 0~999
	TODAY_MAX_RAIN_LEVEL=`echo ${array_rain[@]} | sed 's/ /\n/g' | grep -E [[:digit:]] | sort -r | head -n 1`

	# Check Rain Level from Template
	for (( X = 0; X < ${#INDEX_RAIN_LEVEL[@]}; ++X ))
	do
		# check rain meter
		if [ ${TODAY_MAX_RAIN_LEVEL} -le ${INDEX_RAIN_LEVEL[$X]} ]
		then
			# Set Rain Level. and Return function.
			INDEX_RAIN_LEVEL_TODAY=${X}
			MSG_TWEET=${MSG_TWEET}${MSG_RAIN_METER_MSG[$INDEX_RAIN_LEVEL_TODAY]}
			return 0
		fi
	done
}

##################
# Msg Short Function
##################
function msgShort()
{
	for (( Z = 0; Z < ${#MSG_BEFORE[@]}; ++Z ))
	do
		MSG_TWEET=`echo ${MSG_TWEET} | sed -s "s/${MSG_BEFORE[$Z]}/${MSG_AFTER[$Z]}/g"`
	done
}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

# Get Wether file from bb excite wether site.

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

# Twitter Acount Name.
# Use Default User.
TW_USER=''

# Wget Retry Counter
RETRY='3'

# News Key words
WE_R='雨'
WE_S='晴'
WE_C='曇'
WE_SN='雪'

# My Room news
ROOM_NEWS='南'

# Array Setting
array_time=()
array_rain=()
array_wind=()
array_news=()
array_wether=()
array_result=()

# Grep Key Word
KEY_1='<th>降水量</th>'
KEY_2='予報時刻</th>'
KEY_3='<th>風向き<br>風速</th>'

# Message
MSG_SUNNY='今日は天気( ・∀・)ｲｲ!!'
MSG_CLOUDY='今日は曇りやね(´・ω・｀)'
MSG_RAIN='に雨が降るので注意！(；´Д`)'
MSG_RAIN_ALL='今日は一日雨っぽい(ﾉД`)'
MSG_SNOW='今日雪降るってよ(｡・ω・)'
MSG_ERR='お天気鯖落ちてる？´・ω・)(・ω・｀'
MSG_NEWS='窓の開けっ放しに注意！'
MSG_TWEET=''
MSG_BOT='[自動ツイート]'

# Message from Version 1.4
MSG_RAIN_METER_MSG=( \
"ダッシュでなんとかなるかも。" \
"折りたたみでOK。" \
"ちゃんとした傘要るよ！" \
"雨の量SUGEEEE!!11" \
)
INDEX_RAIN_LEVEL=( 0 1 2 999)
INDEX_RAIN_LEVEL_TODAY=0
TODAY_MAX_RAIN_LEVEL=0

# Msg Short Version 1.5
MSG_BEFORE=( \
"午前中,昼間,おやつ時,夕方" \
"昼間,おやつ時,夕方,夜" \
"午前中,昼間,おやつ時" \
"昼間,おやつ時,夕方" \
"おやつ時,夕方,夜" \
"午前中,昼間" \
"昼間,おやつ時" \
"おやつ時,夕方" \
"夕方,夜" \
)

MSG_AFTER=( \
"午前中～夕方" \
"昼間～夜" \
"午前中～おやつ時" \
"昼間～夕方" \
"おやつ時～夜" \
"午前中～昼間" \
"昼間～おやつ時" \
"おやつ時～夕方" \
"夕方～夜" \
)

# Get Wether
getWether

# Create Temp Wether File.
cat ${FILE} | sed -n `grep -n title-spot ${FILE} | head -n 1 | cut -d ":" -f 1`,`grep -n title-spot ${FILE} | tail -n 1 | cut -d ":" -f 1`p > ${FILE_TEMP}

# SetWetherdata
setWetherdata

# Delete Result File.
test -e ${FILE_RESULT} && rm ${FILE_RESULT}
test -e ${FILE_TEMP} && rm ${FILE_TEMP}

# Set Data for 9:00~21:00
for (( I = 0; I < ${#array_rain[@]}; ++I ))
do
	echo ${array_time[$I]} ${array_rain[$I]} ${array_news[$I]} ${array_wind[$I]} ${array_wether[$I]} | grep -v "0:00\|3:00\|6:00" >> ${FILE_RESULT}
done

# Create Wether Msg.
createWethermsg

# Tweet!
sendTwitter

# Delete Temp Files.
test -e ${FILE_RESULT} && rm ${FILE_RESULT}
test -e ${FILE_TEMP} && rm ${FILE_TEMP}
test -e ${FILE} && rm ${FILE}

