storage_source "consul" {
address = "127.0.0.1:8500"
path    = "vault"
}

storage_destination "raft" {
  path = "/opt/vault/raft/"
  node_id = "oscar"
}

cluster_addr = "http://oscar:8201"
