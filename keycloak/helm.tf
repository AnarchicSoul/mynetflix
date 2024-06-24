#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = var.namespace
  chart      = "./keycloak/keycloak-21.4.1.tgz"

  values = [
    "${file("./keycloak/values.yaml")}",
    local.keycloak_config
  ]

  set {
      name  = "auth.adminPassword"
      value = var.password
    }
  set {
      name  = "ingress.hostname"
      value = var.keycloak_ingress
    }
  
} 

locals {
  keycloak_config = <<-EOT
ingress:
  extraTls:
    - secretName: wildcard-cert
      hosts:
        - ${var.keycloak_ingress}
keycloakConfigCli:
  configuration: 
    realm1.json: |
        {
          "realm": "realm1",
          "enabled": true,
          "clients": [
            {
              "clientId": "prometheus",
              "name": "",
              "description": "",
              "rootUrl": "https://prometheus.localhost/",
              "adminUrl": "https://prometheus.localhost/",
              "baseUrl": "https://prometheus.localhost/",
              "surrogateAuthRequired": false,
              "enabled": true,
              "alwaysDisplayInConsole": false,
              "clientAuthenticatorType": "client-secret",
              "secret": "z4Ux09d1GrR5GVUMleJVSPwYkDFdiaxZ",
              "redirectUris": [
                "https://prometheus.localhost/*"
              ],
              "webOrigins": [
                "https://prometheus.localhost"
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
                "post.logout.redirect.uris": "https://prometheus.localhost/*",
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
            {
              "clientId": "grafana",
              "name": "grafana",
              "description": "",
              "rootUrl": "http://${var.grafana_ingress}",
              "adminUrl": "http://${var.grafana_ingress}",
              "baseUrl": "",
              "surrogateAuthRequired": false,
              "enabled": true,
              "alwaysDisplayInConsole": false,
              "clientAuthenticatorType": "client-secret",
              "redirectUris": [
                "http://${var.grafana_ingress}/login/generic_oauth"
              ],
              "webOrigins": [
                "http://${var.grafana_ingress}"
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
                "client.secret.creation.time": "1718635809",
                "login_theme": "keycloak",
                "oauth2.device.authorization.grant.enabled": "false",
                "backchannel.logout.revoke.offline.tokens": "false",
                "use.refresh.tokens": "true",
                "oidc.ciba.grant.enabled": "false",
                "client.use.lightweight.access.token.enabled": "false",
                "backchannel.logout.session.required": "true",
                "client_credentials.use_refresh_token": "false",
                "acr.loa.map": "{}",
                "require.pushed.authorization.requests": "false",
                "tls.client.certificate.bound.access.tokens": "false",
                "display.on.consent.screen": "false",
                "token.response.type.bearer.lower-case": "false"
              },
              "authenticationFlowBindingOverrides": {},
              "fullScopeAllowed": true,
              "nodeReRegistrationTimeout": -1,
              "protocolMappers": [
                {
                  "name": "realm roles",
                  "protocol": "openid-connect",
                  "protocolMapper": "oidc-usermodel-realm-role-mapper",
                  "consentRequired": false,
                  "config": {
                    "introspection.token.claim": "true",
                    "multivalued": "true",
                    "userinfo.token.claim": "true",
                    "user.attribute": "foo",
                    "id.token.claim": "true",
                    "lightweight.claim": "false",
                    "access.token.claim": "true",
                    "claim.name": "realm_access.roles",
                    "jsonType.label": "String"
                  }
                },
                {
                  "name": "Client Host",
                  "protocol": "openid-connect",
                  "protocolMapper": "oidc-usersessionmodel-note-mapper",
                  "consentRequired": false,
                  "config": {
                    "user.session.note": "clientHost",
                    "introspection.token.claim": "true",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "clientHost",
                    "jsonType.label": "String"
                  }
                },
                {
                  "name": "Client ID",
                  "protocol": "openid-connect",
                  "protocolMapper": "oidc-usersessionmodel-note-mapper",
                  "consentRequired": false,
                  "config": {
                    "user.session.note": "client_id",
                    "introspection.token.claim": "true",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "client_id",
                    "jsonType.label": "String"
                  }
                },
                {
                  "name": "Client IP Address",
                  "protocol": "openid-connect",
                  "protocolMapper": "oidc-usersessionmodel-note-mapper",
                  "consentRequired": false,
                  "config": {
                    "user.session.note": "clientAddress",
                    "introspection.token.claim": "true",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "clientAddress",
                    "jsonType.label": "String"
                  }
                }
              ],
              "defaultClientScopes": [
                "web-origins",
                "acr",
                "profile",
                "roles",
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
            }
          ],
          "users": [
            {
              "username": "admin",
              "enabled": true,
              "emailVerified": true,
              "firstName": "Rootus",
              "lastName": "Adminus",
              "email": "local-admin@mail.com",
              "credentials": [
                {
                  "type": "password",
                  "value": "${var.superadmin}"
                }
              ]
            }
          ]
        }
  EOT
}

