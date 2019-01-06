#!/bin/sh
. ./setenv.sh
hlq=`hlq`
in=${hlq}.CLIENT.BIN
out=${hlq}.CLIENT.TXT
drm -f ${out}
dtouch -tseq -rfb -l188 ${out}

#
# LIST option is here to workaround bug in SORT that causes 
# intermittent crash if no option specified
#
mvscmd --pgm=SORT --args='LIST' --sysout=* --sortin=${in} --sortout=${out} --sysin=stdin <<zz
  OPTION COPY
  OUTREC FIELDS=(1,8,X,
                 9,5,PD,TO=ZD,LENGTH=10,X,
                 14,5,PD,TO=ZD,LENGTH=10,X,
                 19,20,X,
                 39,15,X,
                 54,25,X,
                 79,20,X,
                 99,22,X,
                 121,50)
zz
