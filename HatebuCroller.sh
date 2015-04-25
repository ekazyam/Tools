#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/25
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
	CMD_EXE="${KEY_WORD} ${FILE_TEMP_NEW}"
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
	| sort \
	> ${FILE_TEMP_NEW}
}

# Hatebu News Page Diff Check
function HtmlDiffCheck()
{
	# Old File Check
	test -e ${FILE_TEMP_OLD} || return

	# Diff Check
	diff ${FILE_TEMP_NEW} ${FILE_TEMP_OLD} | grep -E "^>" > ${FILE_TEMP_TMP} && TweetHatebu
}

# FooterSetting for TempFileName.
function SetFooter()
{
	FOOTER="normal"
	echo ${SITE_DATA[$count]} | grep -E "http.+hotentry\/.+\.rss" > /dev/null 2>&1 && FOOTER="hot"
	echo ${SITE_DATA[$count]} | grep -E "http.+entrylist\/.+\.rss" > /dev/null 2>&1 && FOOTER="ent"
}

# TmpFileName Setting.
function SetTmpFileName()
{
	FILE_ORIGIN=`echo ${TMP_DIR}${SITE_DATA[$count]} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-org`
	FILE_TEMP_NEW=`echo ${TMP_DIR}${SITE_DATA[$count]} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-new`
	FILE_TEMP_OLD=`echo ${TMP_DIR}${SITE_DATA[$count]} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-old`
	FILE_TEMP_TMP=`echo ${TMP_DIR}${SITE_DATA[$count]} | sed -E 's/[[:digit:]]}?,http.+\///g' | sed -s 's/,.*//g'``echo -${FOOTER}-tmp`
}

# Url Setting.
function SetUrl()
{
	URL=`echo ${SITE_DATA[$count]} | cut -d ',' -f 2`
}

# KeyWord Setting.
function SetKeyWord()
{
	# Set Key Word.
	KEY_WORD=''

	# Check Keyword Exist.
	if [ `echo ${SITE_DATA[$count]} | sed -e 's/[^,]//g' | wc -c ` != 2 ]
	then
		KEY_WORD=`echo ${SITE_DATA[$count]} | cut -d , -f 3- | sed 's/^/grep\,/g' | sed 's/,/\ -ie\ /g'`
	fi
}

# Twitter
function TweetHatebu()
{
	while read NEWS_MSG; do
		yes | tw ${MSG_BOT}${NEWS_MSG}
	done < ${FILE_TEMP_TMP}
}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Hatebu Html File.
FILE='/tmp/hatebu.html'

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

# Analyze Function
for (( count=0; count<${#SITE_DATA[*]}; count++ ))
do
	# Target URL Bit Check
	if [ `echo ${SITE_DATA[$count]} | cut -d ',' -f 1` == ${CHECK_URL} ]
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
done

