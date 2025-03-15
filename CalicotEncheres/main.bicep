
param location string = 'Canada Central'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-dev-calicot-cc-19'
  location: location
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
param imageUrl string 

module webModule './web.bicep' = {
  name: 'web'
  params: {
    imageUrl: imageUrl
  }
}

//3
param adminUser string = 'adminuser'
@secure()
param adminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'sqlsrv-calicot-dev-19'
  location: location
  properties: {
    administratorLogin: adminUser
    administratorLoginPassword: adminPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'sqldb-calicot-dev-19'
  parent: sqlServer
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  location: location
}

resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'AllowAllIPs'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-calicot-dev-19'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'ConnectionStrings'
  properties: {
    value: 'secret12678!!!!$$$$SSS'
  }
}

