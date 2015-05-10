#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/05/10
# Ver   : 0.2.0
################################
# Contents Count For Text Data.
function ContentCount()
{
	# Set File Kind.
	KIND=${1}

	# Search Data.
	for (( Y = 0; Y < ${#CONTENTS[@]}; ++Y ))
	do
		# Set Target File Name.
		TARGET_FILE=${CONTENTS[$Y]}
		
		# Search Target File and Access Count.
		test ${TARGET_KIND[0]} == ${KIND} && echo -e `zgrep "${TARGET_FILE}" "${TARGET_LOG}" | wc -l`"\t${TARGET_FILE}" | tee -a ${RESULT_LOG} 
		test ${TARGET_KIND[1]} == ${KIND} && echo -e `grep "${TARGET_FILE}" "${TARGET_LOG}" | wc -l`"\t${TARGET_FILE}" | tee -a ${RESULT_LOG}
	done
}

# Log Kind Setting.
function SetLogKind()
{
	# Set Log Kind.
	LOG_KIND=`echo ${TARGET_LOG} | file -b -f - | cut -d , -f 1 | cut -d ' ' -f 1`
}

# Result Log Name Setting.
function SetResultLog()
{
	# Result Log Nanem.
	RESULT_LOG=`echo ${WORK_DIR}/``echo ${TARGET_LOG} | sed 's/.*\///g'``echo ".result"`
}

# Contents Name Setting.
function SetContents()
{
	KIND=$1
	test ${TARGET_KIND[0]} == ${KIND} && CONTENTS=( `unzip -p ${TARGET_LOG} | awk -F' ' '{ print $7 }' | sed -r 's/(\=|\?).*$//g' | sort | uniq` )
	test ${TARGET_KIND[1]} == ${KIND} && CONTENTS=( `cat ${TARGET_LOG} | awk -F' ' '{ print $7 }' | sed -r 's/(\=|\?).*$//g' | sort | uniq` )
}

##################
# Main Function
##################
# Access Log Dir.
LOG_DIR='/var/log/nginx/work'

# Access Log.
LOGS=(`ls ${LOG_DIR}/*access.log*`)

# Work Directory.
WORK_DIR='/tmp'

# Supported Target File.
TARGET_KIND=("Zip" "ASCII")

for (( Z = 0; Z < ${#LOGS[@]}; ++Z ))
do
	# Set Target Log.
	TARGET_LOG=${LOGS[$Z]}

	# Result Log Nanem.
	SetResultLog

	# Set Log Kind.
	SetLogKind

	for (( X = 0; X < ${#TARGET_KIND[@]}; ++X ))
	do
		if [ ${TARGET_KIND[$X]} == ${LOG_KIND} ]
		then
			# Set Contents
			SetContents ${LOG_KIND}

			# Contents Count.
			ContentCount ${LOG_KIND}
		fi
	done
done

