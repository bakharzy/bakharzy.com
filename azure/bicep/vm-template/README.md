# Virtual Machine Bicep Template - Flexible Operating System Selection

> Blog post: https://bakharzy.com/2022/09/02/a-bicep-template-for-linux-and-windows-virtual-machines/

This template creates a virtual machine (user can select the OS), along with necessary resources such as NIC, VNET, a default subnet, Public IP, Disk, and also install the aadsshlogin extension.  It also add two NSG rules for SSH and RDP access and restricts the access only to specific IP addresses (make sure to modify those in parameters file).

This directory has two files. 
* The "vm.bicep" file is the template file. Different resources of the virtual machine are defined in this file.
* The "vm.parameters.json" file. This is the parameters files which can be modified for each deployment. 

## Deployment
First, you need to create a resource group. Use the name of the resource group in the below command. Please note that virtual machine resources will be created in the same region/location as the resource group. The "DEPLOYMENT-NAME" you provide below will be the name you will see on Azure portal (RG -> Settings -> Deployments)

### Use the command below for deployment: 

        az deployment group create --name DEPLOYMENT-NAME --resource-group RESOURC-GROUP-NAME --template-file vm.bicep --parameters vm.parameters.json

## Notes

* You will be prompted to provide a name for the virtual machine and admin username and password/SSH Public Key. 
* In addition, you will be prompted to choose the operating system and OS SKU. 
* Make sure to check the parameters files and change the parameters based on your needs. 
* For Linux virtual machines, we recommend using AD Login. To give access to virtual machine using Azure AD login, you need to add a new role on the resource group level. Instructions for adding the role can be found [here](https://docs.microsoft.com/en-us/azure/active-directory/devices/howto-vm-sign-in-azure-ad-linux#azure-ad-portal)
    * Client then can connect using this command: 

            az ssh vm -g RESOURCE_GROUP_NAME -n VM_NAME
* For Windows virtual machines, password authentication works fine. If you want to use Azure AD login, some requirements should be met from the client side. Remote connection to VMs that are joined to Azure AD is allowed only from Windows 10 or later PCs that are Azure AD registered (starting with Windows 10 20H1), Azure AD joined, or hybrid Azure AD joined to the same directory as the VM. Read more [here](https://docs.microsoft.com/en-us/azure/active-directory/devices/howto-vm-sign-in-azure-ad-windows#requirements). 

