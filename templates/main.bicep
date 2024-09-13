resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'toylaunchstorageshuhei'
  location: 'japaneast'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: 'toy-product-launch-plan-starter'
  location: 'japaneast'
  sku: {
    name: 'F1'
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'toy-product-launch-shuhei-1'
  location: 'japaneast'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
