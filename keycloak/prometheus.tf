locals {
  client_prometheus = <<-EOT
  {
                "clientId": "prometheus",
                "name": "",
                "description": "",
                "rootUrl": "https://${var.prometheus_ingress}/",
                "adminUrl": "https://${var.prometheus_ingress}/",
                "baseUrl": "https://${var.prometheus_ingress}/",
                "surrogateAuthRequired": false,
                "enabled": true,
                "alwaysDisplayInConsole": false,
                "clientAuthenticatorType": "client-secret",
                "secret": "z4Ux09d1GrR5GVUMleJVSPwYkDFdiaxZ",
                "redirectUris": [
                "https://${var.prometheus_ingress}/*"
                ],
                "webOrigins": [
                "https://${var.prometheus_ingress}"
                ],
                "notBefore": 0,
                "bearerOnly": false,
                "consentRequired": false,
                "standardFlowEnabled": true,
                "implicitFlowEnabled": true,
                "directAccessGrantsEnabled": false,
                "serviceAccountsEnabled": false,
                "publicClient": false,
                "frontchannelLogout": true,
                "protocol": "openid-connect",
                "attributes": {
                "oidc.ciba.grant.enabled": "false",
                "client.secret.creation.time": "1719221050",
                "backchannel.logout.session.required": "true",
                "post.logout.redirect.uris": "https://${var.prometheus_ingress}/*",
                "oauth2.device.authorization.grant.enabled": "false",
                "display.on.consent.screen": "false",
                "backchannel.logout.revoke.offline.tokens": "false",
                "login_theme": "",
                "frontchannel.logout.url": "",
                "backchannel.logout.url": ""
                },
                "authenticationFlowBindingOverrides": {},
                "fullScopeAllowed": true,
                "nodeReRegistrationTimeout": -1,
                "protocolMappers": [
                {
                    "name": "Groups",
                    "protocol": "openid-connect",
                    "protocolMapper": "oidc-group-membership-mapper",
                    "consentRequired": false,
                    "config": {
                    "full.path": "true",
                    "introspection.token.claim": "true",
                    "userinfo.token.claim": "true",
                    "multivalued": "true",
                    "id.token.claim": "true",
                    "lightweight.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "groups"
                    }
                },
                {
                    "name": "aud-mapper-oauth2-proxy",
                    "protocol": "openid-connect",
                    "protocolMapper": "oidc-audience-mapper",
                    "consentRequired": false,
                    "config": {
                    "included.client.audience": "oauth2-proxy",
                    "introspection.token.claim": "false",
                    "userinfo.token.claim": "true",
                    "id.token.claim": "true",
                    "lightweight.claim": "false",
                    "access.token.claim": "true"
                    }
                }
                ],
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
                },
                "authorizationServicesEnabled": false
              },
  EOT
}