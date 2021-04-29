param vmName string
param adminPassword string
param subnetId string
param cloudInit string = '#cloud-config\n\nruncmd:\n - curl -sL https://aka.ms/InstallAzureCLIDeb | bash\n\nfinal_message: "cloud init was here\n"'

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
          privateIPAllocationMethod: 'Dynamic'
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
      osDisk:{
        createOption: 'FromImage'
        managedDisk:{
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      adminPassword: adminPassword
      linuxConfiguration:{
        disablePasswordAuthentication: false
      }
      customData: base64(cloudInit)
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

