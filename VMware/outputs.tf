output "VM_Names" {
  value = [for vm in module.vm : vm.vm_name]
}
