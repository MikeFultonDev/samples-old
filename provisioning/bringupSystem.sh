#!/bin/sh
#set -x
if [ -z "${TMPDIR}" ]; then 
	if [ -d /tmp ]; then
		TMPDIR="/tmp"
	else
		echo "Need to define TMPDIR or create /tmp directory"
		exit 16
	fi
fi
if [ -z "${ZOS_USER}}" ]; then
	echo "Need to export ZOS_USER"
	echo "Default for zD&T users is TSTRADM"
	exit 16
fi
if [ -z "${ZOS_HOST}}" ]; then
	echo "Need to export ZOS_HOST"
	echo "Default for zD&T users is 172.30.0.1"
	exit 16
fi
if [ -z "${ZOS_TOOLS_ROOT}}" ]; then
	echo "Need to export ZOS_TOOLS_ROOT to provision."
	echo "Default location for zD&T users is /zaas1/tools"
	exit 16
fi
if [ -z "${ZOS_GIT_USER}" ]; then
	echo "Need to export ZOS_GIT_USER to provision"
	echo "This is your git username you want to use"
	exit 16
fi
if [ -z "${ZOS_GIT_EMAIL}" ]; then
	echo "Need to export ZOS_GIT_EMAIL to provision"
	echo "This is your git email you want to use"
	exit 16
fi
if [ ! -d "${ROCKET_TOOLS_DIR}" ]; then
	echo "Need to export ROCKET_TOOLS_DIR to provision."
	echo "Minimum tools required: gzip-1.6, bash-4.3, unzip-6.0, git-2.3.5, perl-5.24"
	echo "See: https://www.rocketsoftware.com/zos-open-source/tools to download"
	exit 16
fi
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

echo "Temporarily set shell to 'sh'"
ssh "${ZOS_USER}@${ZOS_HOST}" "tsocmd \"ALTUSER TSTRADM OMVS(PROGRAM(/bin/sh))\" "

PROFILE=${ASCIIWORKDIR}/.profile
PUSH_TOOLS=${ASCIIWORKDIR}/ftptools.cmd
cat >${PROFILE} <<zz
export TERM=xterm
set -o emacs
export TOOLS_ROOT=${ZOS_TOOLS_ROOT}
export PATH=\${PATH}:\${TOOLS_ROOT}/bin
export MANPATH=\${MANPATH}:\${TOOLS_ROOT}/man/
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS='FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)'
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
export PERL5LIB=\${PERL5LIB}:\${TOOLS_ROOT}/lib/perl5
export GIT_SHELL=${TOOLS_ROOT}/bin/bash
export GIT_EXEC_PATH=\${TOOLS_ROOT}/libexec/git-core
export GIT_TEMPLATE_DIR=\${TOOLS_ROOT}/share/git-core/templates
git config --global http.sslVerify false 
git config --global core.editor "/bin/vi -W filecodeset=ISO8859-1" 
git config --global user.name  "${ZOS_GIT_USER}"
git config --global user.email "${ZOS_GIT_EMAIL}"
if [ -f .devprofile ]; then
	. ./.devprofile
fi
zz

echo "Create user profile for ${ZOS_USER}"
scp "${PROFILE}" "${ZOS_USER}@${ZOS_HOST}:./.profile"

echo "Create tools directory on host"
ssh "${ZOS_USER}@${ZOS_HOST}" "rm -rf ${ZOS_TOOLS_ROOT}; mkdir -p ${ZOS_TOOLS_ROOT}"

cat >${PUSH_TOOLS} <<zz
cd "${ZOS_TOOLS_ROOT}"
lcd "${BINWORKDIR}"
put *
zz

cp "${ROCKET_TOOLS_DIR}"/* "${BINWORKDIR}"

echo "Push Rocket tools to host"
sftp "${ZOS_USER}@${ZOS_HOST}" <"${PUSH_TOOLS}"

echo "Unpack tools on host"

ssh "${ZOS_USER}@${ZOS_HOST}" "cd ${ZOS_TOOLS_ROOT}; tar -xf gzip*.tar; ./bin/gzip -d *.gz; rm gzip*.tar; for f in *.tar; do tar -xf \$f; done"

echo "Set bash as default shell"
ssh "${ZOS_USER}@${ZOS_HOST}" "tsocmd \"ALTUSER TSTRADM OMVS(PROGRAM(${ZOS_TOOLS_ROOT}/bin/bash))\" "

#
# The following is specific to utility development systems
#
echo "Install MVSCommand and sample utilities"
ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}; mkdir src; cd src; git clone https://github.com/mikefultonbluemix/MVSCommand.git; cd MVSCommand; ./build.sh"
ssh "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src; git clone https://github.com/mikefultonbluemix/samples.git"

DEVPROFILE=${ASCIIWORKDIR}/.devprofile
cat >${DEVPROFILE} <<zz
export PATH=${ZOS_TOOLS_ROOT}/src/MVSCommand/bin:${ZOS_TOOLS_ROOT}/src/samples/utils:\${PATH}
zz

echo "Create dev profile for ${ZOS_USER}"
scp "${DEVPROFILE}" "${ZOS_USER}@${ZOS_HOST}:./.devprofile"
