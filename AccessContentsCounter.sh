#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/05/10
# Ver   : 0.3.0
################################
# Contents Count For Zip Data.
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
		echo -e `zgrep "${TARGET_FILE}" "${TARGET_LOG}" | wc -l`"\t${TARGET_FILE}" | tee -a ${RESULT_LOG} 
	done
}

# Contents Count For Text Data.
function ContentCountFast()
{
	TARGET_FILE=${1}
	echo -e `grep "${TARGET_FILE}" "${TARGET_LOG}" | wc -l`"\t${TARGET_FILE}" | tee -a ${RESULT_LOG}
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

# Search Start.
# linear: zip
# multi : ascii
function SearchStart()
{
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

			if [ ${TARGET_KIND[0]} == ${KIND} ]
			then
				# Contents Count for zip.
				ContentCount ${LOG_KIND}
			else
				# Contents Count for text.
				echo ${CONTENTS[@]} | sed 's/ /\n/g' | xargs -P${MAX_P} -n1 -I % bash -c "ContentCountFast %"
			fi
			
		fi
	done
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

# Max Process.
MAX_P=4

# Export
export -f SetContents SetResultLog SetLogKind ContentCount ContentCountFast
export WORK_DIR TARGET_KIND MAX_P TARGET_LOG RESULT_LOG

for (( Z = 0; Z < ${#LOGS[@]}; ++Z ))
do
	# Start.
	SearchStart
done
