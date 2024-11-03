param location string

param adminUsername string
@secure()
param adminPassword string

param HubVnetName string 
param SpokeVnetName string 
param OnpVnetName string

param vnetHubAddressPrefix string 
param subnetHubName string ='${HubVnetName}-Subnet'
param subnetHubAddressPrefix string
param nsgHubName string='${HubVnetName}-nsg'

param vnetSpokeAddressPrefix string
param subnetSpokeName string='${SpokeVnetName}-Subnet'
param subnetSpokeAddressPrefix string
param nsgSpokeName string='${SpokeVnetName}-nsg'

param vnetOnpAddressPrefix string
param subnetOnpName string='${OnpVnetName}-Subnet'
param subnetOnpAddressPrefix string
param nsgOnpName string='${OnpVnetName}-nsg'


param vmHubA_UbuntuName string='${HubVnetName}-Ubu'
param vmHubB_WindowsName string='${HubVnetName}-Win'
param vmSpoke_WindowsName string='${SpokeVnetName}-Win'
param vmOnp_WindowsName string='${OnpVnetName}-Win'


param bastionHostName string='${HubVnetName}-bastion'
param HubBastionSubnetAddressPrefix string
param HubAzfwsubnetAddressPrefix string

// 同一 Vnet に対するsubnetの作成はconflict起こしがち
module HubVnet 'NW _hub.bicep' = {
  name: 'HubVnet'
  params: {
    azureBastionSubnetAddressPrefix:HubBastionSubnetAddressPrefix

    nsgName: nsgHubName
    bastionHostName:bastionHostName
    location: location
    vnetName: HubVnetName
    vnetAddressPrefix: vnetHubAddressPrefix
    subnetName: subnetHubName
    subnetAddressPrefix: subnetHubAddressPrefix
    AzfwsubnetAddressPrefix:HubAzfwsubnetAddressPrefix
  }
}

module SpokeVnet 'NW.bicep' = {
  name: 'SpokeVnet'
  params: {
    nsgName: nsgSpokeName
    location: location
    vnetName: SpokeVnetName
    vnetAddressPrefix: vnetSpokeAddressPrefix
    subnetName: subnetSpokeName
    subnetAddressPrefix: subnetSpokeAddressPrefix
  }
}

module OnpVnet 'NW.bicep' = {
  name: 'OnpVnet'
  params: {
    nsgName: nsgOnpName
    location: location
    vnetName: OnpVnetName
    vnetAddressPrefix: vnetOnpAddressPrefix
    subnetName: subnetOnpName
    subnetAddressPrefix: subnetOnpAddressPrefix
  }
}

module vmHubA_Ubuntu 'VM.bicep' = {
  name: 'vmHubA_Ubuntu'
  params: {
    location: location
    vmName: vmHubA_UbuntuName
    vmSize: 'Standard_B2s'
    osImageOffer: '0001-com-ubuntu-server-focal'
    osImagePublisher: 'Canonical'
    osImageSku: '20_04-lts'
    adminUsername: adminUsername
    adminPassword: adminPassword
    osDiskStorageType:'StandardSSD_LRS'
    subnetId: HubVnet.outputs.subnetId
  }
  dependsOn: [
    HubVnet
  ]
}


module vmHubB_Windows 'VM.bicep' = {
  name: 'vmHubB_Windows'
  params: {
    location: location
    vmName: vmHubB_WindowsName
    vmSize: 'Standard_B2s'
    osImageOffer: 'WindowsServer'
    osImagePublisher: 'MicrosoftWindowsServer'
    osImageSku: '2019-Datacenter'
    adminUsername: adminUsername
    adminPassword: adminPassword
    osDiskStorageType: 'StandardSSD_LRS'
    subnetId: HubVnet.outputs.subnetId
  }
  dependsOn: [
    HubVnet
  ]
}

module vmSpoke_Windows'VM.bicep' = {
  name: 'vmSpoke_Windows'
  params: {
    location: location
    vmName: vmSpoke_WindowsName
    vmSize: 'Standard_B2s'
    osImageOffer: 'WindowsServer'
    osImagePublisher: 'MicrosoftWindowsServer'
    osImageSku: '2019-Datacenter'
    adminUsername: adminUsername
    adminPassword: adminPassword
    osDiskStorageType: 'StandardSSD_LRS'
    subnetId: SpokeVnet.outputs.subnetId
  }
  dependsOn: [
    SpokeVnet
  ]
}

module vmOnp_Windows'VM.bicep' = {
  name: 'vmOnp_Windows'
  params: {
    location: location
    vmName: vmOnp_WindowsName
    vmSize: 'Standard_B2s'
    osImageOffer: 'WindowsServer'
    osImagePublisher: 'MicrosoftWindowsServer'
    osImageSku: '2019-Datacenter'
    adminUsername: adminUsername
    adminPassword: adminPassword
    osDiskStorageType: 'StandardSSD_LRS'
    subnetId: OnpVnet.outputs.subnetId
  }
  dependsOn: [
    OnpVnet
  ]
}


output vnetHubId string = HubVnet.outputs.vnetId
output vnetSpokeId string = SpokeVnet.outputs.vnetId
output vnetOnpId string = OnpVnet.outputs.vnetId


resource vNetHubSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${HubVnetName}/to${SpokeVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: SpokeVnet.outputs.vnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    SpokeVnet
    HubVnet
  ]
}

resource vnNetSpokeHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${SpokeVnetName}/to${HubVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id:  HubVnet.outputs.vnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    SpokeVnet
  ]
}





