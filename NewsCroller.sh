#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/05/04
# Ver   : 1.3
################################
# Web Page Crolling.
function WebCroller()
{
	# Web Page Analyze
	HtmlAnalyze

	# Key Word Check.
	test -n "${KEY_WORD}" && KeyWordCheck

	# Diff Check
	HtmlDiffCheck
}

# Get Rss File From Web.
function GetRss()
{
	# Web Page Download.
	wget -q ${URL} -O ${FILE_ORIGIN}
}

# Key Word Check.
function KeyWordCheck()
{
	# Create Temp File.
	echo ${KEY_WORD} | grep '|' > /dev/null 2>&1 || CMD_EXE="${KEY_WORD} ${FILE_TEMP_NEW}"
	echo ${KEY_WORD} | grep '|' > /dev/null 2>&1 && CMD_EXE=`echo ${KEY_WORD/\ \|\ /\ ${FILE_TEMP_NEW}\ \|\ }`
	eval ${CMD_EXE} > ${FILE_TEMP_TMP}
	cat ${FILE_TEMP_TMP} > ${FILE_TEMP_NEW}
}

# Hatebu News Page Analyze
function HtmlAnalyze()
{
	# Html File Exist Check
	if [ -e  ${FILE_TEMP_NEW} ]
	then
		# Set Uniq History Data.
		cat ${FILE_TEMP_NEW} ${FILE_TEMP_OLD} > ${FILE_TEMP_TMP}
		cat ${FILE_TEMP_TMP} | sort | uniq >  ${FILE_TEMP_OLD}
	fi

	# Convert to News Title and SITE_DATA
	grep -A 1 "<title>" ${FILE_ORIGIN} \
	| grep -vE ^-- \
	| sed -E 's/^[[:space:]]+<(title|link)>//g' \
	| tr  '\n' ' ' \
	| sed 's/<\/link>/\n/g' \
	| sed -s 's/<\/title>//g' \
	| grep -Ev "${VALID_DATA}" \
	| grep -Ev ^[[:space:]]+$ \
	| sed -E 's/^[[:space:]]+//' \
	| grep -E 'http[s]{0,1}' \
	| sort \
	> ${FILE_TEMP_NEW}
}

# Hatebu News Page Diff Check
function HtmlDiffCheck()
{
	# Old File Check
	if [ `wc -l ${FILE_TEMP_OLD} | awk '{print $1}'` -eq 0 ]
	then
		return
	fi

	# Diff Check
	cat ${FILE_TEMP_OLD_1} ${FILE_TEMP_OLD_2} | sort | uniq |  comm -23 ${FILE_TEMP_NEW} - > ${FILE_TEMP_TMP} && TweetNews
}

# FooterSetting for TempFileName.
function SetFooter()
{
	FOOTER="normal"
	echo ${SITE} | grep -E "http.+hotentry\/.+\.rss" > /dev/null 2>&1 && FOOTER="hot"
	echo ${SITE} | grep -E "http.+entrylist\/.+\.rss" > /dev/null 2>&1 && FOOTER="ent"
}

# HeaderSetting for TempFileName.
function SetHeader()
{
	HEADER=(`grep -E '^#!,' ${TARGET_LIST} | awk -F"," '{ print $3 }'`)
}

# Set History File.
function SetHistoryFile()
{
	# File Exist Check.
	if [ ! -e ${FILE_TEMP_OLD_1} ]
	then
		# write to .old.1
		FILE_TEMP_OLD=${FILE_TEMP_OLD_1}

		# crete .old.1
		touch ${FILE_TEMP_OLD_2} 

		# old.1 file is newer than old.2 file.
		sleep 1s

		# crete .old.2
		touch ${FILE_TEMP_OLD_1} 
		return
	fi

	# New File Check.
	if [ ${FILE_TEMP_OLD_1} -nt ${FILE_TEMP_OLD_2} ]
	then
		# FILE_TEMP_OLD_1 is new
		if [ `wc -l ${FILE_TEMP_OLD_1} | awk '{print $1}'` -lt ${COUNT_HIST} ]
		then
			# write to .old.1
			FILE_TEMP_OLD=${FILE_TEMP_OLD_1}
		else
			# write to .old.2
			FILE_TEMP_OLD=${FILE_TEMP_OLD_2}
			ClearHistoryFile ${FILE_TEMP_OLD}
		fi
	else
		# FILE_TEMP_OLD_2 is new
		if [ `wc -l ${FILE_TEMP_OLD_2} | awk '{print $1}'` -lt ${COUNT_HIST} ]
		then
			# write to .old.2
			FILE_TEMP_OLD=${FILE_TEMP_OLD_2}
		else
			# write to .old.1
			FILE_TEMP_OLD=${FILE_TEMP_OLD_1}
			ClearHistoryFile ${FILE_TEMP_OLD}
		fi
	fi
}

# Clear History File.
function ClearHistoryFile()
{
	# Make Clear File at mod cmd.
	:> $1
}

# TmpFileName Setting.
function SetTmpFileName()
{
	FILE_ORIGIN=`echo ${TMP_DIR}${HEADER}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-org`
	FILE_ORIGIN_OLD=`echo ${TMP_DIR}${HEADER}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-org.old`
	FILE_TEMP_NEW=`echo ${TMP_DIR}${HEADER}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-new`
	FILE_TEMP_OLD_1=`echo ${TMP_DIR}${HEADER}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-old.1`
	FILE_TEMP_OLD_2=`echo ${TMP_DIR}${HEADER}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-old.2`
	FILE_TEMP_TMP=`echo ${TMP_DIR}${HEADER}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-tmp`
	SetHistoryFile
}

# Url Setting.
function SetUrl()
{
	URL=`echo ${SITE} | cut -d ',' -f 2`
}

# KeyWord Setting.
function SetKeyWord()
{
	# Set Key Word.
	KEY_WORD=''

	# Check Keyword Exist.
	if [ `echo ${SITE} | sed -e 's/[^,]//g' | wc -c ` != 2 ]
	then
		# Valid Data Exist.
		KEY_WORD=`echo ${SITE} \
		| cut -d , -f 3- \
		| sed -e 's/,/\n/g' \
		| sort -r \
		| sed -e 's/$/,/g' \
		| tr -d '\n' \
		| sed -e 's/,$//' \
		-e 's/^/,/' \
		-e 's/,/'\'','\''/g' \
		-e 's/$/'\''/' \
		-e 's/,'\''#/\ egrep\ -v\ -ie\ '\''/' \
		-e 's/'\''\ \|//' \
		-e 's/\ egrep/\ \|\ egrep/' \
		-e 's/,'\''#/\ -ie\ '\''/g' \
		-e 's/^'\'',/grep\ -ie\ /' \
		-e 's/,/\ -ie\ /g' \
		`
	fi
}

# Twitter
function TweetNews()
{
	while read NEWS_MSG; do
		yes | tw -silent ${MSG_BOT}${NEWS_MSG}
	done < ${FILE_TEMP_TMP}
}

# Usage
function Usage()
{
	echo "e.g."
	echo "croll NewsCroller.sh target_list_hatebu.txt"
	exit
}

# Check Function
function Analyze()
{
	# Set Site Data.
	SITE=${1}

	# Valid Data.
	VALID_DATA=(`grep -E '^#!,' ${TARGET_LIST} | awk -F"," '{ print $2 }'`)

	# Target URL Bit Check
	if [ `echo ${SITE} | cut -d ',' -f 1` == ${CHECK_URL} ]
	then
		# Set Header.
		SetHeader

		# Set Footer.
		SetFooter
 
		# Set Temp File Name.
		SetTmpFileName
		
		# Set Url.
		SetUrl

		# Set Key Word.
		SetKeyWord

		# Get Rss File.
		GetRss

		# Origin File Diff Check.
		if [ -e ${FILE_ORIGIN_OLD} ] && [ `md5sum ${FILE_ORIGIN} | awk '{print $1}'` != `md5sum ${FILE_ORIGIN_OLD} | awk '{print $1}'` ]
		then
			# Ditect Differ.
			# WebCroll.
			WebCroller "${KEY_WORD}"

			# Original File is Move to Old.
			mv ${FILE_ORIGIN} ${FILE_ORIGIN_OLD}
		elif [ ! -e ${FILE_ORIGIN_OLD} ]
		then
			# Old Origin not exist.
			# WebCroll.
			WebCroller "${KEY_WORD}"

			# Original File is Move to Old.
			mv ${FILE_ORIGIN} ${FILE_ORIGIN_OLD}
		fi

		# Clean Up Temp File.
		rm -f ${FILE_TEMP_TMP}
	fi

}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# TargetFile Check.
test $# -eq 1 || Usage

# Check TargetFile Exist.
test -e ${1} || Usage

# Set Target Site List.
TARGET_LIST=${1}

# Target SITE_DATA.
SITE_DATA=(`cat ${TARGET_LIST} | grep -v ^#`)

# Bot Message
MSG_BOT='[自動ツイート]'

# Check URL On
CHECK_URL="1"

# Max History.
COUNT_HIST='30'

# Key Word.
KEY_WORD=''

# Tmp File Directory
TMP_DIR="/tmp/"

# Max Process at This Script.
# 0	: Unlimited.
# 1 - n : 
MAX_P=0

# Function Export.
export -f Analyze ClearHistoryFile GetRss HtmlAnalyze HtmlDiffCheck KeyWordCheck SetFooter SetHeader SetHistoryFile SetKeyWord SetTmpFileName SetUrl TweetNews WebCroller

# Data Export.
export COUNT_HIST CHECK_URL VALID_DATA KEY_WORD MSG_BOT PATH TMP_DIR TARGET_LIST

# Analyze Function for Multi Process.
echo ${SITE_DATA[@]} | sed 's/ /\n/g' | xargs -P${MAX_P} -n1 -I % bash -c "Analyze %"

