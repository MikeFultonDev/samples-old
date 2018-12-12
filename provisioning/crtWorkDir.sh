#!/bin/sh
WORKDIR="${TMPDIR}/provisionwork"
ASCIIWORKDIR="${WORKDIR}/ascii"
BINWORKDIR="${WORKDIR}/bin"
rm -rf "${WORKDIR}"
rc=$?
if [ ${rc} -ne 0 ]; then
        echo "Unable to remove work directory: ${WORKDIR}"
        exit ${rc}
fi
mkdir ${WORKDIR}
if [ ${rc} -ne 0 ]; then
        echo "Unable to create work directory: ${WORKDIR}"
        exit ${rc}
fi
mkdir ${ASCIIWORKDIR}
if [ ${rc} -ne 0 ]; then
        echo "Unable to create ASCII (text) work directory: ${ASCIIWORKDIR}"
        exit ${rc}
fi
mkdir ${BINWORKDIR}
if [ ${rc} -ne 0 ]; then
        echo "Unable to create binary work directory: ${BINWORKDIR}"
        exit ${rc}
fi
