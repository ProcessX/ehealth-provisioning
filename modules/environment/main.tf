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
  count = length(var.machine_list)
  name = "subnet-${var.environment_tag}-${var.machine_list[count.index]}"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.${count.index + 1}.0/24"]
}

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
    subnet_id = azurerm_subnet.subnet[count.index].id
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

resource "random_id" "randomId" {
  count = length(var.machine_list)
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 8
}

resource "azurerm_storage_account" "storage" {
  count = length(var.machine_list)
  name = "diag${random_id.randomId[count.index].hex}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment_tag
  }
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  count = length(var.machine_list)
  name = "vm-${var.environment_tag}-${var.machine_list[count.index]}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  size = "Standard_DS1_v2"

  os_disk {
    name = "osdisk-${var.environment_tag}-${var.machine_list[count.index]}"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  computer_name = "vm-${var.environment_tag}-${var.machine_list[count.index]}"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "azureuser"
    public_key = var.ssh_key
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage[count.index].primary_blob_endpoint
  }

  tags = {
    environment = var.environment_tag
  }
}