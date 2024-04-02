resource "azurerm_public_ip" "public_ip" {
  count = length(var.public_ip_names)
  name = "ip-${var.environment_tag}-${var.public_ip_names[count.index]}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  allocation_method = "Dynamic"
  tags = {
    environment = var.environment_tag
  }
}