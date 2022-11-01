
nomad-dev:
	@read -p 'enter your vault token:' VAULT_TOKEN;\
	nomad agent -dev -bind 0.0.0.0 -dc homelab -vault-address "http://active.vault.service.consul:8200" -vault-create-from-role "nomad-cluster" -vault-enabled -vault-token $$VAULT_TOKEN

vault-dev:
	if [ -z "$(FILE)"]; then \
		./vault/standalone_vault.sh; \
	else \
		./vault/standalone_vault.sh $(FILE);\
	fi


create-dev:
	make -C ansible create-dev

destroy-dev:
	make -C ansible destroy-dev

docs
	mkdocs server
