/* 
Note: If the target scope for custom role creation is subscription:
1. The targetScope constant must be set to 'subscription'. You just need to uncomment it!

2. Then change the assignableScopes to: 
  assignableScopes: [
      subscription().id
    ]

3. Deployment for subscription uses below command:
  az deployment sub create --location $LOCATION --name $DEPLOYMENT-NAME --template-file role.bicep --parameters role.parameters.json
*/

//targetScope = 'subscription'

@description('Array of actions for the roleDefinition')
param actions array

@description('Array of notActions for the roleDefinition')
param notActions array = []

@description('Friendly name of the role definition')
param roleName string

@description('Detailed description of the role definition')
param roleDescription string

var roleDefName = guid(subscription().id, string(actions), string(notActions))

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}
