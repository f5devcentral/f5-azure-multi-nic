# Azure Mulit-NIC BIG-IP
Deploy a Multi-NIC BIG-IP into Azure  

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftstanley93%2FAzure-Multi-NIC%2Fmaster%2FAzure-Multi-NIC%2FAzure-Multi-NIC%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### Description:
This template will deploy a F5 BIG-IP into Azure with 2 network interfaces.  This template could be modified for additional NIC's as needed.

### Parameter Definitions: ###

* resourceGroupName
  * Required
  * The Resource Group Name that contains the Virtual Network that you are connecting the BIG-IP to.
* vnetName
  * Required
  * The Name of the virtual network that you are connecting the BIG-IP to.
* externalSubnetName
  * Required
  * "Name of first subnet - with External Acccess to Internet.
* internalSubnetName
  * Required
  * Name of internal Subnet for UDR, NOT the subnet with the Servers in it.
* f5Name
  * Required
  * The Unique Name of the BIG-IP instance, that will be used for the Public DNS Name of the Public IP.
* f5Size
  * Required
  * The size of the BIG-IP Instance.
* externalIPAddress
  * Required
  * The IP address of the new BIG-IP
* internalIPAdress
  * Required
  * The IP address of the new BIG-IP
* adminUsername
  * Required
  * User name to login to the BIG-IP.
* adminPassword
  * Required
  * Password to login to the BIG-IP.



### What get's deployed:

This template will deploy the following inside of either a new resource group or an existing one depending on what you select;

* Storage Container
* Public IP Address
* NIC objects for the F5 BIG-IP VM.
* F5 BIG-IP Virtual Machine

### During Deployment
During Deployment there are “TWO” references to a resource group.  One is:
 
<img src="https://raw.githubusercontent.com/tstanley93/Azure-Multi-NIC/master/Azure-Multi-NIC/Azure-Multi-NIC/rg_01.jpg" />

And gives you the opportunity to create new or use an existing.  This is the Resource Group where the BIG-IP's and all of their supporting objects will be placed.

There is also:

<img src="https://raw.githubusercontent.com/tstanley93/Azure-Multi-NIC/master/Azure-Multi-NIC/Azure-Multi-NIC/rg_02.jpg" /> 

This is where you specify the name of the resource group that contains the Virtual Network and Subnets that you want to connect the BIG-IP's to.  The template will use this value to specify the correct URI to find the Virtual Network inside of your subscription.



### How to connect to your Web Application Firewalls to manage them:

After the deployment successfuly finishes, you can find the BIG-IP Management UI\SSH URLs by doing the following;  Find the resource group that was deployed, which is the same name as the "dnsNameForPublicIP".  When you click on this object you will see the deployment status.  Click on the deployment status, and then the deployment.  In the "Outputs" section you will find the URL's and ports that you can use to connect to the F5 BIG-IP. 