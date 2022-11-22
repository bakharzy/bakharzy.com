#!/bin/bash
GREEN=$'\e\033[0;32m'
BLUE=$'\e\033[1;34m'
NC=$'\e\033[0m' # No Color
###################### Find User Principal ID ######################
echo
read -p "${GREEN}Enter the User Principal Email for role assignment: ${NC}" email
echo

userID=$(az ad user list --filter "mail eq '${email}'" --query "[].id" -o tsv)

echo "${GREEN}User ID = ${BLUE}" $userID

###################### Find Role Definition ID ######################
echo
read -p "${GREEN}Enter the name of the built-in role: ${NC}" roleName
echo

id=$(az role definition list --name "${roleName}" --query "[].name" -o tsv)

echo "${GREEN}Role ID = ${BLUE}"$id

###################### Deployment ######################
echo
read -p "${GREEN}Deployment Name: ${NC}" deploymentName
echo
read -p "${GREEN}Target Resource Group Name: ${NC}" resourceGroup
echo
az deployment group create --name ${deploymentName} --resource-group ${resourceGroup} -f role-assignment.bicep -p principalType='User' roleDefinitionId=${id} principalId=${userID}
