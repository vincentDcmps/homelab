
nomad-dev:
	@read -p 'enter your vault token:' VAULT_TOKEN;\
	nomad agent -dev -bind 0.0.0.0 -dc homelab -vault-address "http://active.vault.service.consul:8200" -vault-create-from-role "nomad-cluster" -vault-enabled -vault-token $$VAULT_TOKEN

vault-dev:
	if [ -z "$(FILE)"]; then \
		./vault/standalone_vault.sh; \
	else \
		./vault/standalone_vault.sh $(FILE);\
	fi

devapply:
	make -C  terraform deploy_dev

devdestroy:
	make -C terraform deploy_dev command="destroy -auto-approve"

devshutdown: 
	sudo virsh list --all --name |grep ".*-dev" |xargs -I {} sudo virsh shutdown  {}

devstart:
	sudo virsh list --all --name |grep ".*-dev" |xargs -I {} sudo virsh start {}

create-dev: devapply DNS-stagging
	make -C ansible deploy_staging
	make -C terraform deploy_vault env=staging
	VAULT_TOKEN=$(shell cat ~/vaultUnseal/staging/rootkey) 	python ./script/generate-vault-secret

create-dev-base: devapply DNS-stagging
	make -C ansible deploy_staging_base



serve:
	mkdocs serve

DNS-stagging: 
	 $(eval dns := $(shell dig oscar-dev.lan.ducamps.dev +short))
	 $(eval dns1 := $(shell dig nas-dev.lan.ducamps.dev +short))
	 sudo resolvectl  dns homelab_dev 192.168.2.1;sudo resolvectl domain homelab_dev "~consul";sudo resolvectl domain homelab_dev "lan.ducamps.dev";sudo systemctl restart systemd-resolved.service


DNS-production:
	 sudo resolvectl domain homelab_dev "";sudo systemctl restart systemd-resolved.service

