#!/bin/sh
mvscmd --pgm=SORT --args='' --sysout=* --sortin=tstradm.client.bin --sortout=tstradm.sclient.bin --sysin=stdin <<zz
 SORT FIELDS=(1,8,CH,A)
 SUM FIELDS=NONE
zz
