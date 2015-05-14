#!/bin/bash

# Create mail header.
function CreateMail()
{
	echo ${Header_From}
	echo ${Header_To}
	echo ${Header_Subject}
	echo
	echo ${Message}
	echo ${Hostname}
	echo ${Date}
}

# Define parameter.
function DefineParameter()
{
	# Mail Info.
	From='test@test.co.jp'
	To='hogehoge@co.jp'
	Subject='[通知]サーバー再起動'
	Message='以下のサーバがリブートしました。'
	Hostname='ホスト名：'`uname -n`
	Date='日付：'`date`
}

# Set mail Header.
function SetHeader()
{
	# Mail Header.
	Header_From='From:'${From}
	Header_To='To:'${To}
	Header_Subject=`echo ${Subject} | /usr/bin/base64 | tr -d \n`
	Header_Subject='Subject:=?utf-8?B?'"${Header_Subject}"'?='
}

#################
# Main function.
#################
# Define Parameter
DefineParameter

# Set Mail Header.
SetHeader

# Create Mail Data and Send mail.
CreateMail | /usr/sbin/sendmail -i -t

