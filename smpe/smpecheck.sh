#!/bin/sh
#
# smpecheck - check that there is sufficient space to do a receive
#
export MINTMP=10000000
export SMPPTS_PATTERN="MVS.GLOBAL.SMPPTS*"
#set -x
function freespace {
	volume=$1
	
	df -kP ${volume} | tail +2 | awk ' { print $4; }'
}
if [[ "${TMP}" == "" ]]; then 
	if [[ "${TMPDIR}" == "" ]]; then	
		tmp="/tmp"
		env="Neither TMP nor TMPDIR"    
	else
		tmp="${TMPDIR}"
		env="TMPDIR"
	fi
else
	tmp="${TMP}"
	env="TMP"
fi

if [ -d ${tmp} ]; then 
	;
else
	echo "${env} is set but directory ${tmp} does not exist. smpecheck failed."
	exit 16
fi 

space=`freespace ${tmp}`
if [[ ${space} -lt ${MINTMP} ]]; then
	echo "There is only ${space} KB left on your ${tmp} directory. You need at least ${MINTMP} KB."
	exit 16
fi	
