#!/bin/sh
if [ $# -ne 2 ]; then
	echo "Syntax: $0 <tgt-zone> <ptf>"
	exit 16
fi
tgtZone=`print $1 | tr [:lower:] [:upper:]`
ptf=`print $2 | tr [:lower:] [:upper:]`
gimsmp <<zz
 SET BDY(${tgtZone}) .                                    
  APPLY CHECK                                          
        BYPASS(HOLDSYS) 
        S(${ptf})  
 .
zz
rc=$?
if [ ${rc} -ne 0 ]; then
	cat ${TMP}/smp.smpout
	exit ${rc}
fi

echo "apply ${ptf}"
gimsmp <<zz
 SET BDY(${tgtZone}) .                                    
  APPLY 
        BYPASS(HOLDSYS) 
        S(${ptf})  
 .
zz
