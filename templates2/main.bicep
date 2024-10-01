@description('環境の名前です。dev,test,prodのどれかを指定します。')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('solutionのユニークな名前です。リソースの名前をユニークにします。')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@description('App Serviceプランのインスタンス数です。')
param appServicePlanInstanceCount int = 1

@description('App ServiceプランのSKUの名前とティアです。')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('リソースをデプロイするAzureのリージョンです。')
param location string = 'japaneast'

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
