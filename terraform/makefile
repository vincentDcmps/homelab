env := production
command ?= apply -auto-approve

deploy_vault:
ifneq (,$(wildcard ~/vaultUnseal/$(env)/rootkey))
	VAULT_TOKEN=$(shell cat ~/vaultUnseal/$(env)/rootkey)  terraform -chdir=vault $(command)  
else 
	terraform -chdir=vault $(command)  
endif

deploy_dns:
	TF_VAR_powerDnsApiKey=$(shell vault kv get -field=API_KEY secrets/nomad/pdns) TF_VAR_hetznerApiKey=$(shell vault kv get -field=hdns_token secrets/hetzner) terraform -chdir=dns $(command)

deploy_cloud:
	TF_VAR_hetznerApiKey=$(shell vault kv get -field=hdns_token secrets/hetzner)  terraform -chdir=cloud $(command)

