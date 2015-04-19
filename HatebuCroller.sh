#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/19
# Ver   : 0.9beta
################################
# Web Page Crolling.
function WebCroller()
{
	# Web Page Download.
	wget -q ${URL[$count]} -O ${FILE}

	# Web Page Analyze
	HtmlAnalyze

	# Diff Check
	HtmlDiffCheck
}

# Hatebu News Page Analyze
function HtmlAnalyze()
{
	# Html File Exist Check
	test -e ${FILE_TEMP_NEW} && mv ${FILE_TEMP_NEW} ${FILE_TEMP_OLD}

	# Convert to News Title and URL
	grep 'class="hb-entry-link-container"' ${FILE} \
	| grep 'class="hb-entry-link-container"' hatebu.html \
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
		echo ${NEWS_MSG}{$NEWS_MSG}
		#yes | tw ${NEWS_MSG}{$NEWS_MSG}
	done < ${FILE_TEMP_TMP}
}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Target URL.
URL=(
"http://b.hatena.ne.jp/hotentry/it"
)

# Hatebu Html File.
FILE='/tmp/hatebu.html'

# Bot Message
MSG_BOT='[自動ツイート]'

# Analyze Function
for (( count=0; count<${#URL[*]}; count++ ))
do
	# Set Temp File Name.
	FILE_TEMP_NEW=`echo /tmp/hatebu-``echo ${URL[$count]} | awk -F\/ '{print $5}'``echo .html.new`
	FILE_TEMP_OLD=`echo /tmp/hatebu-``echo ${URL[$count]} | awk -F\/ '{print $5}'``echo .html.old`
	FILE_TEMP_TMP=`echo /tmp/hatebu-``echo ${URL[$count]} | awk -F\/ '{print $5}'``echo .html.tmp`

	# WebCroll.
	WebCroller
done

