#!/bin/sh
# See: http://www-03.ibm.com/support/techdocs/atsmastr.nsf/5cb5ed706d254a8186256c71006d2e0a/bdee3c698260c970852582170066c99f/$FILE/New%20Certificate%20Authority.pdf) 
#
#set -x
function tsoPrintError {
	cmd="$@"
	tsocmd "$cmd" >/dev/null 2>&1
#	if [ $? -gt 0 ]; then
		tsocmd "$cmd" 
#	fi
	return $?
}

me=`hlq` #not whoami - it can give an odd answer for uid 0
certCADataset="${me}.SMPE.DIGICERT.CA.CRT"
certG2Dataset="${me}.SMPE.DIGICERT.G2.CRT"
CALabel="DigiCert Global Root CA"
G2Label="DigiCert Global Root G2"

tsoPrintError "RACDCERT CERTAUTH ADD('${certCADataset}') WITHLABEL('${CALabel}') TRUST"
tsoPrintError "RACDCERT CERTAUTH ADD('${certG2Dataset}') WITHLABEL('${G2Label}') TRUST"

