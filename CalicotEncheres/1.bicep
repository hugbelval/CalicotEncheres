
///
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-dev-calicot-cc-19'
  location: 'Canada Central'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-dev-web-cc-19'
        properties: {
          addressPrefix: '10.0.0.0/24'
          
        }
      }
      {
        name: 'snet-dev-db-cc-19'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

//2.

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: 'app-calicot-dev-19'
  //tier:'Standard S1'
  location: 'Canada Central'
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: 'webServerFarms.id'
  }
  
}


