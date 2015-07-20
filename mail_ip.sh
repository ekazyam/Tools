################################
# Author: Rum Coke
# Data  : 2015/07/20
# Ver   : 1.0.1
################################

################################
# Send Mail.
################################
function sendMail()
{
	showIP | mail -s "${SUBJECT}" --to "${TO_ADDRESS}"
}

################################
# Print IP.
################################
function showIP()
{
	ifconfig
}

################################
# Print Hostname.
################################
function setSubject()
{
	WORK=`uname -n`
	SUBJECT="${SUBJECT} Host:${WORK}"
}

################################
# Main Function.
################################

# Mail Address.
TO_ADDRESS='your mail address'

# Mail Header Msg.
SUBJECT='[myserver]'

# SetSubject.
setSubject

# SendMail.
sendMail

