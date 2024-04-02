variable "machine_list" {
  type = list(string)
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "environment_tag" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}