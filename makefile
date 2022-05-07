
dev:
	@read -p 'enter your vault token:' VAULT_TOKEN;\
	nomad agent -dev -bind 0.0.0.0 -dc homelab -vault-address "http://active.vault.service.consul:8200" -vault-create-from-role "nomad-cluster" -vault-enabled -vault-token $$VAULT_TOKEN
