#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/21
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
	grep 'class="hb-entry-link-container"' ${FILE_ORIGIN} \
	| grep 'class="hb-entry-link-container"' \
	| awk -Ftitle=\" '{print $2 $1}' \
	| sed -E 's/\"[[:space:]]data-entryrank=.+<a[[:space:]]href=\"/ /g' \
	| sed -E 's/\"[[:space:]]class=\".*//g' \
	| sort \
	> ${FILE_TEMP_NEW}
}

# Hatebu News Page Diff Check
function HtmlDiffCheck()
{
	# Old File Check
	test -e ${FILE_TEMP_OLD} || return

	# Diff Check
	comm ${FILE_TEMP_NEW} ${FILE_TEMP_OLD} | grep -Ev ^[[:space:]]+ > ${FILE_TEMP_TMP} && TweetHatebu
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

# Target SITE_DATA.
SITE_DATA=(`cat ${TARGET_LIST} | grep -v ^#`)

# Bot Message
MSG_BOT='[自動ツイート]'

# Analyze Function
for (( count=0; count<${#SITE_DATA[*]}; count++ ))
do
	# Set Temp File Name.
	FILE_ORIGIN=`echo /tmp/hatebu-``echo ${SITE_DATA[$count]} | sed -e 's/http.*\///g' -e 's/,.*//g'``echo .html`
	FILE_TEMP_NEW=`echo /tmp/hatebu-``echo ${SITE_DATA[$count]} | cut -d ',' -f 1 | awk -F\/ '{print $5}'``echo .html.new`
	FILE_TEMP_OLD=`echo /tmp/hatebu-``echo ${SITE_DATA[$count]} | cut -d ',' -f 1 | awk -F\/ '{print $5}'``echo .html.old`
	FILE_TEMP_TMP=`echo /tmp/hatebu-``echo ${SITE_DATA[$count]} | cut -d ',' -f 1 | awk -F\/ '{print $5}'``echo .html.tmp`

	# Set Url.
	URL=`echo ${SITE_DATA[$count]} | cut -d ',' -f 1`

	# Set Key Word.
	KEY_WORD=''
	if [ ! `echo ${SITE_DATA[$count]} | sed -e 's/[^,]//g' | wc -c ` == 1 ]
	then
		KEY_WORD=`echo ${SITE_DATA[$count]} | cut -d , -f 2- | sed 's/^/grep\,/g' | sed 's/,/\ -ie\ /g'`
	fi

	# WebCroll.
	WebCroller "${KEY_WORD}"

	# Clean Up Temp File.
	rm -f ${FILE_ORIGIN} ${FILE_TEMP_TMP}
done

