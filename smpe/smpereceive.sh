#!/bin/sh
#
# See: https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.gim3000/gim3119.htm
# Requires SMP/E certificate setup has already been done
#
export SMPE_CLASSPATH="/usr/lpp/smp/classes"
export SMPE_CSI_DATASET="MVS.GLOBAL.CSI"
export SMPE_LABEL="SMPE Client Certificate"
export SMPE_RING="SMPERING"
export SMPE_SERVER="eccgw01.boulder.ibm.com"

owner="TSTRADM"
tmpOrderHFS=${TMP}/order.$$.xml
tmpClientHFS=${TMP}/client.$$.xml
tmpCntlHFS=${TMP}/cntl.$$.xml

if [ $# -ne 1 ]; then
	echo "Syntax: $0 [PTFS(<ptflist>)|RECOMMENDED]"
	exit 16
fi
content=`print $1 | tr [:lower:] [:upper:]`

cat >${tmpOrderHFS} <<zzz
 <ORDERSERVER 
  url="https://${SMPE_SERVER}/services/projects/ecc/ws/" 
  keyring="${owner}/${SMPE_RING}" 
  certificate="${SMPE_LABEL}"> 
 </ORDERSERVER>
zzz

cat >${tmpClientHFS} <<zzz
  <CLIENT debug="YES"                                  
     javahome="${JAVA_HOME}"                    
     classpath="${SMPE_CLASSPATH}"                 
     downloadmethod="https"                            
     downloadkeyring="*AUTH*/*"                        
     javadebugoptions="-Dcom.ibm.smp.debug=severe">    
 </CLIENT>    
zzz

cat >${tmpCntlHFS} <<zzz
     SET BDY(GLOBAL).
     RECEIVE SYSMODS HOLDDATA
             ORDER(ORDERSERVER(SERVER)
             CLIENT(CLIENT)
             CONTENT(${content}))
             DELETEPKG.
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

mvscmdauth --pgm=gimsmp --smpcsi=${SMPE_CSI_DATASET} --smpwkdir=${TMP} --smpnts=${NTS} --smplog=${LOG},mod --smpout=${OUT},mod --smprpt=${RPT},mod --bpxprint=* --sysprint=* --server=${tmpOrderHFS} --client=${tmpClientHFS} --smpcntl=${tmpCntlHFS} >${PRINT}
rc=$?
if [ ${rc} -ne 0 ]; then
	cat ${OUT}
fi

rm ${tmpOrderHFS} ${tmpClientHFS} ${tmpCntlHFS}
rm -rf ${OUT} ${NTS}

exit ${rc}

