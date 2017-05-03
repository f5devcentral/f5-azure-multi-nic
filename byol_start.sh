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
## hostname
## location
## licenseKeys
## port

# Parse the command line arguments, primarily checking full params as short params are just placeholders
while getopts ":e:h:l:k:o:u:" opt; do
  case $opt in
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
    o)
      port=$OPTARG
      set -x
      ;;
    u)
      udrip=$OPTARG
      ;;
  esac
done

## Get the Default Gateway IP address of this device.
mydg=$(ip route get 1 | awk '{print $3;exit}')

## Execute the CloudLibs
#--network "--wait-for ONBOARD_DONE --log-level debug --output /var/log/network.log --host ${myip} -u admin -p ${adminpass} --multi-nic --default-gw ${mydg} --vlan external,1.0 --vlan internal,1.1 --self-ip external_ip,${myip},external --log-level debug --background --force-reboot --signal NETWORK_DONE" 
#--cluster " --wait-for NETWORK_DONE --output /var/log/cluster.log --log-level debug --host ${myip} -u admin -p ${adminpass} --config-sync-ip ${myip} --create-group --device-group Sync --sync-type sync-failover --device ${hostname} --auto-sync --save-on-auto-sync"


exec /usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/onboard.js --output /var/log/onboard.log --log-level debug --host ${externalip} --port ${port} -u admin --password-url file:///config/cloud/passwd --hostname ${hostname}.${location}.cloudapp.azure.com --license ${licenseKey} --ntp pool.ntp.org --db tmm.maxremoteloglength:2048 --module ltm:nominal
exec /usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/network.js --log-level debug --output /var/log/network.log --host ${externalip} --port ${port} -u admin --password-url file:///config/cloud/passwd --multi-nic --default-gw ${mydg} --vlan name:external, nic:1.0 --vlan name:internal, nic:1.1 --self-ip name:external_ip, address:${externalip}, vlan:external --self-ip name:internal_ip, address:${udrip}, vlan:internal --force-reboot
rm -f /config/cloud/passwd