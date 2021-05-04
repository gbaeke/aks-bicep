param acrName string
param acrSku string
param acrAdminUserEnabled bool
param acrRole string
param principalId string  // this will come from aks output in main.bicep
param acrSubnet string
param vnetId string


resource acrpe 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: 'acr-pe'
  location: resourceGroup().location
  properties:{
    
    subnet:{
      id: acrSubnet
    }
    privateLinkServiceConnections:[
      {
        name: 'acr-pe'
        properties:{
          privateLinkServiceId: acr.id
          groupIds:[
            'registry'
          ]
        }
      }
    ]
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurecr.io'
  location: 'global'

  resource privateDNSZoneNetworkLink 'virtualNetworkLinks@2020-06-01' = {
    name: 'acrnetlink'
    location: 'global'
    properties:{
      registrationEnabled: false
      virtualNetwork:{
        id: vnetId
      }
    }
  }
  
}



resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = {
  name: '${acrpe.name}/default'
  properties:{
    privateDnsZoneConfigs:[
      {
        name: 'privatelink-azurecr-io'
        properties:{
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    publicNetworkAccess: 'Disabled'
  }

}

resource aksAcrPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  scope: acr
  properties: {
    principalId: principalId
    roleDefinitionId: acrRole
  }
}
