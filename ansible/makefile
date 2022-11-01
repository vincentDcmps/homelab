
requirements:
	ansible-galaxy install -g  -r roles/requirements.yml

deploy_production:
	ansible-playbook site.yml -i production 

deploy_staging:
	ansible-playbook site.yml -i staging 

generate-token:
	@echo export VAULT_TOKEN=`vault token create -policy=ansible -field="token" -period 6h`


create-dev: requirements
	PY_COLORS=1 molecule converge
	
destroy-dev:
	PY_COLORS=1 molecule destroy
