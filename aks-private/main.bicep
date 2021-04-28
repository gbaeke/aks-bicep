targetScope='subscription'

// resource group parameters
param rgName string = 'aks-rg'
param location string = 'westeurope'

// vnet parameters
param vnetName string = 'aks-vnet'
param vnetPrefix string = '10.50.0.0/16'
param aksSubnetPrefix string = '10.50.1.0/24'
param ilbSubnetPrefix string = '10.50.2.0/24'
param bastionSubnetPrefix string = '10.50.3.0/24'
param fwSubnetPrefix string = '10.50.4.0/24'
param mgmtSubnetPrefix string = '10.50.5.0/24'

// bastion parameters
param bastionName string = 'aks-bastion'

// jumpbox parameters
param adminPassword string


// aks parameters
/* param k8sVersion string = '1.19.7'
param adminUsername string = 'azureuser'
param adminPublicKey string
param adminGroupObjectIDs array = []
@allowed([
  'Free'
  'Paid'
])
param aksSkuTier string = 'Free'
param aksVmSize string = 'Standard_D2s_v3'
param aksSubnets array = []
param aksSubnetName string = 'snet-aks'
param aksNodes int */

/* @allowed([
  'azure'
  'calico'
])
param aksNetworkPolicy string = 'calico'

// acr parameters
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'
param acrAdminUserEnabled bool = true
param acrRole string */

// create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: location
}

module vnet 'modules/aks-vnet.bicep' = {
  name: vnetName
  scope: rg
  params: {
    vnetName: vnetName
    vnetPrefix: vnetPrefix
    aksSubnetPrefix: aksSubnetPrefix
    ilbSubnetPrefix: ilbSubnetPrefix
    bastionSubnetPrefix: bastionSubnetPrefix
    fwSubnetPrefix: fwSubnetPrefix
    mgmtSubnetPrefix: mgmtSubnetPrefix
  }
}

module bastion 'modules/bastion.bicep' = {
  name: bastionName
  scope: rg
  params: {
    bastionName: bastionName
    subnetId: vnet.outputs.bastionSubnetId
  }
}
