
requirements:
	ansible-galaxy install -g -f -r roles/requirements.yml

deploy_production:
	ansible-playbook site.yml -i production 

deploy_staging:
	ansible-playbook site.yml -i staging 

generate-token:
	@echo export VAULT_TOKEN=`vault token create -policy=ansible -field="token" -period 6h`
