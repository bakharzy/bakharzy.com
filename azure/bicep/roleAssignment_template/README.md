# Role Assignment Bicep Template - Built-in Roles for User Principal

> Blog post: https://bakharzy.com/2022/11/22/bicep-template-for-azure-role-assignment/

This template creates a role assignment for a specific User principal on the scope of a specified resource group.

This directory has two other files. 
* The "role-assignment.bicep" file is the template file. 
* The "deploy.sh" file. This script will be used to fetch roleDefinitionId and principalId which is required for deployment. The same script will also run the deployment command.  

## Prerequisite 
You need to have <u>User Access Administrator</u> role to be able to assign a role to other principals.

## Deployment (resource group)
When running the "deploy.sh" script, you will be prompted for 4 inputs. 
1. Email address of the User principal (e.g. email@example.com)
2. The name of the built-in role (e.g. Contributor (or) Virtual Machine Administrator Login)
3. The "Deployment Name" you provide will be the name you will see on Azure portal (RG -> Settings -> Deployments)
4. Resource group name. Use the name of an existing target resource group in the script when prompted. 

### Use the deploy.sh script for deployment

```console
bash deploy.sh
```