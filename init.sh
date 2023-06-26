#!/bin/bash

read -p 'Enter VAULT_ADDR (NO PORT): ' input_VAULT_ADDR
VAULT_ADDR=${input_VAULT_ADDR:-$VAULT_ADDR}

VAULT_OIDC_CALLBACK_ADDR=${VAULT_ADDR}:8250
VAULT_ADDR=${VAULT_ADDR}:8200

read -p 'Enter VAULT_ROOT_TOKEN: ' input_VAULT_TOKEN
VAULT_TOKEN=${input_VAULT_TOKEN:-$VAULT_TOKEN}

read -p 'Enter AUTH0_CLIENT_ID: ' input_AUTH0_CLIENT_ID
AUTH0_CLIENT_ID=${input_AUTH0_CLIENT_ID:-$AUTH0_CLIENT_ID}
if [ -z "$AUTH0_CLIENT_ID" ]; then
    echo "AUTH0_CLIENT_ID is not set. Exiting."
    exit 1
fi

read -p 'Enter AUTH0_CLIENT_SECRET: ' input_AUTH0_CLIENT_SECRET
AUTH0_CLIENT_SECRET=${input_AUTH0_CLIENT_SECRET:-$AUTH0_CLIENT_SECRET}
if [ -z "$AUTH0_CLIENT_SECRET" ]; then
    echo "AUTH0_CLIENT_SECRET is not set. Exiting."
    exit 1
fi

read -p 'Enter AUTH0_DOMAIN: ' input_AUTH0_DOMAIN
AUTH0_DOMAIN=${input_AUTH0_DOMAIN:-$AUTH0_DOMAIN}
if [ -z "$AUTH0_DOMAIN" ]; then
    echo "AUTH0_DOMAIN is not set. Exiting."
    exit 1
fi

export VAULT_ADDR=$VAULT_ADDR
export VAULT_OIDC_CALLBACK_ADDR=$VAULT_OIDC_CALLBACK_ADDR
export VAULT_TOKEN=$VAULT_TOKEN

export AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID
export AUTH0_CLIENT_SECRET=$AUTH0_CLIENT_SECRET
export AUTH0_DOMAIN=$AUTH0_DOMAIN

vault auth disable oidc
vault auth disable jwt
vault auth enable jwt

vault write auth/jwt/config \
    oidc_discovery_url="https://$AUTH0_DOMAIN/" \
    default_role="api_user" \
    bound_issuer="https://$AUTH0_DOMAIN/"

JWT_ACCESSOR=$(vault auth list -format=json | jq -r '.["jwt/"].accessor')

# define policy
read -d '' POLICY << EOF
path "secrets/data/{{identity.entity.aliases.$JWT_ACCESSOR.name}}/*" {
  capabilities = ["create", "update", "read", "delete"]
}
EOF

# write policy to a file
echo "$POLICY" > user-policy.hcl

# create new policy in vault
vault policy write user-policy user-policy.hcl

rm user-policy.hcl

vault write auth/jwt/role/api_user \
    bound_audiences="$AUTH0_CLIENT_ID" \
    allowed_redirect_uris="$VAULT_ADDR/ui/vault/auth/oidc/oidc/callback" \
    allowed_redirect_uris="$VAULT_OIDC_CALLBACK_ADDR/oidc/callback" \
    policies="default,user-policy"\
    bound_issuer="https://$AUTH0_DOMAIN/" \
    role_type=jwt \
    user_claim="sub"

