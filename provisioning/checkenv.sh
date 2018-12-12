#!/bin/sh
#
# Paired with setenv.sh - ensure that environment variables set up properly
#
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
if [ -z "${SSH}}" ]; then
        echo "Need to export SSH to provision."
        echo "Default for zD&T users is ssh"
        exit 16
fi
if [ -z "${SCP}}" ]; then
        echo "Need to export SCP to provision."
        echo "Default for zD&T users is scp"
        exit 16
fi
if [ -z "${SFTP}}" ]; then
        echo "Need to export SFTP to provision."
        echo "Default for zD&T users is sftp"
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
if [ ! -d "${CERT_DIR}" ]; then
        echo "Need to export CERT_DIR for SMP/E configuration."
        exit 16
fi

