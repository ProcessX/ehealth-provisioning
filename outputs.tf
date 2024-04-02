output "subnet_ids" {
  value = module.module_vnets.*.subnet_ids
}