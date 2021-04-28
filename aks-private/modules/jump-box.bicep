param vmName string
param adminPassword string
param subnetId string

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: resourceGroup().location
  properties:{
    ipConfigurations:[
      {
        name: 'ipConfig'
        properties:{
          subnet:{
            id: subnetId
          }
        }
      }
    ]
  }
}

resource jumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: resourceGroup().location
  properties: {
    hardwareProfile:{
      vmSize: 'Standard_B1ms'
    }
    storageProfile:{
      imageReference:{
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureUser'
      adminPassword: adminPassword
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic.id
          properties:{
            primary: true
          }
        }
      ]
    }
  }
}

