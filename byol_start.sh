#!/bin/bash
###########################################################################
##       ffff55555                                                       ##
##     ffffffff555555                                                    ##
##   fff      f5    55         Deployment Script Version 0.0.1           ##
##  ff    fffff     555                                                  ##
##  ff    fffff f555555                                                  ##
## fff       f  f5555555             Written By: EIS Consulting          ##
## f        ff  f5555555                                                 ##
## fff   ffff       f555             Date Created: 12/14/2016            ##
## fff    fff5555    555             Last Updated: 12/14/2016            ##
##  ff    fff 55555  55                                                  ##
##   f    fff  555   5       This script will start the pre-configured   ##
##   f    fff       55       WAF configuration.                          ##
##    ffffffff5555555                                                    ##
##       fffffff55                                                       ##
###########################################################################
###########################################################################
##                              Change Log                               ##
###########################################################################
## Version #     Name       #                    NOTES                   ##
###########################################################################
## 12/14/16#  Thomas Stanley#    Created base functionality              ##
###########################################################################

### Parameter Legend  ###
## cluster
## external IP address
## hostname
## location
## licenseKeys
## mgmt IP address
## port
## udr IP address

# Parse the command line arguments, primarily checking full params as short params are just placeholders
while getopts ":c:e:h:l:k:m:o:u:" opt; do
  case $opt in
    c)
      cluster=$OPTARG
      ;;
    e)
      externalip=$OPTARG
      ;;
    h)
      hostname=$OPTARG
      ;;
    l)
      location=$OPTARG
      ;;
    k)
      licenseKey=$OPTARG
      ;;
    m)
      mgmtip=$OPTARG
      ;;
    o)
      port=$OPTARG
      ;;
    u)
      udrip=$OPTARG
      ;;
  esac
done

## Get the Default Gateway IP address of this device.

mydg=$(echo ${externalip%?})
mydg="${mydg}1"


## Execute the CloudLibs

/usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/onboard.js --output /var/log/onboard.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --hostname ${hostname}.${location}.cloudapp.azure.com --license ${licenseKey} --ntp pool.ntp.org --db tmm.maxremoteloglength:2048 --module ltm:nominal
/usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/network.js --output /var/log/network.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --default-gw ${mydg} --vlan name:external,nic:1.1 --vlan name:internal,nic:1.2 --self-ip name:external_ip,address:${externalip},vlan:external --self-ip name:internal_ip,address:${udrip},vlan:internal --force-reboot

if [ ${cluster} == "yes" ]; then
  /usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/cluster.js --output /var/log/cluster.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --config-sync-ip ${internalip} --create-group --device-group Sync --sync-type sync-failover --device ${hostname}.${location}.cloudapp.azure.com --auto-sync --save-on-auto-sync
fi
rm -f /config/cloud/passwd