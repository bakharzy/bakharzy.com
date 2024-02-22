#!/bin/bash
GREEN=$'\e\033[0;32m'
BLUE=$'\e\033[1;34m'
NC=$'\e\033[0m' # No Color


echo
read -p "Enter the Service Principal name you wish to create [${GREEN}Postfix '-sp' will be added${NC}]: " servicePrincipalName
servicePrincipalName="${servicePrincipalName}-sp"
   
read -p "Enter the Role Name to be assigned to service principal: " roleName
roleName=${roleName}

echo
echo "Select the service principal scope ${BLUE}"  
PS3='Select a scope: ' 
echo
options=("resource group" "management group" "quit")
select opt in "${options[@]}"

do
    case $opt in
        "management group")
            read -p "Enter the Management Group name for role assignment scope: " managementGroup
            managementGroup=${managementGroup}
            echo
            echo "${GREEN}Creating SP for RBAC with name ${BLUE}$servicePrincipalName${GREEN}, with role ${BLUE}$roleName${GREEN} and in scopes ${BLUE}/providers/Microsoft.Management/managementGroups/$managementGroup${NC}"
            echo
            az ad sp create-for-rbac --name $servicePrincipalName --role $roleName --scopes /providers/Microsoft.Management/managementGroups/$managementGroup
            break
            ;;
        "resource group")
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

            read -p "Enter the Resource Group name for role assignment scope: " resourceGroup
            resourceGroup=${resourceGroup}
            echo
            echo "${GREEN}Creating SP for RBAC with name ${BLUE}$servicePrincipalName${GREEN}, with role ${BLUE}$roleName${GREEN} and in scopes ${BLUE}/subscriptions/$subscriptionID/resourceGroups/$resourceGroup${NC}"
            echo
            az ad sp create-for-rbac --name $servicePrincipalName --role $roleName --scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup
            break
            ;;
        "quit")
            break
            ;;
        *) echo "invalid option";;
    esac
done
