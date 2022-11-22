targetScope = 'resourceGroup' 

@description('Principal type of the assignee.')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string

@description('the id for the role defintion, to define what permission should be assigned')
param roleDefinitionId string

@description('the id of the principal that would get the permission')
param principalId string


resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, roleDefinitionId, principalId)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: principalType
  }
}
