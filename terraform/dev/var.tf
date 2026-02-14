variable "vms"{
  type =  list(object({
    name       = string
    memory     = number
    vcpu       = number
    disk_size  = number
    mac_address = string
  }))   
  default = [
    {
      name       = "oscar-dev"
      memory     = 2048
      vcpu       = 2
      disk_size  = 20
      mac_address = "52:54:00:ab:cd:01"
    },
    {
      name       = "merlin-dev"
      memory     = 1024
      vcpu       = 2
      disk_size   = 20
      mac_address = "52:54:00:ab:cd:02"
    },
    {
      name       = "gerard-dev"
      memory     = 2048 
      vcpu       = 2
      disk_size  = 20
      mac_address = "52:54:00:ab:cd:03"
    },
    {
      name       = "nas-dev"
      memory     = 2048
      vcpu       = 2
      disk_size  = 20
      mac_address = "52:54:00:ab:cd:04"
    }
  ]
}
