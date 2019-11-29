#!/bin/sh
if [ $# -ne 2 ]; then
	echo "Syntax: mkcat <alias> <storage-class>"
	exit 4
fi
alias=`print $1 | tr [:lower:] [:upper:]`
stgclass=`print $2 | tr [:lower:] [:upper:]`
mvscmdauth --pgm=idcams --sysprint='*' --sysin=stdin <<zzz
    DEFINE  USERCATALOG( - 
                   NAME(USERCAT.${alias}) - 
                   STORCLAS(${stgclass}) - 
                   ICFCATALOG - 
                   TRACKS(150) - 
                   BUFND(4) - 
                   BUFNI(4) - 
                     ) - 
            DATA( - 
                   CYL(10 5) - 
                     ) - 
            INDEX( - 
                   TRACKS(10 5) - 
                 ) 
zzz
