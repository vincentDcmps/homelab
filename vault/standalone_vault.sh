CONSUL_HTTP_ADDR=http://127.0.0.1:8500

echo "launch consul dev server"
nohup consul agent -dev & 
if [ "$1" ]; then

  echo "restore snapshot $1"
  sleep 5
  consul snapshot restore -http-addr=$CONSUL_HTTP_ADDR $1

fi

tee /tmp/standalone-vault-dev.hcl << EOF

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
address     = "0.0.0.0:8200"
  tls_disable = 1
}
ui= true


EOF

echo "starting vault server please unseal before use "
vault server -config "/tmp/standalone-vault-dev.hcl"
