To provision git into a new z/OS system 'from scratch':
* logon to the new system and set a password, if you haven't done so yet
* edit setenv.sh to specify where to find resources on the local client as well as the z/OS target host
* download the rocket tools you need (at least bash, unzip, gzip, perl and git) into your ROCKET_TOOLS_DIR directory
* download your personal certificate and your global CA certificate into your CERT_DIR directory 
* run ./bringupSystem.sh to provision your base system
* run ./configSMPE.sh to configure SMP/E internet maintenance on your system
 
Go to: [Rocket Software Downloads](https://my.rocketsoftware.com/RocketCommunity/) to find the latest versions of tools to install

Go to: [Personal Certificate Info](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.gim3000/obtuc.htm) to determine where to get your personal certificate

Go to: [Global Certificate Info](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.gim3000/acac.htm) to determine where to get your Global certificate
