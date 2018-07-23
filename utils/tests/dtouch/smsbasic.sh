#!/bin/sh
#
# dtouch basic unit test
# TBD: determine how to get a list of possible SMS volumes
#
DESC='dtouch: Create Default SMS-managed dataset'

. ../testframework.sh
#set -x
today=`date "+%Y/%m/%d"`
smsvols="USER00 USER20"
dataclass="DCEXTEAV"
basic=`dsname "DTOUCH.BASIC"`
basicpadded=`blankpad ${basic} 44`

expectedPrefix="${basicpadded} ${today} PO  FB    80"
drm -f ${basic}
dtouch -d${dataclass} ${basic}
actual=`dls -l ${basic}`

for vol in ${smsvols}; do
  expected="${expectedPrefix} ${vol}"
  if [[ "${actual}" == "${expected}" ]]; then
    drm -f ${basic}
    pass "${DESC}"
  fi
done
fail "${DESC}" "${expectedPrefix}" "${actual}"
