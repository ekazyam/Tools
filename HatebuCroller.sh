#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/19
# Ver   : 0.9
################################

##################
# Web Croller
##################

# Web Page Crolling.
function WebCroller()
{
	# Web Page Download.
	wget -q ${URL} -O ${FILE}

	# Web Page Analyze
	HtmlAnalyze

	# Diff Check
	#HtmlDiffCheck
}

# Hatebu News Page Analyze
function HtmlAnalyze()
{
	# Old News Page Moving
	mv ${FILE_TEMP_NEW} ${FILE_TEMP_OLD}

	# Convert to News Title and URL
	grep 'class="hb-entry-link-container"' hatebu-it.html \
	| awk -Fdata-entryrank=\" {'print $1}' \
	| awk -Fclass=\"entry-link\" '{print $2 $1 }' \
	| sed -E 's/[[:space:]]+title="//g' \
	| sed -E 's/\"[[:space:]]+<h3.*href="/ /g' \
	| sed -e 's/\" $//g' \
	> ${FILE_TEMP_NEW}
}

# Hatebu News Page Diff Check
#function HtmlDiffCheck()
#{
	# Diff Check
#}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Target URL.
URL='http://b.hatena.ne.jp/hotentry/it'

# Temp Files.
FILE='/tmp/hatebu-it.html'
FILE_TEMP_NEW='/tmp/hatebu.html.new'
FILE_TEMP_OLD='/tmp/hatebu.html.old'

# WebCroll.
WebCroller

