#!/bin/sh
# Use ICETOOL for a better sort
#
. ./setenv.sh
hlq=`hlq`
in=${hlq}.CLIENT.BIN
dup=${hlq}.ICLIENT.DUP
nodup=${hlq}.ICLIENT.NODUP
tmp=`mvstmp ${hlq}`

drm -f ${dup} ${nodup}
dtouch -tseq ${dup}
dtouch -tseq ${nodup}
dtouch ${tmp}

dtouch -rfb -l80 -tseq ${out}
position="1"
length="8"
format="CH"

decho "
 SELECT FROM(IN) TO(DUP) DISCARD(NODUP) -
 ON(${position},${length},${format}) ALLDUPS USING(CTL1)
" "${tmp}(toolin)"

decho "
 OUTFIL FNAMES=DUP
 OUTFILE FNAMES=NODUP
" "${tmp}(ctl1cntl)"

mvscmd --pgm=ICETOOL --toolmsg=* --dfsmsg=* --in=${in} --dup="${dup}" --nodup="${nodup}" --toolin="${tmp}(toolin)" --ctl1cntl="${tmp}(ctl1cntl)"

drm -f ${tmp}
