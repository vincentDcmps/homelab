env := production
command ?= apply -auto-approve

deploy_vault:
ifneq (,$(wildcard ~/vaultUnseal/$(env)/rootkey))
	VAULT_TOKEN=$(shell cat ~/vaultUnseal/$(env)/rootkey)  tofu -chdir=vault $(command)  
else 
	tofu -chdir=vault $(command)  
endif

deploy_dns:
	TF_VAR_powerDnsApiKey=$(shell vault kv get -field=API_KEY secrets/nomad/pdns-auth) TF_VAR_hetznerApiKey=$(shell vault kv get -field=hdns_token secrets/hetzner) tofu -chdir=dns $(command)

deploy_cloud:
	TF_VAR_hetznerApiKey=$(shell vault kv get -field=hdns_token secrets/hetzner)  tofu -chdir=cloud $(command)

deploy_dev: 
	tofu -chdir=dev $(command)
