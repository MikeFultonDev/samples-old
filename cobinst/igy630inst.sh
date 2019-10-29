#!/bin/sh
#set -x

crtds() {
	list=$1
	echo "$1" | awk '{ ds=$1; $1=""; attrs=$0; if ($ds != "") { rc=system("dtouch " attrs " " ds); if (rc > 0) { exit(rc); } } }'
	exit $?
}

crtzfs() {
	root=$1 
	middle='/usr/lpp/IBM/cobol/igyv6r3'
	leaves='bin/.orig bin/IBM lib/nls/msg/C lib/nls/msg/Ja_JP include demo/oosample'
	for l in $leaves; do
		mkdir -p -m 755 ${root}${middle}${l}
		rc=$?
		if [ $rc -gt 0 ]; then
			exit $rc
		fi
	done
}

crtddef() {
targetsmpcntl=\
" SET   BDY(${IGYSMPTGT}).
 UCLIN.
  ADD DDDEF(SIGYMAC)
      DA(${IGYHLQ}.SIGYMAC)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYCOMP)
      DA(${IGYHLQ}.SIGYCOMP)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYPROC)
      DA(${IGYHLQ}.SIGYPROC)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYSAMP)
      DA(${IGYHLQ}.SIGYSAMP)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYHFS)
      DA(${IGYHLQ}.AIGYHFS)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYMOD1)
      DA(${IGYHLQ}.AIGYMOD1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYSRC1)
      DA(${IGYHLQ}.AIGYSRC1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYHFS)
      PATH('${IGYROOT}/usr/lpp/IBM/cobol/igyv6r3/bin/IBM/').
 ENDUCL."

distsmpcntl=\
" SET   BDY(${IGYSMPDIST}).
 UCLIN.
  ADD DDDEF(AIGYHFS)
      DA(${IGYHLQ}.AIGYHFS)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYMOD1)
      DA(${IGYHLQ}.AIGYMOD1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYSRC1)
      DA(${IGYHLQ}.AIGYSRC1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
 ENDUCL."

	mvscmdauth --pgm=GIMSMP --smpcsi=${IGYGLOBALCSI}  --smppts=TST.SMPPTS --smplog='*' --smpout='*' --smprpt='*' --smplist='*' --sysprint='*'  --smpcntl=stdin <<zzz
${targetsmpcntl}
zzz
	rc=$?
	if [ $rc -gt 0 ]; then
		exit $rc
	fi

	mvscmdauth --pgm=GIMSMP --smpcsi=${IGYGLOBALCSI} --smplog='*' --smpout='*' --smprpt='*' --smplist='*' --sysprint='*' --smpcntl=stdin <<zzz
${distsmpcntl}
zzz
	rc=$?
	exit $rc
}

props="./igy630config.properties"

if [ -f ${props} ]; then
	value=`cat ${props}`
	OLDIFS=$IFS; IFS="
"
	for v in $value; do
		eval "$v";
	done	
	IFS=$OLDIFS
else
	echo "Unable to find properties file. Make sure you cd to this directory before running the script."
	exit 16
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
	echo "Dataset creation failed. Installation aborted"
	exit $rc
fi

out=`crtzfs "${IGYROOT}"`
rc=$?
if [ $rc -gt 0 ]; then
	echo "zFS File system creation failed. Installation aborted"
	exit $rc
fi

out=`crtddef`
rc=$?
if [ $rc -gt 0 ]; then
	echo "zFS File system creation failed. Installation aborted"
	echo "$out"
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

