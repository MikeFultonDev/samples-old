#!/bin/sh
if [ $# -ne 1 ]; then
	echo "Syntax: $0 <tgt-zone>"
	exit 16
fi
tgtZone=`print $1 | tr [:lower:] [:upper:]`
gimsmp <<zz
 SET BDY(${tgtZone}).
 LIST SYSMODS FUNCTIONS.
zz
