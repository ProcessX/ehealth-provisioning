resource "azurerm_resource_group" "rg-ehealth" {
  name = var.resource_group_name
  location = var.resource_group_location


}

module "module_vnets" {
  count = length(var.environment_list)
  source = "./modules/module_vnets"
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  environment_tag = var.environment_list[count.index]
  subnet_names = var.machine_list
  depends_on = [ azurerm_resource_group.rg-ehealth ]
}


module "module_securityGroups" {
  count = length(var.environment_list)
  source = "./modules/module_securityGroups"
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  machine_list = var.machine_list
  subnet_ids = module.module_vnets[count.index].subnet_ids
  environment_tag = var.environment_list[count.index]
  depends_on = [ azurerm_resource_group.rg-ehealth ]
}
