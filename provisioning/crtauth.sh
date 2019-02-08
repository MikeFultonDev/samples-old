#!/bin/sh
cd ~
echo 'Local passphrase'
ssh-keygen -t rsa
#
${SSH} ${ZOS_USER}@${ZOS_HOST} mkdir -p .ssh
cat .ssh/id_rsa.pub | ${SSH} ${ZOS_USER}@${ZOS_HOST} 'cat >> .ssh/authorized_keys'

