#!/bin/sh
# See: https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.gim3000/accracd.htm
#
#set -x
function tsoPrintError {
	cmd="$@"
	tsocmd "$cmd" >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		tsocmd "$cmd" 
	fi
	return $?
}

function defineIfRequired {
	racfprofile $1 $2 2>/dev/null >/dev/null
	if [ $? -gt 0 ]; then
		echo "Creating profile: $1 $2"
		tsoPrintError "RDEFINE ${class} ${profile} UACC(NONE)"
	fi
}
function addPermission {
	tsoPrintError "PERMIT $2 CLASS($1) ID($3) ACCESS($4)"
}
me=`hlq` #not whoami - it can give an odd answer for uid 0
ringOwner="${me}"
certOwner="${me}"
certDataset="${me}.SMPE.CERT"
certLabel="GeoTrust Global CA"
export SMPE_RING="SMPERING"
export SMPE_LABEL="SMPE Client Certificate"

fac="FACILITY"
add="IRR.DIGTCERT.ADD"
addring="IRR.DIGTCERT.ADDRING"
alter="IRR.DIGTCERT.ALTER"
connect="IRR.DIGTCERT.CONNECT"
list="IRR.DIGTCERT.LIST"
listring="IRR.DIGTCERT.LISTRING"
gim="GIM.*"

defineIfRequired ${fac} ${gim}
addPermission "${fac}" "${gim}" "${me}" "READ"

defineIfRequired ${fac} ${add}
defineIfRequired ${fac} ${addring}
defineIfRequired ${fac} ${alter}
defineIfRequired ${fac} ${connect}
defineIfRequired ${fac} ${list}
defineIfRequired ${fac} ${listring}

addPermission "${fac}" "${add}" "${me}" "READ"
addPermission "${fac}" "${addring}" "${me}" "READ"
addPermission "${fac}" "${alter}" "${me}" "READ"
addPermission "${fac}" "${connect}" "${me}" "UPDATE"
addPermission "${fac}" "${list}" "${me}" "READ"
addPermission "${fac}" "${listring}" "${me}" "READ"

tsoPrintError "SETROPTS RACLIST(${fac}) REFRESH"

tsoPrintError "RACDCERT ID(${ringOwner}) ADDRING(${SMPE_RING})"
tsoPrintError "RACDCERT CERTAUTH ALTER(LABEL('${certLabel}')) TRUST"
tsoPrintError "RACDCERT ID(${ringOwner}) CONNECT(CERTAUTH RING(${SMPE_RING}) LABEL('${certLabel}') USAGE(CERTAUTH))"

echo "Certificate Password:"
read -r
certPW="${REPLY}"
tsoPrintError "RACDCERT ID(${certOwner}) ADD('${certDataset}') WITHLABEL('${SMPE_LABEL}') PASSWORD('${certPW}') TRUST"
tsoPrintError "RACDCERT ID(${ringOwner}) CONNECT(LABEL('${SMPE_LABEL}') RING(${SMPE_RING}) USAGE(CERTAUTH))"

