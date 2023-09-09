param environment string = 'dev'
param location string
param region string
param workload string
param instance string = '01'
param tags object
param configValues array

var name = 'ac-${workload}-${environment}-${region}-${instance}'

resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  tags: tags
}


var endpointUri = 'https://${name}.azconfig.io'

var connectionString = configStore.listKeys().value[0].connectionString

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: configStore
  name: 'SYS_APPCONFIG_CONNECTIONSTRING'
  properties: {
    value: connectionString    
  }
}

resource configStoreEndpoint 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: configStore
  name: 'SYS_APPCONFIG_ENDPOINT'
  properties: {
    value: configStore.properties.endpoint    
  }
}


// Apply any other configuration values here
//
resource configStoreKeyValue2 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [ for(config,i) in configValues : {
  parent: configStore
  name: config.key
  properties: {
    value: config.value    
  }
}]

output endpointUri string = endpointUri
output connectionString string = connectionString


