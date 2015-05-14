#!/bin/bash

# Create mail header.
function CreateMailHeader()
{
	echo ${From}
	echo ${To}
	echo ${Subject}
	echo
	echo ${Header}
	echo ${Message}
	echo ${Hostname}
	echo ${Date}
}

# Set mail parameter.
function SetParameter()
{
	# Mail Header at From and To Field.
	From='From:hoge@fuga.co.jp'
	To='To:piyo@fuga.co.jp'

	# Mail Header at Message Field.
	Subject='Subject:[Attention] Server Rebooted.'
	Header='--------------------'
	Hostname='ホスト名：'`uname -n`
	Date='日付：'`date`
	Message='以下のサーバがリブートしました。'
}

#################
# Main function.
#################
# Usage:
# crontab -e
# @reboot /bin/bash /root/reboot_mail.sh
# 

# Set Parameter for Mail Header.
SetParameter

# Create Mail Data and Send mail.
CreateMailHeader | /usr/sbin/sendmail -i -t

