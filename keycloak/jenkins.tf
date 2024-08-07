locals {
  client_jenkins = <<-EOT
  {
                "clientId": "jenkins",
                "name": "",
                "description": "",
                "rootUrl": "https://${var.jenkins_ingress}/",
                "adminUrl": "https://${var.jenkins_ingress}/",
                "baseUrl": "",
                "surrogateAuthRequired": false,
                "enabled": true,
                "alwaysDisplayInConsole": false,
                "clientAuthenticatorType": "client-secret",
                "redirectUris": [
                "https://${var.jenkins_ingress}/*"
                ],
                "webOrigins": [
                "https://${var.jenkins_ingress}"
                ],
                "notBefore": 0,
                "bearerOnly": false,
                "consentRequired": false,
                "standardFlowEnabled": true,
                "implicitFlowEnabled": false,
                "directAccessGrantsEnabled": true,
                "serviceAccountsEnabled": false,
                "publicClient": true,
                "frontchannelLogout": true,
                "protocol": "openid-connect",
                "attributes": {
                "oidc.ciba.grant.enabled": "false",
                "oauth2.device.authorization.grant.enabled": "false",
                "backchannel.logout.session.required": "true",
                "backchannel.logout.revoke.offline.tokens": "false"
                },
                "authenticationFlowBindingOverrides": {},
                "fullScopeAllowed": true,
                "nodeReRegistrationTimeout": -1,
                "defaultClientScopes": [
                "web-origins",
                "acr",
                "roles",
                "profile",
                "email"
                ],
                "optionalClientScopes": [
                "address",
                "phone",
                "offline_access",
                "microprofile-jwt"
                ],
                "access": {
                "view": true,
                "configure": true,
                "manage": true
                }
              },
  EOT
}