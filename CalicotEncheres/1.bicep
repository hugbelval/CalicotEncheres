
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

//2

param location string = 'Canada Central'
param imageUrl string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-calicot-dev-19'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 2
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'app-calicot-dev-19'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'ImageUrl'
          value: imageUrl
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource autoScaleSetting 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: 'autoscale-calicot-dev-19'
  location: location
  properties: {
    profiles: [
      {
        name: 'defaultProfile'
        capacity: {
          default: '1'
          minimum: '1'
          maximum: '2'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/sites'
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: 70
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              dimensions: []
              metricResourceUri: webApp.id
              timeWindow: 'PT5M'
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              cooldown: 'PT5M'
              value: '1'
            }
          }
        ]
      }
    ]
    targetResourceUri: webApp.id
    enabled: true
  }
}

