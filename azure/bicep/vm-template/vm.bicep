@description('Name of the virtual machine:')
param virtualMachineName string

@description('Select the OS type to deploy:')
@allowed([
  'Windows'
  'Linux'
])
param operatingSystem string

@description('The OS version (SKU):')
@allowed([
  'win10'
  'win11'
  'ubuntu2004'
  'ubuntu2004gen2'
])
param operatingSystemSKU string

@description('Username for admin account:')
param adminUsername string

@description('Select the authentication type: (Password for Windows and SSH Public Key for Linux)')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string

@description('Admin password or SSH key:')
@secure()
param adminPasswordOrPublicKey string

@description('Size of the virtual machine')
param virtualMachineSize string

@description('Location for all resources')
param location string = resourceGroup().location

// -- Other Parameters -- 

param enableAcceleratedNetworking bool = true

@description('Name of the Network Security Group')
param networkSecurityGroupName string = '${virtualMachineName}-nsg'

@description('Network Security Group Inbound and Outbound rules')
param networkSecurityGroupRules array

@description('Name of the virtual machine subnet')
param subnetName string = '${virtualMachineName}-snet'

@description('Name of VM virtual network')
param virtualNetworkName string = '${virtualMachineName}-vnet'

@description('Address Prefix for virtual network')
param addressPrefixes array

param subnets array

@description('Name of the public IP address')
param publicIpAddressName string = '${virtualMachineName}-publicIP'

@description('Allocation method of the public IP: Dynamic or Static')
@allowed([
  'Dynamic'
  'Static'
])
param publicIpAddressType string

@description('Public IP SKU: Basic or Standard')
@allowed([
  'Basic'
  'Standard'
])
param publicIpAddressSku string

@description('Specify what happens to the public IP address when the VM is deleted')
@allowed([
  'Delete'
  'Detach'
])
param pipDeleteOption string = 'Delete'

@description('Type of the OS disk')
param osDiskType string

@description('Specifies whether OS Disk should be deleted or detached upon VM deletion: Delete or Detach')
@allowed([
  'Delete'
  'Detach'
])
param osDiskDeleteOption string = 'Delete'


@description('Specify what happens to the network interface when the VM is deleted')
@allowed([
  'Delete'
  'Detach'
])
param nicDeleteOption string = 'Delete'


// --- Variables ---
var osImageReference = {
  win10: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: '21h1-pron-g2'
    version: 'latest'
  }
  win11: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-11'
    sku: 'win11-21h2-pron'
    version: 'latest'
  }
  ubuntu2004: {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
  }
  ubuntu2004gen2: {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
}

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrPublicKey
      }
    ]
  }
}

var networkInterfaceName = '${virtualMachineName}-netInt'
var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetId}/subnets/${subnetName}'
var aadLoginExtensionName = (operatingSystem == 'Linux') ? 'AADSSHLoginForLinux' : 'AADLoginForWindows'

// -- Resource definitions -- 

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroupName_resource
    virtualNetworkName_resource
    publicIpAddressName_resource
  ]
}

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: osImageReference[operatingSystemSKU].publisher
        offer: osImageReference[operatingSystemSKU].offer
        sku: osImageReference[operatingSystemSKU].sku
        version: osImageReference[operatingSystemSKU].version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrPublicKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource virtualMachineName_aadLoginExtensionName 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  parent: virtualMachineName_resource
  name: aadLoginExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: aadLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

output adminUsername string = adminUsername
