#!/bin/sh
sw=$1
if [ $# -ne 1 ]; then
	echo "Syntax: fmidls <sw>, e.g. fmidls igy630"
	exit 4
fi
sw=`print $1 | tr [:lower:] [:upper:]`
export SMP_CSI=ZBREW.${sw}G.GLOBAL.CSI
gimsmp <<zzz
SET BDY(GLOBAL).
LIST FEATURE.
zzz
rc=$?
if [ $rc -eq 0 ]; then
	fmids=`awk ' /FMID/ { $1=$2=""; print $0; }' ${TMP}/smp.smplist`
	echo ${fmids}
else
	cat /bigtemp/smp.smpout
fi
exit $rc
