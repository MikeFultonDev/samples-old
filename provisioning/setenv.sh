#!/bin/sh
#ZOS_ADMIN:     The z/OS ID that has highest privileges 
#               This ID is not needed for basic provisioning but needs to have it's password reset
#               For z/OS as a Service systems, this is IBMUSER
#ZOS_USER:      The z/OS ID that you will log in as. 
#               This ID will need privileges to APF authorize modules, change RACF definitions and install software. 
#               For z/OS as a Service systems, this is TSTRADM
#ZOS_HOST       The IP address of the z/OS system you will provision. 
#               For z/OS as a Service systems, this is 172.30.0.1
#ZOS_TOOLS_ROOT The z/OS remote directory that the tools you will install will be placed. 
#               For z/OS as a Service systems, this is /zaas1/tools
#ZOS_JAVA_HOME  The z/OS remote directory that Java is already installed in.
#               For z/OS as a Service systems, this is /usr/lpp/java/J8.0_64
#ZOS_GIT_USER   The git user name you will use for making changes in git. 
#               This is your real name, e.g. Mike Fulton
#ZOS_GIT_EMAIL   The email you will use for making changes in git, e.g. fultonm@ca.ibm.com
#ROCKET_TOOLS_DIR The local directory that the tools you want to install (in tar.gz form) are on your client, 
#                 e.g. /Users/fultonm/Documents/Development/RocketTools
#CERT_DIR        The local directory that the certificates you want to install (in binary form) are on your client, 
#                 e.g. /Users/fultonm/Documents/Development/Certificates
#SSH             Command to use for ssh (typically just ssh, but sometimes ssh -p <port>)
#SFTP            Command to use for sftp (typically just sftp, but sometimes sftp -p <port>)
#
export ZOS_USER="tstradm"
export ZOS_ADMIN="ibmuser"
export ZOS_HOST="fultonm.zosaas.ibm.com"
export ZOS_GIT_USER="Mike Fulton"
export ZOS_GIT_EMAIL="fultonm@ca.ibm.com"
export ROCKET_TOOLS_DIR="/Users/fultonm/Documents/Development/RocketTools"
export CERT_DIR="/Users/fultonm/Documents/Development/zOSCertificates"
export ZOS_TOOLS_ROOT="/zaas1/tools"
export ZOS_JAVA_HOME=/usr/lpp/java/J8.0_64
export SSH=ssh
export SFTP=sftp
export SCP=scp
