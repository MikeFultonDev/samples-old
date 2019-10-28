#!/bin/sh
set -x

crtds() {
	list=$1
	echo "$1" | awk '{ ds=$1; $1=""; attrs=$0; if ($ds != "") { rc=system("dtouch " attrs " " ds); if (rc > 0) { exit(rc); } } }'
	exit $?
}

props="./igy630.properties"

if [ -f ${props} ]; then
	value=`cat ${props}`
	OLDIFS=$IFS; IFS="
"
	for v in $value; do
		eval "$v";
	done	
	IFS=$OLDIFS
fi

ds="
    	${IGYHLQ}.SIGYCOMP -s150M -ru
	${IGYHLQ}.SIGYMAC -s1M
	${IGYHLQ}.SIGYPROC -s1M
	${IGYHLQ}.SIGYSAMP -s1M
"

out=`crtds "${ds}"`
rc=$?
if [ $rc -gt 0 ]; then
	echo "Installation Failed."
	exit $rc
fi

tempprefix="${IGYHLQ}T"
tempds=`mvstmp ${tempprefix}`
dtouch -tseq $tempds

jobcard="//IGYWIVP1   JOB ${JOBOPTS},${JOBPARMS}"
decho "$jobcard" ${tempds}
decho -a "//*
//PROCLIB JCLLIB ORDER=${IGYHLQ}.SIGYPROC
//RUNIVP EXEC IGYWCLG,REGION=0M,
//  LNGPRFX=${IGYHLQ},
//  LIBPRFX=${CEEHLQ},
//  PARM.LKED='LIST.XREF,LET,MAP',
//  PARM.COBOL='RENT',
//  PARM.GO=''
//COBOL.SYSIN DD DISP=SHR,
//  DSN=${IGYHLQ}.SIGYSAMP(IGYIVP)
//GO.SYSOUT DD SYSOUT=*
" ${tempds}

job=`jsub $tempds`
running=1
while [ ${running} -gt 0 ]; do
	status=`jls ${job} | awk '{ print $4; }'`
	if [ "${status}" != 'AC' ]; then
		running=0
	else 
		sleep 1
	fi
done
rc=`jls ${job} | awk '{ print $5; }'`
if [ ${rc} != '0' ]; then
	echo "IVP failed with RC:${rc}"
	exit 16
fi

drm $tempds

