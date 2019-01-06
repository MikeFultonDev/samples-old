#!/bin/sh
. ./setenv.sh
hlq=`hlq`
in=${hlq}.CLIENT.TXT
out=${hlq}.CLIENT.BIN
drm -f ${in}
drm -f ${out}
dtouch -tseq -rfb -l188 ${in}
dtouch -tseq -rfb -l170 ${out}

cp "${PART3_CHALLENGE2_ROOT}/data/client.txt" "//'${in}'"

#
# LIST option is here to workaround bug in SORT that causes 
# intermittent crash if no option specified
#
mvscmd --pgm=SORT --args='LIST' --sysout=* --sortin=${in} --sortout=${out} --sysin=stdin <<zz
  OPTION COPY
  OUTREC FIELDS=(1,8,
                 10,10,ZD,TO=PD,LENGTH=5,
                 21,10,ZD,TO=PD,LENGTH=5,
                 32,20,
                 53,15,
                 69,25,
                 95,20,
                 116,22,
                 139,50)
zz
