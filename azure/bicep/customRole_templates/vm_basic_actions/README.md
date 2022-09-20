# Bicep Template for custom role: VM Basic Actions

> Blog post: https://bakharzy.com/2022/09/20/example-of-azure-custom-role-creation/

This template creates a custom role (by default on resource group scope) for a user with basic action permissions on virtual machines. The user can start, restart and deallocate the VM. User can also see (read) the public IP and network interface of the VM.

This directory has two files. 
* The "role.bicep" file is the template file. 
* The "role.parameters.json" file. This is the parameters files which can be modified to create different custom roles. 

## Deployment (resource group)
You need to create a resource group first. Use the name of the resource group in the below command. The "DEPLOYMENT-NAME" you provide below will be the name you will see on Azure portal (RG -> Settings -> Deployments)

### Use the command below for deployment: 

```console
az deployment group create --name DEPLOYMENT-NAME --resource-group RESOURC-GROUP-NAME -f role.bicep -p role.parameters.json
```

## Deployment (subscription)
If the target scope for custom role creation is a subscription:
1. The targetScope constant must be set to 'subscription'. You just need to uncomment it from code!

2. Then change the assignableScopes to: 
 
```armasm
assignableScopes: [
      subscription().id
    ]
```


3. Deployment for subscription uses below command (please provide a location):

```console
az deployment sub create --location LOCATION --name DEPLOYMENT-NAME --template-file role.bicep --parameters role.parameters.json
```