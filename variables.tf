variable "resource_group_name" {
  type = string
  description = "RG's name for the project"
}

variable "resource_group_location" {
  type = string
  description = "RG's location for the project"
}

variable "environment_list" {
  type = list(string)
  description = "Tags for the different environments"
}

variable "machine_list" {
  type = list(string)
  description = "Name of the machines in each environment"
}