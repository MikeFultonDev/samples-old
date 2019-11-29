#!/bin/sh
if [ $# -ne 1 ]; then
	echo "Syntax: mkalias <alias-name>"
	exit 4
fi
alias=`print $1 | tr [:lower:] [:upper:]`
mvscmdauth --pgm=idcams --sysprint='*' --sysin=stdin <<zzz
 DEFINE ALIAS (NAME(${alias}) -                                   
               RELATE(USERCAT.${alias})) 
zzz
