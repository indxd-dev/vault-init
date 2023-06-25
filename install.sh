#!/bin/bash

# Define Vault version
VAULT_VERSION="1.8.0"

# Detect the OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected OS is Ubuntu/Debian"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vault
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected OS is macOS"
    brew tap hashicorp/tap
    brew install hashicorp/tap/vault
else
    echo "This script does not support your OS."
    exit 1
fi

# Check Vault version
vault -v

