#!/bin/sh
#
# Configure SMP/E so that PTFs can be received
#
#set -x
. ./setenv.sh
./checkenv.sh
. ./crtWorkDir.sh

echo 'Install SMP/E tools on host'
ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src; git clone https://github.com/mikefultonbluemix/samples.git"
ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src/samples/smpe; ./smpecheck.sh"
rc=$?
if [ ${rc} -gt 0 ]; then
	exit ${rc}
fi

echo 'Transfer Certificates'

PUSH_TOOLS=${ASCIIWORKDIR}/ftptools.cmd
cat >${PUSH_TOOLS} <<zz
cd "${ZOS_TOOLS_ROOT}/src/samples/smpe"
mkdir bin
cd bin
lcd "${BINWORKDIR}"
put *
zz

cp "${CERT_DIR}"/* "${BINWORKDIR}"

echo "Push certificates to host"
sftp "${ZOS_USER}@${ZOS_HOST}" <"${PUSH_TOOLS}"

ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src/samples/smpe; ./smpecertinstall.sh"
rc=$?
if [ ${rc} -gt 0 ]; then
        exit ${rc}
fi
ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src/samples/smpe; ./smpecertconfig.sh"
rc=$?
if [ ${rc} -gt 0 ]; then
        exit ${rc}
fi
ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src/samples/smpe; ./smperecert.sh"
rc=$?
if [ ${rc} -gt 0 ]; then
        exit ${rc}
fi
