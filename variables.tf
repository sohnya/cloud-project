variable "region" {
  type    = string
  default = "us-east1"
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}

variable "a_static_ip" {
  type    = string
  default = "35.237.20.53"
}

variable "b_static_ip" {
  type    = string
  default = "35.237.166.103"
}

variable "vpn_shared_secret" {
  type    = string
  default = "JIIKbNG6Z+6FGO2fTwkf9YZMY7tQH5bz"
}

variable "subnet_aa_ip_range" {
  type    = string
  default = "10.0.10.0/24"
}

variable "subnet_ab_ip_range" {
  type    = string
  default = "10.0.20.0/24"
}

variable "subnet_ba_ip_range" {
  type    = string
  default = "10.1.10.0/24"
}

variable "subnet_bb_ip_range" {
  type    = string
  default = "10.1.20.0/24"
}
