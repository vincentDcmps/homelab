
requirements:
	ansible-galaxy install -g  -r roles/requirements.yml

deploy_production: 
	ansible-playbook site.yml -i production -u ansible

deploy_staging: 
	ansible-playbook site.yml -i staging -u ansible


deploy_staging_base:
	ansible-playbook playbooks/sssd.yml -i staging -u ansible
	ansible-playbook playbooks/wireguard.yml -i staging -u ansible
	ansible-playbook playbooks/server.yml -i staging -u ansible



view-allvault:
	ansible-vault view `git grep -l "ANSIBLE_VAULT;1.1;AES256$$"`

