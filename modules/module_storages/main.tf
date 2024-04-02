resource "random_id" "randomId" {
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 4
}

resource "azurerm_storage_account" "storage" {
  count = length(var.machine_list)
  name = "${var.environment_tag}${random_id.randomId.hex}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment_tag
  }
}