#!/bin/sh
#
# dtouch basic unit test
# TBD: determine how to get a list of possible non-SMS volumes
#
DESC='dtouch: Create Default non-SMS dataset'
. ../testframework.sh

#set -x
today=`date "+%Y/%m/%d"`
smsvols="USER10"
basic=`dsname "DTOUCH.NONSMS.BASIC"`
basicpadded=`blankpad ${basic} 44`

expectedPrefix="${basicpadded} ${today} PO  FB    80"
drm -f ${basic}
dtouch ${basic}
actual=`dls -l ${basic}`

for vol in ${smsvols}; do
  expected="${expectedPrefix} ${vol}"
  if [[ "${actual}" == "${expected}" ]]; then
    drm -f ${basic}
    pass "${DESC}"
  fi
done
fail "${DESC}" "${expectedPrefix}" "${actual}"
