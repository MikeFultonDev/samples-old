#!/bin/sh
#GIMSAMPU:

definecsicluster() {
     name="$1"

     echo "
     DEFINE CLUSTER( +
              NAME(${name}) +
              CYLINDERS(100 10) +
              FREESPACE(10 5) +
              KEYS(24 0) +
              RECORDSIZE(24 143) +
              SHAREOPTIONS(2 3) +
                  ) +
         DATA ( +
              NAME(${name}.DATA) +
              CONTROLINTERVALSIZE(8192) +
              ) +
        INDEX (NAME(${name}.INDEX) +
              CONTROLINTERVALSIZE(4096) +
              )
     REPRO INFILE(REPRO) +
              OUTDATASET(${name})
     "
     return 0
}

definecsidatasets() {
     for v in $*; do
          name="${v%%:*}"
          attrs="${v##*:}"
          attrs=`echo ${attrs} | tr ',' '\t'`
          dtouch ${attrs} ${name}
     done
     return 0
}

definesmpcntl() {
     HLQ="$1"

     echo "
  SET BOUNDARY(GLOBAL).
  UCLIN.
    ADD OPTIONS(GOPT)
          DSPREFIX(${HLQ}.SMPTLIB)
          DSSPACE(20,20,100)
          MSGFILTER(YES)
          MSGWIDTH(80)
          RECZGRP(ALLZONES)
          RETRYDDN(ALL).
    ADD GLOBALZONE
          OPTIONS(GOPT)
          SREL(Z038)
          ZONEINDEX(
                    (TARGET,${HLQ}.TARGET.CSI,TARGET)
                    (DLIB,${HLQ}.DLIB.CSI,DLIB)
                   ).
    ADD DDDEF(SMPDEBUG) SYSOUT(*).
    ADD DDDEF(SMPLIST)  SYSOUT(*).
    ADD DDDEF(SMPRPT)   SYSOUT(*).
    ADD DDDEF(SMPSNAP)  SYSOUT(*).
    ADD DDDEF(SYSPRINT) SYSOUT(*).
    ADD DDDEF(SMPLOG)   DA(${HLQ}.GLOBAL.SMPLOG) MOD.
    ADD DDDEF(SMPLOGA)  DA(${HLQ}.GLOBAL.SMPLOGA) MOD.
    ADD DDDEF(SMPOUT)   SYSOUT(*).
    ADD DDDEF(SMPPTS)   DA(${HLQ}.SMPPTS) SHR.
    ADD DDDEF(SYSUT1)   UNIT(SYSALLDA) CYLINDERS SPACE(25,25).
    ADD DDDEF(SYSUT2)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SYSUT3)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SYSUT4)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SMPWRK1)  UNIT(SYSALLDA) CYLINDERS SPACE(10,10)
                        DIR(100).
    ADD DDDEF(SMPWRK2)  UNIT(SYSALLDA) CYLINDERS SPACE(10,10)
                        DIR(100).
    ADD DDDEF(SMPWRK3)  UNIT(SYSALLDA) CYLINDERS SPACE(150,50)
                        DIR(1000).
    ADD DDDEF(SMPWRK4)  UNIT(SYSALLDA) CYLINDERS SPACE(5,5)
                        DIR(50).
    ADD DDDEF(SMPWRK6)  UNIT(SYSALLDA) CYLINDERS SPACE(150,50)
                        DIR(1000).
  ENDUCL.
  SET BOUNDARY(TARGET).
  UCLIN.
    ADD TARGETZONE(TARGET)
          OPTIONS(GOPT)
          SREL(Z038)
          RELATED(DLIB).
    ADD DDDEF(SMPDEBUG) SYSOUT(*).
    ADD DDDEF(SMPLIST)  SYSOUT(*).
    ADD DDDEF(SMPLOG)   DA(${HLQ}.TARGET.SMPLOG) MOD.
    ADD DDDEF(SMPLOGA)  DA(${HLQ}.TARGET.SMPLOGA) MOD.
    ADD DDDEF(SMPOUT)   SYSOUT(*).
    ADD DDDEF(SMPRPT)   SYSOUT(*).
    ADD DDDEF(SMPSNAP)  SYSOUT(*).
    ADD DDDEF(SYSPRINT) SYSOUT(*).
    ADD DDDEF(SMPPTS)   DA(${HLQ}.SMPPTS) SHR.
    ADD DDDEF(SMPSTS)   DA(${HLQ}.TARGET.SMPSTS) OLD.
    ADD DDDEF(SMPMTS)   DA(${HLQ}.TARGET.SMPMTS) OLD.
    ADD DDDEF(SMPLTS)   DA(${HLQ}.TARGET.SMPLTS) OLD.
    ADD DDDEF(SMPSCDS)  DA(${HLQ}.TARGET.SMPSCDS) OLD.
    ADD DDDEF(SYSLIB)   CONCAT(SMPMTS).
    ADD DDDEF(SYSUT1)   UNIT(SYSALLDA) CYLINDERS SPACE(25,25).
    ADD DDDEF(SYSUT2)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SYSUT3)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SYSUT4)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SMPWRK1)  UNIT(SYSALLDA) CYLINDERS SPACE(10,10)
                        DIR(100).
    ADD DDDEF(SMPWRK2)  UNIT(SYSALLDA) CYLINDERS SPACE(10,10)
                        DIR(100).
    ADD DDDEF(SMPWRK3)  UNIT(SYSALLDA) CYLINDERS SPACE(150,50)
                        DIR(1000).
    ADD DDDEF(SMPWRK4)  UNIT(SYSALLDA) CYLINDERS SPACE(5,5)
                        DIR(50).
    ADD DDDEF(SMPWRK6)  UNIT(SYSALLDA) CYLINDERS SPACE(150,50)
                        DIR(1000).
  ENDUCL.
  SET BOUNDARY(DLIB).
  UCLIN.
    ADD DLIBZONE(DLIB)
          OPTIONS(GOPT)
          SREL(Z038)
          ACCJCLIN
          RELATED(TARGET).
    ADD DDDEF(SMPDEBUG) SYSOUT(*).
    ADD DDDEF(SMPLIST)  SYSOUT(*).
    ADD DDDEF(SMPLOG)   DA(${HLQ}.DLIB.SMPLOG) MOD.
    ADD DDDEF(SMPLOGA)  DA(${HLQ}.DLIB.SMPLOGA) MOD.
    ADD DDDEF(SMPOUT)   SYSOUT(*).
    ADD DDDEF(SMPRPT)   SYSOUT(*).
    ADD DDDEF(SMPSNAP)  SYSOUT(*).
    ADD DDDEF(SYSPRINT) SYSOUT(*).
    ADD DDDEF(SMPPTS)   DA(${HLQ}.SMPPTS) SHR.
    ADD DDDEF(SMPSTS)   DA(${HLQ}.TARGET.SMPSTS) OLD.
    ADD DDDEF(SMPMTS)   DA(${HLQ}.TARGET.SMPMTS) OLD.
    ADD DDDEF(SMPLTS)   DA(${HLQ}.TARGET.SMPLTS) OLD.
    ADD DDDEF(SMPSCDS)  DA(${HLQ}.TARGET.SMPSCDS) OLD.
    ADD DDDEF(SYSLIB)   CONCAT(SMPMTS).
    ADD DDDEF(SYSUT1)   UNIT(SYSALLDA) CYLINDERS SPACE(25,25).
    ADD DDDEF(SYSUT2)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SYSUT3)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SYSUT4)   UNIT(SYSALLDA) CYLINDERS SPACE(5,5).
    ADD DDDEF(SMPWRK1)  UNIT(SYSALLDA) CYLINDERS SPACE(10,10)
                        DIR(100).
    ADD DDDEF(SMPWRK2)  UNIT(SYSALLDA) CYLINDERS SPACE(10,10)
                        DIR(100).
    ADD DDDEF(SMPWRK3)  UNIT(SYSALLDA) CYLINDERS SPACE(150,50)
                        DIR(1000).
    ADD DDDEF(SMPWRK4)  UNIT(SYSALLDA) CYLINDERS SPACE(5,5)
                        DIR(50).
    ADD DDDEF(SMPWRK6)  UNIT(SYSALLDA) CYLINDERS SPACE(150,50)
                        DIR(1000).
  ENDUCL.
       "
       return 0
}

HLQ='TST'
GLOBAL_CSI="${HLQ}.GLOBAL.CSI"
TARGET_CSI="${HLQ}.TARGET.CSI"
DLIB_CSI="${HLQ}.DLIB.CSI"
REPRO_FROM="SYS1.MACLIB(GIMZPOOL)"

gcsi=`definecsicluster "${GLOBAL_CSI}"`
tcsi=`definecsicluster "${TARGET_CSI}"`
dcsi=`definecsicluster "${DLIB_CSI}"`

mvscmdauth --pgm=IDCAMS --sysprint='*' --repro=${REPRO_FROM} --sysin=stdin <<zzz
  ${gcsi}
  ${tcsi}
  ${dcsi}
zzz
if [ $? -gt 0 ]; then
     exit 16
fi

datasets="${HLQ}.SMPPTS:-s500M,-tpdse
          ${HLQ}.TARGET.SMPMTS:-tpds
          ${HLQ}.TARGET.SMPSTS:-tpds
          ${HLQ}.TARGET.SMPLTS:-tpds
          ${HLQ}.TARGET.SMPSCDS:-tpds
          ${HLQ}.GLOBAL.SMPLOG:-tseq,-rvb,-l150
          ${HLQ}.GLOBAL.SMPLOGA:-tseq,-rvb,-l150
          ${HLQ}.TARGET.SMPLOG:-tseq,-rvb,-l150
          ${HLQ}.TARGET.SMPLOGA:-tseq,-rvb,-l150
          ${HLQ}.DLIB.SMPLOG:-tseq,-rvb,-l150
          ${HLQ}.DLIB.SMPLOGA:-tseq,-rvb,-l150"

definecsidatasets ${datasets}
if [ $? -gt 0 ]; then
     exit 16
fi

#
#********************************************************************
# Prime the CSI data sets with:
# - zone definitions for a global, target, and dlib zone
# - basic OPTIONS entry
# - DDDEF entries for operational and temporary data sets
#********************************************************************
#
set -x
smpcntl=`definesmpcntl "${HLQ}"`
mvscmdauth --pgm=GIMSMP --smpcsi=${GLOBAL_CSI} --smppts=${HLQ}.SMPPTS --smplog='*' --smpout='*' --smprpt='*' --smplist='*' --sysprint='*' --smpcntl=stdin <<zzz
  ${smpcntl}
zzz
if [ $? -gt 0 ]; then
     exit 16
fi
