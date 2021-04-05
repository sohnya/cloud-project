variable "project_id" {
  description = "The Google Cloud ID of the project. Example: project-a-309016"
  type        = string
}

variable "google_credentials_file" {
  description = "Path to the google credentials json file"
  type        = string
}

variable "region" {
  description = "The region this project should be created in"
  type        = string
}

variable "zone" {
  description = "The zone this project should be created in"
  type        = string
}

variable "network" {
  description = "The VPC for which the rule applies"
  type        = string
}
