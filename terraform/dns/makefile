

setenv:
	export TF_VAR_hetznerApiKey=`vault kv get -field=hdns_token secrets/hetzner`
	export TF_VAR_powerDnsApiKey=`vault kv get -field=API_KEY secrets/nomad/pdns`

apply: setenv
	terraform apply

plan: setenv
	export
	terraform plan
