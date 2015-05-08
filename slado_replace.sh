#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/05/09
# Ver   : 1.0.0
################################
# Replace to New Domain.
function ReplaceDomain()
{
	# Replace.
	sed -i -e "s/${REPLACE_DOMAIN}/${REPLACEMENT_DOMAIN}/g" ${TARGET_TEXT}

	# End Shell Script.
	exit
}

################################
# Main Function
################################

# Target URL.
URL='http://slashdot.jp'

# Target URL Text.
TARGET_TEXT='/home/pi/tools/target_list_slado.txt'

# Replace Domain.
REPLACEMENT_DOMAIN='srad.jp'
REPLACE_DOMAIN='slashdot.jp'

# Wait Timer.
TIMER='60s'

# Retry Ping.
RETRY=2

# Sleep at Change Domain.
while [ 1 ]
do
	# Check Ping.
	httping -c ${RETRY} ${URL} > /dev/null 2>&1 || ReplaceDomain

	# Wait.
	sleep ${TIMER}
done
