#!/bin/sh
#
# dls basic unit test
#
DESC='dls: Create set of datasets and then list them'
. ../testframework.sh

#set -x
thlq="DLSTEST"
ds1="PDS.FB70"
dsAttr1="-tpds -rFB -l70"
ds2="PDSE.VB123"
dsAttr2="-tpdse -rVB -l123"
ds3="PDSE.DEFAULT.FB80"
dsAttr3=""
ds4="SEQ.VB5"
dsAttr4="-tseq -rVB -l5"
ds5="SEQ.DEFAULT.VB137"
dsAttr5="-tseq -rVB"
ds6="PDS.DEFAULT.FB80"
dsAttr6="-tpds -rFB"

drm -f `dls ${thlq}.*`
ds1=`qualdsname ${thlq} ${ds1}`
ds2=`qualdsname ${thlq} ${ds2}`
ds3=`qualdsname ${thlq} ${ds3}`
ds4=`qualdsname ${thlq} ${ds4}`
ds5=`qualdsname ${thlq} ${ds5}`
ds6=`qualdsname ${thlq} ${ds6}`

dtouch ${dsAttr1} ${ds1}
dtouch ${dsAttr2} ${ds2}
dtouch ${dsAttr3} ${ds3}
dtouch ${dsAttr4} ${ds4}
dtouch ${dsAttr5} ${ds5}
dtouch ${dsAttr6} ${ds6}

today=`date "+%Y/%m/%d"`

dsP1=`blankpad ${ds1} 44`
dsP2=`blankpad ${ds2} 44`
dsP3=`blankpad ${ds3} 44`
dsP4=`blankpad ${ds4} 44`
dsP5=`blankpad ${ds5} 44`
dsP6=`blankpad ${ds6} 44`

dsPAttr1='PO  FB    70'
dsPAttr2='PO  VB   123'
dsPAttr3='PO  FB    80'
dsPAttr4='PS  VB     5'
dsPAttr5='PS  VB   137'
dsPAttr6='PO  FB    80'

vol="USER10"  # msf - use SMS volume or ignore volume 
actual=`dls -l ${thlq}.*`
expected="${dsP1} ${today} ${dsPAttr1} ${vol}
${dsP2} ${today} ${dsPAttr2} ${vol}
${dsP3} ${today} ${dsPAttr3} ${vol}
${dsP4} ${today} ${dsPAttr4} ${vol}
${dsP5} ${today} ${dsPAttr5} ${vol}
${dsP6} ${today} ${dsPAttr6} ${vol}"
actual=`echo "${actual}" | sort`
expected=`echo "${expected}" | sort`
if [[ "${actual}" = "${expected}" ]]; then
	pass "${DESC}"
else
	fail "${DESC}" "${expected}" "${actual}"
fi
