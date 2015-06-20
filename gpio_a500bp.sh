#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/06/21
# Ver   : 0.9.0
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
		if [ `cat ${TARGET_DIR}/value` == 0 ]
			# Sensor On.
			echo "ON."
		else
			# Sensor Off.
			echo "OFF."
		fi
		sleep ${TIME}
	done	
}

#####################
# Main Function.
#####################
# GPIO No
GPIO=25

# Wait Time.
TIME=1s

# Target Directory.
TARGET_DIR="/sys/class/gpio/gpio${GPIO}"


# Init Gpio.
initGpio

# Check Gpio.
checkGpio
