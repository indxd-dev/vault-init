#!/bin/bash

read -p 'Enter VAULT_ADDR: ' input_VAULT_ADDR
VAULT_ADDR=${input_VAULT_ADDR:-$VAULT_ADDR}

read -p 'Enter VAULT_ROOT_TOKEN: ' input_VAULT_TOKEN
VAULT_TOKEN=${input_VAULT_TOKEN:-$VAULT_TOKEN}

vault write auth/jwt/login jwt=$1 role=api_user
