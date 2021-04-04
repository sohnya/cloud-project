# Static IP for A
variable "a_static_ip" {
  type    = string
  default = "35.237.20.53"
}

# Static IP for B
variable "b_static_ip" {
  type    = string
  default = "35.237.166.103"
}

variable "vpn_shared_secret" {
    type = string
    default = "JIIKbNG6Z+6FGO2fTwkf9YZMY7tQH5bz"
}
