[![Releases](https://img.shields.io/github/release/f5devcentral/f5-azure-multi-nic.svg)](https://github.com/f5devcentral/f5-azure-multi-nic/releases)
[![Commits](https://img.shields.io/github/commits-since/f5devcentral/f5-azure-multi-nic/v1.0.1.svg)](https://github.com/f5devcentral/f5-azure-multi-nic/commits)
[![Issues](https://img.shields.io/github/issues/f5devcentral/f5-azure-multi-nic.svg)](https://github.com/f5devcentral/f5-azure-multi-nic/issues)
[![TMOS Version](https://img.shields.io/badge/tmos--version-13.0.2-ff0000.svg)](https://github.com/f5devcentral/f5-azure-multi-nic)

# Azure Multi-NIC BIG-IP
Deploy a Multi-NIC BIG-IP into Azure  

<a target="_blank" href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ff5devcentral%2Ff5-azure-multi-nic%2Fmaster%2Fazuredeploy.json">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


### Release Notes:
Added Features:
* The ability to choose to cluster the BIG-IP's or not.
* The ability to choose up to 5 Public IP Addresses.
* Removed 2 NIC BIG-IP option.
  * The default configuration is now a 3 NIC BIG-IP where the first NIC is the Management NIC.  For the purposes of this template and ease of deployment, the Management NIC is configued with its own Public IP Address.  This of course can be removed to make the BIG-IP more secure.
  * The 2 NIC BIG-IP is a limited throughput capable BIG-IP and does not really provide any additional benefits over Single NIC BIG-IP's.  That is why it was removed.
* The ability to choose which BIG-IP Version you want to deploy.
  * Current version options are 12.1.2, 13.0.0.  Versions will be added in the future as they come out.
* The ability to choose BYOL vs Hourly images.
* The abiltiy to choose Good, Better, or Best feature sets.


This template will allow you to deploy more than one F5 BIG-IP into Azure with 3 or more network interfaces.  Remember that the total number of interfaces that can be deployed is predicated on the number of NIC objects supported by the underlying Virtual Instance Size.  If you choose to deploy on an instance size that only supports 2 NIC's for example but you request that 4 NIC's be created from this template, then template deployment will fail.  Please see this [link](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sizes/#size-tables) to determine the Virtual Instances Sizes and the number of NIC's that are supported.

### Parameter Definitions: ###

* vnetResourceGroupName
  * Required
  * The Resource Group Name that contains the Virtual Network that you are connecting the BIG-IP to.
* vnetName
  * Required
  * The Name of the virtual network that you are connecting the BIG-IP to.
* mgmtSubnetName
  * Required
  * Name of the subnet that the Management NIC will be attached to.
* externalSubnetName
  * Required
  * "Name of first subnet - with External Acccess to Internet.
* internalSubnetName
  * Required
  * Name of internal Subnet for UDR, NOT the subnet with the Servers in it.
* f5Name
  * Required
  * The Unique Name of the BIG-IP instance, that will be used for the Public DNS Name of the Public IP.
* f5LicenseType
  * Required
  * Choose the license type for the F5 BIG-IP you wish to deploy.  BYOL, or Hourly
* f5FeatureSet
  * Required
  * Choose the SKU of F5 BIG-IP you wish to deploy.  Good, Better, Best
* F5ThroughPutLevel
  * Required
  * Choose the throughput level for the F5 BIG-IP you wish to deploy.  25Mbps, 200Mbps, 1Gbps
* f5Version
  * Required
  * Choose the version of the F5 BIG-IP you wish to deploy.  12.1.2, 13.0.0
* f5Size
  * Required
  * The size of the BIG-IP Instance.
* numberOFBIGIPs
  * Required
  * The total number of BIG-IP's (Up to 4) you want to deploy.
* cluster
  * required
  * If you want to deploy more than one BIG-IP and would like them to be clusterd together, choose yes.
* numberOfAdditionalInterfaces
  * Required
  * By default two interfaces are deployed with this template.  If the VM instance that you have chosen supports more than two NIC objects, you can specify the additional number of NIC's here.  For example if you can have 4, you would specify 2 here.  Zero, means only 2 NIC's will be deployed.
* numberOfPublicIPAddresses
  * Required
  * By default one Public IP address is deployed.  Select up to 5 additional Public IP addresses to be deployed with these BIG-IP's.
* LicenseKeys
  * Not Required
  * A semi-colon delimited string of BYOL License Keys, one for each of the BIG-IP you intend to deploy. (No Spaces) Leave Blank for Hourly
* additionalSubnets
  * Not Required
  * A semi-colon delimited string of subnets, one for each of the additional interfaces. If zero, leave this field blank, if one enter a single subnet, if two type two subnet names separated by a semi-colon with no spaces.  Exmaple subnet3;subnet4.
* adminUsername
  * Required
  * User name to login to the BIG-IP.
* adminPassword
  * Required
  * Password to login to the BIG-IP.



### What get's deployed:

This template will deploy the following inside of either a new resource group or an existing one depending on what you select;

* Premium Storage Container for the BIG-IP's
* Public IP Address
* NIC objects for the F5 BIG-IP VM.
* F5 BIG-IP Virtual Machine

### During Deployment
During Deployment there are "TWO" references to a resource group.  One is:
 
<img src="https://raw.githubusercontent.com/tstanley93/Azure-Multi-NIC/master/Azure-Multi-NIC/Azure-Multi-NIC/rg_01.jpg" />

And gives you the opportunity to create new or use an existing.  This is the Resource Group where the BIG-IP's and all of their supporting objects will be placed.

There is also:

<img src="https://raw.githubusercontent.com/tstanley93/Azure-Multi-NIC/master/Azure-Multi-NIC/Azure-Multi-NIC/rg_02.jpg" /> 

This is where you specify the name of the resource group that contains the Virtual Network and Subnets that you want to connect the BIG-IP's to.  The template will use this value to specify the correct URI to find the Virtual Network inside of your subscription.



### How to connect to your Multi-NIC BIG-IP's to manage them:

After the deployment successfuly finishes, you can find the BIG-IP Management UI\SSH URLs by doing the following;  Find the resource group that was deployed, which is the same name as the "f5name".  When you click on this object you will see the deployment status.  Click on the deployment status, and then the deployment.  In the "Outputs" section you will find the URL's and ports that you can use to connect to the F5 BIG-IP. 
