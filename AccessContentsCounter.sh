#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/05/09
# Ver   : 0.1.0
################################
# Contents Count.
function ContentCount()
{
	# Set Target File Name.
	TARGET_FILE=${1}

	# Search Target File and Access Count.
	echo -e `grep "${TARGET_FILE}" "${LOG}" | wc -l`"\t${TARGET_FILE} "
}

##################
# Main Function
##################
# Access Log.
LOG='/var/log/nginx/access.log'

# Set Contents
CONTENTS=( `awk -F' ' '{ print $7 }' ${LOG} | sed 's/\?.*$//g' | sort | uniq` )

# Show Title.
echo -e "[Count]\t[File]"

# Search Key Word.
for (( I = 0; I < ${#CONTENTS[@]}; ++I ))
do
	ContentCount ${CONTENTS[$I]}
done
