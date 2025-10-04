	export TF_VAR_hetznerApiKey=`vault kv get -field=hdns_token secrets/hetzner`
	export TF_VAR_powerDnsApiKey=`vault kv get -field=API_KEY secrets/nomad/pdns-auth`
  export TF_VAR_hcloud_token=`vault kv get -field=hcloud_token secrets/hetzner`
