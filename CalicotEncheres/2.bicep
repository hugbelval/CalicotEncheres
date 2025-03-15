param codeIdentification string
param location string = 'Canada Central'
param webAppName string
param webAppResourceGroup string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: 'kv-calicot-dev-${codeIdentification}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [] // Ajouté séparément après déploiement
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: keyVault.name
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webAppIdentity.properties.identity.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }
  dependsOn: [ keyVault, webAppIdentity ]
}

resource appSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${webAppName}/web'
  properties: {
    "ConnectionStrings": "@Microsoft.KeyVault(SecretUri=${keyVault.properties.vaultUri}secrets/ConnectionStrings/)"
  }
  dependsOn: [ keyVault, webApp ]
}
