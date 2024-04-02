resource "azurerm_virtual_network" "vnet-control" {
  name = "vnet-control"
  address_space = ["10.0.0.0/16"]
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  tags = {
    environment = "control"
  }
}

resource "azurerm_subnet" "subnet-control" {
  name = "subnet-control"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-control.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name = "public_ip_control"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method = "Dynamic"
  tags = {
    environment = "control"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg-control"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name

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
    environment = "control"
  }
}

resource "azurerm_network_interface" "nic"{
  name = "nic-control"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "nic-config-control"
    subnet_id = azurerm_subnet.subnet-control.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = "control"
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 8
}

resource "azurerm_storage_account" "storage" {
  name = "diag${random_id.randomId.hex}"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "control"
  }
}

data "template_file" "cloudconfig" {
  template = "${file("./ansible/scripts/userdata.yaml")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "vm-control-machine"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_DS1_v2"

  os_disk {
    name = "os-control-machine"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  computer_name = "control"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "azureuser"
    public_key = var.ssh_key
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage.primary_blob_endpoint
  }

  tags = {
    environment = "production"
  }
}
