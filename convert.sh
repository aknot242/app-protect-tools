#!/usr/bin/env bash

mkdir -p ./tmp
echo "Downloading an example ASM Policy from GitHub"
curl https://raw.githubusercontent.com/aknot242/ansible-uber-demo/master/ansible/roles/big-ip/files/JuiceShop_ASM_Policy.xml --output /tmp/asm_policy.xml

echo "Converting example ASM policy to NAP JSON declarative format. Unsupported features during conversion will show as warnings."
/opt/app_protect/bin/convert-policy -i /tmp/asm_policy.xml -o /tmp/nap_policy.json | jq

echo "Creating YAML version of converted policy"
yq eval -P /tmp/nap_policy.json > /tmp/nap_policy.yaml
