resource "azurerm_virtual_network" "vnet" {
  name = "vnet-${var.environment_tag}"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space = ["10.0.0.0/16"]
  tags = {
    environment = var.environment_tag
  }
}

resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_names)
  name = "subnet-${var.environment_tag}-${var.subnet_names[count.index]}"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.${count.index + 1}.0/24"]
}