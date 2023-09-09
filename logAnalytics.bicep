param environment string = 'dev'
param location string
param region string
param workload string
param instance string = '01'
param tags object

var name = 'ws-${workload}-${environment}-${region}-${instance}'

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output workspaceResourceId string = workspace.id
