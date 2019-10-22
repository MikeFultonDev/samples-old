#!/bin/sh
#
# See: https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.gim3000/gim3119.htm
# Requires SMP/E certificate setup has already been done
#

chkset() {
	rc=0
	for e in $*; do
		if [ -z "${e}" ]; then  
			echo "Environment variable: ${e} is not set, but needs to be for this script"
			rc=8
		fi
	done
	return $rc
}

chkset "SMPE_CLASSPATH JAVA_HOME SMPE_CSI SMPE_ORDER SMPE_FTPHOST SMPE_FTPSRCDIR SMPE_FTPUSER SMPE_FTPPORT SMPE_FTPPW SMPE_FTPHASH SMPE_SIZE_MB"
if [ $? -gt 0 ]; then
	exit $?
fi

tmpServerHFS=${TMP}/server.$$.xml
tmpClientHFS=${TMP}/client.$$.xml
tmpCntlHFS=${TMP}/cntl.$$.xml


cat >${tmpClientHFS} <<zzz
  <CLIENT debug="YES"                                  
     javahome="${JAVA_HOME}"                    
     classpath="${SMPE_CLASSPATH}"                 
     downloadmethod="https"                            
     downloadkeyring="*AUTH*/*"                        
     javadebugoptions="-Dcom.ibm.smp.debug=severe">    
 </CLIENT>    
zzz

cat >${tmpServerHFS} <<zzz
  <SERVER
  host="${SMPE_FTPHOST}"
  user="${SMPE_FTPUSER}"
  port="${SMPE_FTPPORT}"
  pw="${SMPE_FTPPW}"
  >
  <PACKAGE
  file="/${SMPE_FTPSRCDIR}/GIMPAF.XML"
  hash="${SMPE_FTPHASH}"
  id="httptest"
  >
  </PACKAGE>
  </SERVER>
zzz

cat >${tmpCntlHFS} <<zzz
  SET BDY(GLOBAL).
    RECEIVE FROMNETWORK(
      SERVER(SERVER)
      CLIENT(CLIENT)
    )
      .
zzz

LOG=${TMP}/$$.smplog
touch ${LOG}

OUT=${TMP}/$$.smpout
touch ${OUT}

RPT=${TMP}/$$.smprpt
touch ${RPT}

NTS=${TMP}/$$.smpnts

PRINT=${TMP}/$$.smpsysprint
touch ${PRINT}

rm -rf ${NTS}
mkdir ${NTS}

mvscmdauth --pgm=gimsmp --smpcsi=${SMPE_CSI} --smpwkdir=${TMP} --smpnts=${NTS} --smplog=${LOG},mod --smpout=${OUT},mod --smprpt=${RPT},mod --bpxprint=* --sysprint=* --server=${tmpServerHFS} --client=${tmpClientHFS} --smpcntl=${tmpCntlHFS} >${PRINT}
rc=$?
if [ ${rc} -ne 0 ]; then
	cat ${OUT}
fi

rm ${tmpOrderHFS} ${tmpClientHFS} ${tmpCntlHFS}
rm -rf ${OUT} ${NTS}

exit ${rc}
