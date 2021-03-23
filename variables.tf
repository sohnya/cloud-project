# Static IP for A
variable "vpn_gateway_a_static_ip" {
  type    = string
  default = "35.227.55.197"
}

# Static IP for B
variable "vpn_gateway_b_static_ip" {
  type    = string
  default = "34.74.42.111"
}

variable "shared_secret" {
  type    = string
  default = "JIIKbNG6Z+6FGO2fTwkf9YZMY7tQH5bz"
}
