param bastionName string
param subnetId string

resource bastionIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'ip-${bastionName}'
  location: resourceGroup().location
  properties:{
    publicIPAllocationMethod: 'Static'
  }
  sku:{
    name: 'Standard'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionName
  location: resourceGroup().location
  properties: {
   ipConfigurations: [
     {
        name: 'ipconfig1'
        properties:{
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: bastionIP.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }      
     }
   ] 
  }
}
