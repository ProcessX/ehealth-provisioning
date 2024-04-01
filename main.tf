resource "azurerm_resource_group" "rg-ehealth" {
  name = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = "production"
  }
}