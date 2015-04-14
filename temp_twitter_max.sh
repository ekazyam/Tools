#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2014/06/20
# Ver   : 1.2
################################
# Common Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
DAY=`date +"%m月%d日" --date "1 day ago"`
MAX_TEMP=null
FILE='/tmp/1_temp.html'

# Temp Border Setting
FUYU_TEMP=18.0
NATU_TEMP=30.0
MANATU_TEMP=34.0

# Message Setting
MSG_BOT='[自動ツイート]'
DEF_MSG='(｀・ω・´)b快適'
FUYU_MSG='寒い(((〃´Д｀)(´Д｀〃)))ﾈｰ'
NATU_MSG='｡ﾟ(;･д･Ａ)ｱﾁｨ･･･'
MANATU_MSG='⊂⌒~⊃｡Д｡)⊃ ﾋﾟｸﾋﾟｸ'

# File Not Exist
test -e ${FILE} || exit

# Main Function
array=()
array=(`grep "00:00" -A 23 ${FILE} | cut -d "," -f 2`)
for (( I = 0; I < ${#array[@]}; ++I ))
do
	if [ ${MAX_TEMP} = "null" ]
	then
		MAX_TEMP=${array[$I]}
	else
		if [ ${array[$I]} != "null" ]
		then
			if [ `echo "${MAX_TEMP} < ${array[$I]}" | bc` -eq 1 ]
			then
				MAX_TEMP=${array[$I]}
			fi
		fi
	fi
done

# Tempture null Exception
[ "${MAX_TEMP}" = "null" ] && exit

# Debug
#MAX_TEMP=14.0

# Tempture Message Select
if [ `echo "${MAX_TEMP} < ${FUYU_TEMP}" | bc` -eq 1 ]
then
	MSG=${FUYU_MSG}
elif [ `echo "${MAX_TEMP} >= ${MANATU_TEMP}" | bc` -eq 1 ]
then
	MSG=${MANATU_MSG}
elif [ `echo "${MAX_TEMP} >= ${NATU_TEMP}" | bc` -eq 1 ]
then
	MSG=${NATU_MSG}
else
	MSG=${DEF_MSG}
fi

# tweet
#echo ${MSG_BOT}${DAY}" の最高気温は" $MAX_TEMP "度でした。${MSG}" && exit
yes | tw ${MSG_BOT}${DAY}" の最高気温は" $MAX_TEMP "度でした。${MSG}"
