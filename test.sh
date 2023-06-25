#!/bin/bash
# Assuming you have the token from running bash token.sh {JWT} as your VAULT_TOKEN env var, and you have the VAULT_ADDR
# set, this will run smoothly:
export VAULT_TOKEN=
export VAULT_ADDR=
export AUTH0_USER_ID=
vault kv put "secrets/$AUTH0_USER_ID/my-secret" key1="key" key2="yek"
vault kv get "secrets/$AUTH_USER_ID/my-secret"

