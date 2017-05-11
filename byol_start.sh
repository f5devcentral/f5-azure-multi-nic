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

lastchar=$(echo ${hostname: -1})

master=$(echo ${hostname%?})
master="${master}0"

## Execute the CloudLibs

/usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/onboard.js --output /var/log/onboard.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --hostname ${hostname}.${location}.cloudapp.azure.com --license ${licenseKey} --ntp pool.ntp.org --db tmm.maxremoteloglength:2048 --module ltm:nominal --no-reboot --signal ONBOARD_DONE &
/usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/network.js --wait-for ONBOARD_DONE --output /var/log/network.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --default-gw ${mydg} --vlan external,1.1 --vlan internal,1.2 --self-ip external_ip,${externalip},external --self-ip internal_ip,${udrip},internal --no-reboot --signal NETWORK_DONE &

if [ ${cluster} == "Yes" ]; then
    if [ ${lastchar} == "0" ]; then
        /usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/cluster.js --wait-for NETWORK_DONE --output /var/log/cluster.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --config-sync-ip ${udrip} --create-group --device-group Sync --sync-type sync-only --device ${hostname}.${location}.cloudapp.azure.com --auto-sync --save-on-auto-sync &
    else
        mastermgmtip=$(ping -c 1 ${master} | awk -F'[ :]' 'NR==2 { print $4 }')
        /usr/bin/f5-rest-node /config/cloud/f5-cloud-libs/scripts/cluster.js --wait-for NETWORK_DONE --output /var/log/cluster.log --log-level debug --host ${mgmtip} --port ${port} -u admin --password-url file:///config/cloud/passwd --config-sync-ip ${udrip} --join-group --remote-host ${mastermgmtip} --remote-user admin --remote-password-url file:///config/cloud/passwd --remote-port ${port} --device-group Sync --sync &
    fi
fi
wait
rm -f /config/cloud/passwd
reboot