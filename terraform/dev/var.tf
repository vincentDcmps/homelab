variable "vms"{
  type =  list(object({
    name       = string
    memory     = number
    vcpu       = number
    disk_size  = number
  }))   
  default = [
    {
      name       = "oscar-dev"
      memory     = 2048
      vcpu       = 2
      disk_size  = 20
    },
    {
      name       = "merlin-dev"
      memory     = 1024
      vcpu       = 2
      disk_size   = 20
    },
    {
      name       = "gerard-dev"
      memory     = 2048 
      vcpu       = 2
      disk_size  = 20
    },
    {
      name       = "nas-dev"
      memory     = 2048
      vcpu       = 2
      disk_size  = 20
    }
  ]
}
