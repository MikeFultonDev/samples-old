#!/bin/sh
if [[ $# -lt 1 ]]; then
	echo "Syntax: setpasswd.sh <userid> : set the initial password of the z/OS user <userid>"
	exit 16
fi
id=`echo $1 | tr [:lower:] [:upper:]`
primary=`echo ${ZOS_USER} | tr [:lower:] [:upper:]`

if [ "${id}" == "${primary}" ]; then
	# Just need to log in and have them enter new password
	${SSH} ${primary}@${ZOS_HOST}
else
	${SSH} ${primary}@${ZOS_HOST} "tsocmd 'ALTUSER ${id} PASS(CHANGEME) RESUME'"
	# Now they can just log in and enter new password
	${SSH} ${id}@${ZOS_HOST}
fi
