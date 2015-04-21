#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/04/21
# Ver   : 1.0
################################

# Path Setting.
P_PATH="/tmp/index.php"

# Set Html Header.
echo "<html>" > ${P_PATH}

# Create Links at Html File
ls *.php | awk '{ print $1" "$1 }' | sed -E 's/[[:space:]]/" target="_blank">/' | sed -e 's/^/<li><a href="/' -e 's/$/<\/a><\/li><br>/' >> ${P_PATH}

# Set Html Footer.
echo "</html>" >> ${P_PATH}

