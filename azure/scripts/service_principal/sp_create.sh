#!/bin/bash
GREEN=$'\e\033[0;32m'
BLUE=$'\e\033[1;34m'
NC=$'\e\033[0m' # No Color

###################### Select default subscription ######################
echo
echo "${GREEN}Select your Azure Subscription OR press Enter to use the default ${NC}"
echo  
az account list -o table 
echo
read -p "Name or ID of the subscription: " subscription
subscription=${subscription}
if [ -z "$subscription" ]
then
        echo "${GREEN}No subscription entered, using default subscription${NC}"
else
        echo "${GREEN}Setting selected subscription ...${NC}"
        az account set --subscription $subscription
fi
subscriptionID=$(az account show --query id -o tsv)
# Verify the ID of the active subscription
echo "${GREEN}Using subscription ID:${BLUE} $subscriptionID${NC}"

###################### Creating Service Principal ######################
echo
read -p "Enter the Service Principal name you wish to create [${GREEN}Postfix '-sp' will be added${NC}]: " servicePrincipalName
servicePrincipalName="${servicePrincipalName}-sp"
   
read -p "Enter the role name to be assigned to service principal: " roleName
roleName=${roleName}

read -p "Enter the resource group name for role assignment scope: " resourceGroup
resourceGroup=${resourceGroup}
echo

echo "${GREEN}Creating SP for RBAC with name $servicePrincipalName, with role $roleName and in scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup${NC}"
echo
az ad sp create-for-rbac --name $servicePrincipalName --role $roleName --scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup