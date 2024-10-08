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
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('App ServiceプランのSKUの名前とティアです。')
param appServicePlanSku object

@description('リソースをデプロイするAzureのリージョンです。')
param location string = 'japaneast'

@secure()
@description('SQLServerのAdministratorログインのユーザー名です。')
param sqlServerAdministratorLogin string

@secure()
@description('SQLServerのAdministratorログインのパスワードです。')
param sqlServerAdministratorPassword string

@description('SQLデータベースの名前とティア')
param sqlDatabaseSku object

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-aql'
var sqlDatabaseName = 'Employees'

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

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}
