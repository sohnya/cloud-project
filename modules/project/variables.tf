variable "project_id" {
  description = "The Google Cloud ID of the project. Example: project-a-309016"
  type        = string
}

variable "project_name" {
  description = "A human readable project name. Example: a:"
  type        = string
}

variable "google_credentials_file" {
    description = "Path to the google credentials json file"
    type = string
}

variable "region" {
    description = "The region this project should be created in"
    type = string
}

variable "zone" {
    description = "The zone this project should be created in"
    type = string
}

variable "subnet_a_ip_range" {
    type = string
}

variable "subnet_b_ip_range" {
    type = string
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
