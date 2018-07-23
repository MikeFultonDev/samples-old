#!/bin/sh
hlq=`hlq`
function dsname {
  echo ${hlq}.TEST.$1
}

function blankpad {
  str=$1
  padlen=$2
  strlen=${#str}
  blanks="                                                                                                   "
  if [ ${#blanks} -lt ${padlen} ]; then 
    echo "Internal Error: blankpad can only pad to ${padlen} blanks"
    exit 16
  fi

  blankpad=`expr ${padlen} - ${strlen}`
  blanks=`print "${blanks}" | cut -b 1-${blankpad}`
  print "${str} ${blanks}"
  return 0
}

function pass {
  print "OK $1"
  exit 0
}

function fail {
  print "NOT OK $1"
  print "  Expected: <$2>"
  print "  Actual  : <$3>"
  exit 16
}
