output "homelab_servers_status" {
  value = {
    for server in hcloud_server.merlin :
    server.name => server.status
  }
}

output "homelab_servers_ips" {
  value = {
    for server in hcloud_server.merlin :
    server.name => server.ipv4_address
  }
}
