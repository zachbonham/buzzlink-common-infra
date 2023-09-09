param environment string = 'dev'
param location string
param region string
param workload string
param instance string = '01'
param tags object
param databaseAccountOfferType string = 'Standard'
param enableFreeTier bool = environment == 'dev' ? true : false

@description('The default consistency level of the Cosmos DB account.')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string = 'Strong'
@description('Cosmos DB account type.')
@allowed([
  'Sql'
  'MongoDB'
  'Cassandra'
  'Gremlin'
  'Table'
])
param databaseApi string = 'Sql'

@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 2,147,483,647. Multi Region: 100,000 to 2,147,483,647.')
@minValue(10)
@maxValue(2147483647)
param maxStalenessPrefix int = 100000

@description('Max lag time (seconds). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84,600. Multi Region: 300 to 86,400.')
@minValue(5)
@maxValue(86400)
param maxIntervalInSeconds int = 300

@description('Enable system managed failover for regions. Ignored when mult-region writes is enabled')
param systemManagedFailover bool = true

var apiType = {
  Sql: {
    kind: 'GlobalDocumentDB'
    capabilities: []
  }
  MongoDB: {
    kind: 'MongoDB'
    capabilities: [
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
  }
  Cassandra: {
    kind: 'GlobalDocumentDB'
    capabilities: [
      {
        name: 'EnableCassandra'
      }
    ]
  }
  Gremlin: {
    kind: 'GlobalDocumentDB'
    capabilities: [
      {
        name: 'EnableGremlin'
      }
    ]
  }
  Table: {
    kind: 'GlobalDocumentDB'
    capabilities: [
      {
        name: 'EnableTable'
      }
    ]
  }
}

var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}

var name = 'cosmos-${workload}-${environment}-${region}-${instance}'

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: name
  location: location
  kind: apiType[databaseApi].kind
  properties: {
    enableFreeTier: enableFreeTier
    databaseAccountOfferType: databaseAccountOfferType
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: [
      {
        locationName: location
      }
    ]
    enableAutomaticFailover: systemManagedFailover
    capabilities: apiType[databaseApi].capabilities
  }
  tags: tags
}


var connectionString = listConnectionStrings(resourceId('Microsoft.DocumentDB/databaseAccounts', account.name), account.apiVersion).connectionStrings[0].connectionString

output connectionString string = connectionString


