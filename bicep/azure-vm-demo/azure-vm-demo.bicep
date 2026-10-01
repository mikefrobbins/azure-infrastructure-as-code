@description('Azure region where the resources are deployed.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
@minLength(1)
@maxLength(59)
param vmName string = 'vm-demo'

@description('Administrator username for the virtual machine.')
@minLength(1)
param adminUsername string

@description('SSH public key used to authenticate to the virtual machine.')
param sshPublicKey string

@description('Virtual machine size.')
param vmSize string = 'Standard_B2s'

@description('Virtual network address space.')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Workload subnet address space.')
param subnetAddressPrefix string = '10.10.1.0/24'

@description('Resource tags applied to supported resources.')
param tags object = {
  environment: 'demo'
  workload: 'azure-vm-demo'
  managedBy: 'Bicep'
}

var vnetName = 'vnet-${vmName}'
var subnetName = 'snet-workload'
var nsgName = 'nsg-${vmName}'
var nicName = 'nic-${vmName}'
var natGatewayName = 'nat-${vmName}'
var natPublicIpName = 'pip-${vmName}-nat'

resource nsg 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: nsgName
  location: location
  tags: tags
}

resource natPublicIp 'Microsoft.Network/publicIPAddresses@2025-09-01' = {
  name: natPublicIpName
  location: location
  sku: {
    name: 'StandardV2'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
}

resource natGateway 'Microsoft.Network/natGateways@2025-09-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'StandardV2'
  }
  properties: {
    idleTimeoutInMinutes: 10
    publicIpAddresses: [
      {
        id: natPublicIp.id
      }
    ]
  }
  tags: tags
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: nsg.id
          }
          natGateway: {
            id: natGateway.id
          }
        }
      }
    ]
  }

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet::subnet.id
          }
          primary: true
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2026-04-01' = {
  name: vmName
  location: location
  tags: tags

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername

      linuxConfiguration: {
        disablePasswordAuthentication: true
        provisionVMAgent: true

        patchSettings: {
          assessmentMode: 'AutomaticByPlatform'
        }

        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }

    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }

      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'

        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }

    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource guestAttestation 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = {
  parent: vm
  name: 'GuestAttestation'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Security.LinuxAttestation'
    type: 'GuestAttestation'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: 'GuestAttestation'
        }
      }
    }
  }
}

output vmResourceId string = vm.id
output vmPrincipalId string = vm.identity.principalId
output privateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output virtualNetworkResourceId string = vnet.id
output subnetResourceId string = vnet::subnet.id
output networkSecurityGroupResourceId string = nsg.id
output natGatewayResourceId string = natGateway.id
output natGatewayPublicIpAddress string = natPublicIp.properties.ipAddress
