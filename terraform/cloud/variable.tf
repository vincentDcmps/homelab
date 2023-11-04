variable "hcloud_token" {
  type = string
  # default = <your-api-token>
}
variable "hdns_token" {
  type=string
}
variable "location" {
  type=string
  default = "hel1"
}
variable "instances" {
  type=number
  default = "1"
}

variable "server_type" {
  type=string
  default = "CPX21"
}

variable "os_type" {
  type=string
  default = "rocky-9"
}

