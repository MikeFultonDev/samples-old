#!/bin/sh
#set -x
gimsmp <<zz
 SET BDY(GLOBAL).
 LIST GZONE.
zz
if [[ $? -gt 0 ]]; then
	echo "List global zones failed. See ${TMP}/smp.* for details"
	exit 8
fi
cat ${TMP}/smp.smplist
rm -f ${TMP}/smp.*
