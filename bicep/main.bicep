param prefix string
param suffix string
param vnetPrefix string = '10.0.0.0/16'
param k8sVersion string = '1.19.7'
param adminUsername string = 'azureuser'
param adminPublicKey string
param adminGroupObjectIDs array = []
param vnetName string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'
param acrAdminUserEnabled bool = true
param acrRole string

@allowed([
  'Free'
  'Paid'
])
param aksSkuTier string = 'Free'
param aksVmSize string = 'Standard_D2s_v3'
param aksSubnets array = []
param aksSubnetName string = 'snet-aks'
param aksNodes int

@allowed([
  'azure'
  'calico'
])
param aksNetworkPolicy string = 'calico'

// create vnet if the vnetId is empty
resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: vnetName == '' ? '${prefix}-${suffix}-vnet' : vnetName
  location: resourceGroup().location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: aksSubnets
  } 
}

module aks 'modules/aks-cluster.bicep' = {
  name: 'AksCluster'
  
  params: {
    prefix: prefix
    suffix: suffix
    subnetId: '${vnet.id}/subnets/${aksSubnetName}'
    adminPublicKey: adminPublicKey

    aksSettings: {
      clusterName: '${prefix}-${suffix}-aks'
      identity: 'SystemAssigned'
      kubernetesVersion: k8sVersion
      networkPlugin: 'azure'
      networkPolicy: aksNetworkPolicy
      serviceCidr: '172.16.0.0/22' // can be reused in multiple clusters; no overlap with other IP ranges
      dnsServiceIP: '172.16.0.10'
      dockerBridgeCidr: '172.16.4.1/22'
      outboundType: 'loadBalancer'
      loadBalancerSku: 'standard'
      sku_tier: aksSkuTier			
      enableRBAC: true 
      aadProfileManaged: true
      adminGroupObjectIDs: adminGroupObjectIDs 
    }

    defaultNodePool: {
      name: 'pool01'
      count: aksNodes
      vmSize: aksVmSize
      osDiskSizeGB: 50
      osDiskType: 'Ephemeral'
      vnetSubnetID: '${vnet.id}/subnets/${aksSubnetName}'
      osType: 'Linux'
      type: 'VirtualMachineScaleSets'
      mode: 'System'
    }
    
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: '${prefix}${suffix}'
  location: resourceGroup().location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource aksAcrPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  scope: acr
  properties: {
    principalId: aks.outputs.identity
    roleDefinitionId: acrRole
  }
}
