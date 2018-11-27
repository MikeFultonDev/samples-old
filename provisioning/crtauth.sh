cd ~
echo 'Local passphrase'
ssh-keygen -t rsa
#
ssh ${ZOS_USER}@${ZOS_HOST} mkdir -p .ssh
cat .ssh/id_rsa.pub | ssh ${ZOS_USER}@${ZOS_HOST} 'cat >> .ssh/authorized_keys'
#ssh ${ZOS_USER}@${ZOS_HOST} "chmod 700 .ssh; chmod 640 .ssh/authorized_keys"

