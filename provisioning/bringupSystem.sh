#!/bin/sh
#set -x
if [[ -z "${ZOS_USER}" ]]; then
	. ./setenv.sh
fi
./setpasswd.sh "${ZOS_USER}"
./setpasswd.sh "${ZOS_ADMIN}"
./crtauth.sh
./checkenv.sh
. ./crtWorkDir.sh

echo "Temporarily set shell to 'sh'"
${SSH} "${ZOS_USER}@${ZOS_HOST}" "tsocmd \"ALTUSER TSTRADM OMVS(PROGRAM(/bin/sh))\" "
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

PROFILE=${ASCIIWORKDIR}/.profile
PUSH_TOOLS=${ASCIIWORKDIR}/ftptools.cmd
cat >${PROFILE} <<zz
export TERM=xterm
set -o emacs
export TOOLS_ROOT=${ZOS_TOOLS_ROOT}
export PATH=\${PATH}:\${TOOLS_ROOT}/bin
export MANPATH=\${MANPATH}:\${TOOLS_ROOT}/man/
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="FILETAG(AUTOCVT) POSIX(ON)"
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
export PERL5LIB=\${PERL5LIB}:\${TOOLS_ROOT}/lib/perl5
export GIT_SHELL=\${TOOLS_ROOT}/bin/bash
export GIT_EXEC_PATH=\${TOOLS_ROOT}/libexec/git-core
export GIT_TEMPLATE_DIR=\${TOOLS_ROOT}/share/git-core/templates
export JAVA_HOME=${ZOS_JAVA_HOME}
export PS1="\$(whoami)@\$(hostname -s):\$(pwd)\$ >"
mkdir -p /zaas1/tmp
export TMPDIR=/zaas1/tmp
export SMP_CSI=MVS.GLOBAL.CSI
export _BPX_SHAREAS=YES
export _BPX_SPAWN_SCRIPT=YES
git config --global http.sslVerify false 
git config --global core.editor "/bin/vi -W filecodeset=ISO8859-1" 
git config --global user.name  "${ZOS_GIT_USER}"
git config --global user.email "${ZOS_GIT_EMAIL}"
if [ -f .devprofile ]; then
	. ./.devprofile
fi
if [ -f .personalprofile ]; then
        . ./.personalprofile
fi
if [ \$(basename "\${SHELL}") = "bash" ]; then
  function whence {
    type -a "\${1}" | awk ' { print \$3; exit; }' ;
  }
fi
function whencedir {
  echo \$(dirname \`whence "\${1}"\`)
}
zz

echo "Create user profile for ${ZOS_USER}"
${SCP} "${PROFILE}" "${ZOS_USER}@${ZOS_HOST}:./.profile"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

echo "Create tools directory on host"
${SSH} "${ZOS_USER}@${ZOS_HOST}" "rm -rf ${ZOS_TOOLS_ROOT}; mkdir -p ${ZOS_TOOLS_ROOT}"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

cat >${PUSH_TOOLS} <<zz
cd "${ZOS_TOOLS_ROOT}"
lcd "${BINWORKDIR}"
put *
zz

cp "${ROCKET_TOOLS_DIR}"/* "${BINWORKDIR}"

echo "Push Rocket tools to host"
${SFTP} "${ZOS_USER}@${ZOS_HOST}" <"${PUSH_TOOLS}"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

echo "Unpack tools on host"

${SSH} "${ZOS_USER}@${ZOS_HOST}" "cd ${ZOS_TOOLS_ROOT}; tar -xf gzip*.tar; ./bin/gzip -d *.gz; rm gzip*.tar; for f in *.tar; do tar -xf \$f; done"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

echo "Set bash as default shell"
${SSH} "${ZOS_USER}@${ZOS_HOST}" "tsocmd \"ALTUSER TSTRADM OMVS(PROGRAM(${ZOS_TOOLS_ROOT}/bin/bash))\" "
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

#
# The following is specific to utility development systems
#
echo "Install MVSCommand and sample utilities"
${SSH} "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}; mkdir src; cd src; git clone https://github.com/mikefultonbluemix/MVSCommand.git; cd MVSCommand; ./build.sh"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi
${SSH} "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; cd ${ZOS_TOOLS_ROOT}/src; git clone https://github.com/mikefultonbluemix/MVSUtils.git; cd MVSUtils; ./build.sh"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

DEVPROFILE=${ASCIIWORKDIR}/.devprofile
cat >${DEVPROFILE} <<zz
export PATH=${ZOS_TOOLS_ROOT}/src/MVSCommand/bin:${ZOS_TOOLS_ROOT}/src/MVSUtils/bin:\${PATH}
zz

echo "Create dev profile for ${ZOS_USER}"
${SCP} "${DEVPROFILE}" "${ZOS_USER}@${ZOS_HOST}:./.devprofile"
if [[ $? -gt 0 ]]; then
	echo "...failed"
	exit 16
fi

echo "Let TSTRADM receive/apply PTFs"
${SSH} "${ZOS_USER}@${ZOS_HOST}" ". ~/.profile; racfpermit facility 'gim.*'"
if [[ $? -gt 0 ]]; then
        echo "...failed"
        exit 16
fi
