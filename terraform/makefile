env := production

deploy_vault:
ifneq (,$(wildcard ~/vaultUnseal/$(env)/rootkey))
	VAULT_TOKEN=$(shell cat ~/vaultUnseal/$(env)/rootkey)  terraform -chdir=vault apply  -auto-approve
else 
	terraform -chdir=vault apply  -auto-approve
endif

deploy_dns:
	TF_VAR_powerDnsApiKey=$(shell vault kv get -field=API_KEY secrets/nomad/pdns) TF_VAR_hetznerApiKey=$(shell vault kv get -field=hdns_token secrets/hetzner) terraform -chdir=dns apply

deploy_cloud:
	TF_VAR_hetznerApiKey=$(shell vault kv get -field=hdns_token secrets/hetzner)  terraform -chdir=cloud apply

