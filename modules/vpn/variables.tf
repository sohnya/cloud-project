variable "project_name" {
  description = "A human readable project name. Example: a:"
  type        = string
}

variable "local_static_ip_address" {
    type = string
}

variable "remote_static_ip_address" {
    type = string
}

variable "vpn_shared_secret" {
    type = string
}

variable "vpn_destination_range" {
    type = string
}