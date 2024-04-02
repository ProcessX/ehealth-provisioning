resource "azurerm_resource_group" "rg-ehealth" {
  name = var.resource_group_name
  location = var.resource_group_location


}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

module "environment" {
  count = length(var.environment_list)
  source = "./modules/environment"
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  environment_tag = var.environment_list[count.index]
  machine_list = var.machine_list
  ssh_key = tls_private_key.ssh_key.public_key_openssh
  depends_on = [ azurerm_resource_group.rg-ehealth, tls_private_key.ssh_key ]
}