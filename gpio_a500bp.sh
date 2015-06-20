#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/06/21
# Ver   : 0.9.1
################################
function initGpio()
{
	# Check Init GPIO
	if [ ! -e "${TARGET_DIR}" ]
	then
		# Init GPIO
		echo "$GPIO" > /sys/class/gpio/export
	fi
}

function checkGpio()
{
	while true
	do
		if [ `cat ${TARGET_DIR}/value` == ${ON} ]
		then
			# Sensor On.
			echo "ON."
			
			# Execute.
			executeCmd
		else
			# Sensor Off.
			echo "OFF."
		fi

		# Wait.
		sleep ${TIME}
	done	
}

function executeCmd()
{
	echo "Execute!"

	# Wait.
	sleep ${TIME_CMD}
}

#####################
# Main Function.
#####################
# GPIO No
GPIO=25

# Wait Time.
TIME=10s

# Wait for Cmd.
TIME_CMD=5s

# Target Directory.
TARGET_DIR="/sys/class/gpio/gpio${GPIO}"

# On
ON=1

# Init Gpio.
initGpio

# Check Gpio.
checkGpio

# End Function. #
