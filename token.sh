#!/bin/bash

read -p 'Enter VAULT_ADDR: ' input_VAULT_ADDR
VAULT_ADDR=${input_VAULT_ADDR:-$VAULT_ADDR}:8200

vault write auth/jwt/login jwt=$1
