#!/bin/sh
# Use ICETOOL for a better sort
#
function unload {
in=$1
out=$2
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

}

. ./setenv.sh
hlq=`hlq`
in=${hlq}.CLIENT.ORIG.BIN
dup=${hlq}.CLIENT.ICETOOL.DUP
nodup=${hlq}.CLIENT.ICETOOL.NODUP
duptext=${hlq}.CLIENT.ICETOOL.DUPTXT
noduptext=${hlq}.CLIENT.ICETOOL.NODUPTXT
tmp=`mvstmp ${hlq}`
icetmp=/tmp/icetool.$$.tmp

drm -f ${dup} ${nodup} ${duptext} ${noduptext}
dtouch -tseq -rfb -l170 ${dup}
dtouch -tseq -rfb -l170 ${nodup}
dtouch -tseq -rfb -l188 ${duptext}
dtouch -tseq -rfb -l188 ${noduptext}
dtouch ${tmp}

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

mvscmd --pgm=ICETOOL --toolmsg=* --dfsmsg=* --in=${in} --dup="${dup}" --nodup="${nodup}" --toolin="${tmp}(toolin)" --ctl1cntl="${tmp}(ctl1cntl)" >"${icetmp}"
rc=$?
if [[ $rc -gt 0 ]]; then
	cat ${icetmp}
else
	rm -f ${icetmp}
fi

drm -f ${tmp}

dupres=`unload ${dup} ${duptext}`
nodupres=`unload ${nodup} ${noduptext}`

echo "Duplicates in ${dup} (human-readable ${duptxt})"
echo "Non-Duplicates in ${nodup} (human-readable ${noduptxt})"
