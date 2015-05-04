#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/05/04
# Ver   : 1.1.1
################################
# Usage
function Usage()
{
	Msg=$1
	echo "[notice]"  
	echo "$Msg"
	echo
        echo "[e.g.]"
        echo "search LinkSearch.sh [option] [directory]"
	echo
	echo "[option]"
	echo "-r --reverse	Print Called html or php to Calling html or php."
        exit
}

# Check for option.
function CheckOption()
{
	# Arg Check for option.
	if [ $# -eq 2 ] && ([ $1 == '-r' ] || [ $1 == '--reverse' ])
	then
		# Set Search Directory.
		SEARCH_DIR=$2
		
		# Set Flag.
		FLAG=1
	elif [ $# -eq 2 ] && ( [ ! $1 == '-r' ] || [ ! $1 == '--reverse' ] )
	then
		Usage ${MSG_ERR[3]}
	else
		# Set Search Directory.
		SEARCH_DIR=$1
	fi
}

# Search html or php call
function Search()
{
	if [ $# -eq 1 ]
	then
		# Normal.
		echo '[ FROM ] -> [ TO ]'
		grep -ER '(href\ ?=\ ?.+\.(php|html)|(include|require(_once)?).+\.(php|html))' $1 | grep -E '^.+\.(php|html)' | grep -Eo '.*\.(php|html)' | sed -E 's/[!?#$%&()<>{}='\''\":;]/\ /g' | sed -e 's/\ /\ \ /g' | sed -E 's/[[:space:]]{2}.*[[:space:]]{2}/\ /g'| awk -F' ' '{print $1,"->",$2}' | sort
	else
		# Reverse.
		echo '[ TO ] -> [ FROM ]'
		grep -ER '(href\ ?=\ ?.+\.(php|html)|(include|require(_once)?).+\.(php|html))' $1 | grep -E '^.+\.(php|html)' | grep -Eo '.*\.(php|html)' | sed -E 's/[!?#$%&()<>{}='\''\":;]/\ /g' | sed -e 's/\ /\ \ /g' | sed -E 's/[[:space:]]{2}.*[[:space:]]{2}/\ /g'| awk -F' ' '{print $2,"->",$1}' | sort
	fi
}

################################
# Main Function
################################

# Setting for Separetor. 
IFS=,

# Option.
FLAG=0

# Setting for Err Msg.
MSG_ERR=('Invalid Arg.' 'Too may Arg.' 'Directory is not found.' 'Invalid Option.')

# Arg Check for not exist args.
test $# -eq 0 && Usage ${MSG_ERR[0]}

# Arg Check for too many args.
test $# -ge 3 && Usage ${MSG_ERR[1]}

CheckOption $1 $2

# Arg Check for directory.
test -d ${SEARCH_DIR} || Usage ${MSG_ERR[2]}

# Search php or html link.
test 1 -eq ${FLAG} && Search ${SEARCH_DIR} ${FLAG}
test 0 -eq ${FLAG} && Search ${SEARCH_DIR} 

# Function End.
exit
