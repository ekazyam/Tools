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
	test -e ${FILE_TEMP_NEW} || exit

	# Rename New File to Old File
	mv ${FILE_TEMP_NEW} ${FILE_TEMP_OLD}

	# Convert to News Title and URL
	grep 'class="hb-entry-link-container"' ${FILE} \
	| awk -Fdata-entryrank=\" {'print $1}' \
	| awk -Fclass=\"entry-link\" '{print $2 $1 }' \
	| sed -E 's/[[:space:]]+title="//g' \
	| sed -E 's/\"[[:space:]]+<h3.*href="/ /g' \
	| sed -e 's/\" $//g' \
	> ${FILE_TEMP_NEW}
}

# Hatebu News Page Diff Check
function HtmlDiffCheck()
{
	# Diff Check
	diff ${FILE_TEMP_NEW} ${FILE_TEMP_OLD} | grep -e ^\< | sed -E 's/<[[:space:]]//g'
}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Target URL.
URL=(
"http://b.hatena.ne.jp/hotentry/it"
"http://b.hatena.ne.jp/hotentry/general"
)

# Hatebu Html File.
FILE='/tmp/hatebu.html'

# Analyze Function
for (( count=0; count<${#URL[*]}; count++ ))
do
	# Set Temp File Name.
	FILE_TEMP_NEW=`echo /tmp/hatebu-``echo ${URL[$count]} | awk -F\/ '{print $5}'``echo .html.new`
	FILE_TEMP_OLD=`echo /tmp/hatebu-``echo ${URL[$count]} | awk -F\/ '{print $5}'``echo .html.old`

	# WebCroll.
	WebCroller
done

