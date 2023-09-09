/// getting started
/// az login
/// az account set --subscription "fs-zach-01"
/// az group create --name rg-sys-dev-scus-01 --location southcentralus --tags app-contact-email=zachbonham@gmail.com app-environemnt=DEV
/// az deployment group create --resource-group rg-sys-dev-scus-01 -f .\main.bicep --parameters app-contact-email=zachbonham@gmail.com app-environemnt=DEV

// we are creating top level resource group outside of main.bicep - everything else should be referenced as a bicep module
//

targetScope = 'resourceGroup'

@allowed([
  'dev'
  'uat'
  'prod'
])

// pipeline can override these values
//
@description('The environment we are deploying to.')
param environment string = 'dev'


@description('The Azure region name we are deploying to. Only used for the resource group location.')
param azureRegion string = 'southcentralus'

// storage account names are limited to 3-24 characters. 'southcentralus' region name blows this out of the water once we add other naming elements.
//
@description('The Azure region short name we are deploying to, using a short version because of storage account name length contraint.')
param regionShortName string = 'scus'

param resourceGroupLocation string = resourceGroup().location


@description('The owner of the resource')
param contact string = 'zachbonham@gmail.com'

// workload, component, etc.
// 
var workload = 'buzzlink-sys'
var instance = '01'

// tags specific metadata for organizing/identifying our resources
//
var tags = {
  'app-environment': toUpper(environment)
  'app-contact': contact
}

module cosmos 'cosmosdb.bicep' = {
  name: 'cosmos'
  params: {
    environment: environment
    location: resourceGroupLocation
    region: regionShortName
    tags: tags
    workload: workload
  }
}

module workspace 'logAnalytics.bicep' = {
  name: 'workspace'
  params: {
    environment: environment
    location: resourceGroupLocation
    region: regionShortName
    tags: tags
    workload: workload
  }
}

module appInsights 'appInsights.bicep' = {
  name: 'appInsights'
  params: {
    environment: environment
    location: resourceGroupLocation
    region: regionShortName
    workload: workload
    instance: instance
    tags: tags
    workspaceResourceId: workspace.outputs.workspaceResourceId
  }
}

// problem: resources, such as app insights, will generate configuration we need to capture in app config, 
// but I can't seem to reference the symbolic name from the module *outside of the module* like expected.  Think this
// is lack of knowledge on my part.  
// solution: accumulate configuration, then push it all at once when we create the app config resource.

var configValues = [
  { key: 'SYS_APPINSIGHTS__INSTRUMENTATIONKEY', value: appInsights.outputs.instrumentationKey }
  { key: 'SYS_APPINSIGHTS__CONNECTIONSTRING', value: appInsights.outputs.connectionString }
  { key: 'SYS_COSMOSDB__CONNECTIONSTRING', value: cosmos.outputs.connectionString }

  // other values will go here from the deployment
]
   
module appConfig 'appConfiguration.bicep' = {
  name: 'appConfig'
  params: {
    location: resourceGroupLocation
    environment: environment
    region: regionShortName
    workload: workload
    instance: instance
    tags: tags
    configValues: configValues
  }  
}

output azureRegion string = azureRegion
output azureRegionShortName string = regionShortName
output workload string = workload
output tags object = tags
output appConfigEndpointUri string = appConfig.outputs.endpointUri


