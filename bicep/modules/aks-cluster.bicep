param prefix string
param suffix string
param subnetId string
param adminUsername string = 'azureuser'
param adminPublicKey string

param aksSettings object = {
  kubernetesVersion: null
  identity: 'SystemAssigned'
  networkPlugin: 'azure'
  networkPolicy: 'calico'
  serviceCidr: '172.16.0.0/22' // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
  dnsServiceIP: '172.16.0.10' // Ip Address for K8s DNS
  dockerBridgeCidr: '172.16.4.1/22' // Used for the default docker0 bridge network that is required when using Docker as the Container Runtime.  Not used by AKS or Docker and is only cluster-routable.  Cluster IP based addresses are allocated from this range.  Can be safely reused in multiple clusters.
  outboundType: 'loadBalancer'
  loadBalancerSku: 'standard'
  sku_tier: 'Paid'				
  enableRBAC: true 
  aadProfileManaged: true
  adminGroupObjectIDs: [] 
}

param defaultNodePool object = {
  name: 'systempool01'
  count: 3
  vmSize: 'Standard_D2s_v3'
  osDiskSizeGB: 50
  osDiskType: 'Ephemeral'
  vnetSubnetID: subnetId
  osType: 'Linux'
  maxCount: 6
  minCount: 2
  enableAutoScaling: true
  type: 'VirtualMachineScaleSets'
  mode: 'System'
  orchestratorVersion: null
}


// https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/2020-03-01-preview/workspaces?tabs=json
resource aksAzureMonitor 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: '${prefix}-${suffix}-logA'
  tags: {}
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 30
    }
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=json#ManagedClusterAgentPoolProfile
resource aks 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
  name: aksSettings.clusterName
  location: resourceGroup().location
  identity: {
    type: aksSettings.identity
  }
  sku: {
    name: 'Basic'
    tier: aksSettings.sku_tier
  }
  properties: {
    kubernetesVersion: aksSettings.kubernetesVersion
    dnsPrefix: aksSettings.clusterName
    linuxProfile: {
      adminUsername: adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: adminPublicKey
          }
        ]
      }
    }
    
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: aksAzureMonitor.id
        }
      }
    }
    
    enableRBAC: aksSettings.enableRBAC

    enablePodSecurityPolicy: false // setting to false since PSPs will be deprecated in favour of Gatekeeper/OPA

    networkProfile: {
      networkPlugin: aksSettings.networkPlugin 
      networkPolicy: aksSettings.networkPolicy 
      serviceCidr: aksSettings.serviceCidr  // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
      dnsServiceIP: aksSettings.dnsServiceIP // Ip Address for K8s DNS
      dockerBridgeCidr: aksSettings.dockerBridgeCidr  // Used for the default docker0 bridge network that is required when using Docker as the Container Runtime.  Not used by AKS or Docker and is only cluster-routable.  Cluster IP based addresses are allocated from this range.  Can be safely reused in multiple clusters.
      outboundType: aksSettings.outboundType 
      loadBalancerSku: aksSettings.loadBalancerSku 
    }

    aadProfile: {
      managed: aksSettings.aadProfileManaged
      // enableAzureRBAC: true // Cross-Tenant Azure RBAC doesn't work - must be same tenant as the cluster subscription
      adminGroupObjectIDs: aksSettings.adminGroupObjectIDs
    }

    autoUpgradeProfile: {}

    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    
    agentPoolProfiles: [
      defaultNodePool
    ]
  }
}



output identity string = aks.identity.principalId
