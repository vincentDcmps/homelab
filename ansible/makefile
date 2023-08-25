
requirements:
	ansible-galaxy install -g  -r roles/requirements.yml

deploy_production: generate-token
	ansible-playbook site.yml -i production -u ansible

deploy_staging: generate-token
	ansible-playbook site.yml -i staging -u ansible

generate-token:
	export VAULT_TOKEN=`vault token create -policy=ansible -field="token" -period 6h`

