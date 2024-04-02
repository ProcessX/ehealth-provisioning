resource "azurerm_public_ip" "public_ip" {
  count = length(var.machine_list)
  name = "ip-${var.environment_tag}-${var.machine_list[count.index]}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  allocation_method = "Dynamic"
  tags = {
    environment = var.environment_tag
  }
}

resource "azurerm_network_security_group" "nsg" {
  count = length(var.machine_list)
  name = "nsg-${var.environment_tag}-${var.machine_list[count.index]}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment_tag
  }
}

resource "azurerm_network_interface" "nic"{
  count = length(var.machine_list)
  name = "nic-${var.environment_tag}-${var.machine_list[count.index]}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location

  ip_configuration {
    name = "nicConfig-${var.environment_tag}-${var.machine_list[count.index]}"
    subnet_id = var.subnet_ids[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip[count.index].id
  }

  tags = {
    environment = var.environment_tag
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  count = length(var.machine_list)
  network_interface_id = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
}