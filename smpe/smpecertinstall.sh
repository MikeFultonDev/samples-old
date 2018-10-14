#!/bin/sh
set -x
me=`hlq`
cd bin
for f in *; do
	drm -f ${me}.${f}
	dtouch -tSEQ -s5k -rVB -l1028 ${me}.${f}
	cp ${f} "//'${me}.${f}'"
done
cd ..
