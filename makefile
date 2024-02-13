
nomad-dev:
	@read -p 'enter your vault token:' VAULT_TOKEN;\
	nomad agent -dev -bind 0.0.0.0 -dc homelab -vault-address "http://active.vault.service.consul:8200" -vault-create-from-role "nomad-cluster" -vault-enabled -vault-token $$VAULT_TOKEN

vault-dev:
	if [ -z "$(FILE)"]; then \
		./vault/standalone_vault.sh; \
	else \
		./vault/standalone_vault.sh $(FILE);\
	fi

vagranup:
	vagrant up

create-dev: vagranup DNS-stagging
	make -C ansible deploy_staging
	make -C terraform deploy_vault env=staging
	VAULT_TOKEN=$(shell cat ~/vaultUnseal/staging/rootkey) 	python ./script/generate-vault-secret

create-dev-base: vagranup DNS-stagging
	make -C ansible deploy_staging_base


destroy-dev:
	vagrant destroy --force

serve:
	mkdocs serve

DNS-stagging: 
	 $(eval dns := $(shell dig oscar-dev.lan.ducamps.dev +short))
	 $(eval dns1 := $(shell dig nas-dev.lan.ducamps.dev +short))
	 sudo  resolvectl dns virbr2 "$(dns)" "$(dns1)";sudo resolvectl domain virbr2 "~consul";sudo systemctl restart systemd-resolved.service


DNS-production:
	 sudo  resolvectl dns virbr2 "";sudo resolvectl domain virbr2 "";sudo systemctl restart systemd-resolved.service

