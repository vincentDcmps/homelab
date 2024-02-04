
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
	make -C terraform deploy_vault

create-dev-base: vagranup DNS-stagging
	make -C ansible deploy_staging_base


destroy-dev:
	vagrant destroy --force

serve:
	mkdocs serve

DNS-stagging: 
	 $(eval dns := $(shell dig oscar-dev.ducamps-dev.eu +short))
	 sudo  resolvectl dns virbr2 "$(dns)";sudo resolvectl domain virbr2 "~consul"


DNS-production:
	 sudo  resolvectl dns virbr2 "";sudo resolvectl domain virbr2 "" 
