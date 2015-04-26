#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/27
# Ver   : 0.9beta
################################
# Web Page Crolling.
function WebCroller()
{
	# Web Page Download.
	wget -q ${URL} -O ${FILE_ORIGIN}

	# Web Page Analyze
	HtmlAnalyze

	# Key Word Check.
	test -n "${KEY_WORD}" && KeyWordCheck

	# Diff Check
	HtmlDiffCheck
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
	test -e ${FILE_TEMP_NEW} && mv ${FILE_TEMP_NEW} ${FILE_TEMP_OLD}

	# Convert to News Title and SITE_DATA
	grep -A 1 "<title>" ${FILE_ORIGIN} \
	| grep -vE ^-- \
	| sed -E 's/^[[:space:]]+<(title|link)>//g' \
	| tr  '\n' ' ' \
	| sed 's/<\/link>/\n/g' \
	| sed -s 's/<\/title>//g' \
	| grep -v ${HATEBU} \
	| grep -Ev ^[[:space:]]+$ \
	| sed -E 's/^[[:space:]]+//' \
	| sort \
	> ${FILE_TEMP_NEW}
}

# Hatebu News Page Diff Check
function HtmlDiffCheck()
{
	# Old File Check
	test -e ${FILE_TEMP_OLD} || return

	# Diff Check
	diff ${FILE_TEMP_NEW} ${FILE_TEMP_OLD} | grep -E "^>" | sed -E 's/^>[[:space:]]+//g' > ${FILE_TEMP_TMP} && TweetHatebu
}

# FooterSetting for TempFileName.
function SetFooter()
{
	FOOTER="normal"
	echo ${SITE} | grep -E "http.+hotentry\/.+\.rss" > /dev/null 2>&1 && FOOTER="hot"
	echo ${SITE} | grep -E "http.+entrylist\/.+\.rss" > /dev/null 2>&1 && FOOTER="ent"
}

# TmpFileName Setting.
function SetTmpFileName()
{
	FILE_ORIGIN=`echo ${TMP_DIR}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-org`
	FILE_TEMP_NEW=`echo ${TMP_DIR}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-new`
	FILE_TEMP_OLD=`echo ${TMP_DIR}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-old`
	FILE_TEMP_TMP=`echo ${TMP_DIR}${SITE} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-tmp`
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
		| sed -e 's/^/,/' \
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
function TweetHatebu()
{
	while read NEWS_MSG; do
		yes | tw ${MSG_BOT}${NEWS_MSG}
	done < ${FILE_TEMP_TMP}
}

# Check Function
function Analyze()
{
	# Set Site Data.
	SITE=${1}

	# Multi Process View Debug
	#echo ${SITE}

	# Target URL Bit Check
	if [ `echo ${SITE} | cut -d ',' -f 1` == ${CHECK_URL} ]
	then
		# Set Footer.
		SetFooter
 
		# Set Temp File Name.
		SetTmpFileName
		
		# Set Url.
		SetUrl

		# Set Key Word.
		SetKeyWord

		# WebCroll.
		WebCroller "${KEY_WORD}"

		# Clean Up Temp File.
		rm -f ${FILE_ORIGIN} ${FILE_TEMP_TMP}
	fi

}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Target SITE_DATA List.
TARGET_LIST=`dirname $0`'/target_list.txt'

# Hatebu URL
HATEBU="http://b.hatena.ne.jp/hotentry/"

# Target SITE_DATA.
SITE_DATA=(`cat ${TARGET_LIST} | grep -v ^#`)

# Bot Message
MSG_BOT='[自動ツイート]'

# Check URL On
CHECK_URL="1"

# Key Word.
KEY_WORD=''

# Tmp File Directory
TMP_DIR="/tmp/hatebu-"

# Max Process at This Script.
# 0	: Unlimited.
# 1 - n : 
MAX_P=0

# Function Export.
export -f Analyze HtmlAnalyze HtmlDiffCheck KeyWordCheck SetFooter SetKeyWord SetTmpFileName SetUrl TweetHatebu WebCroller

# Data Export.
export CHECK_URL HATEBU KEY_WORD MSG_BOT PATH TMP_DIR

# Analyze Function for Multi Process.
echo ${SITE_DATA[@]} | sed 's/ /\n/g' | xargs -P${MAX_P} -n1 -I % bash -c "Analyze %"

