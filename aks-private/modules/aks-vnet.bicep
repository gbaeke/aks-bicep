param vnetName string
param vnetPrefix string
param aksSubnetPrefix string
param ilbSubnetPrefix string
param bastionSubnetPrefix string
param fwSubnetPrefix string
param mgmtSubnetPrefix string


var subnets = [
  {
    name: 'aks'
    addressPrefix: aksSubnetPrefix
  }
  {
    name: 'ilb'
    addressPrefix: ilbSubnetPrefix
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: bastionSubnetPrefix
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: fwSubnetPrefix
  }
  {
    name: 'mgmt'
    addressPrefix: mgmtSubnetPrefix
  }  
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
        properties:{
          addressPrefix: subnet.addressPrefix
        }
    }]
  }
}

output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
output mgmtSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'mgmt')
