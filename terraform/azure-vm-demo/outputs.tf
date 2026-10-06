output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.demo.name
}

output "vm_resource_id" {
  description = "Resource ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_principal_id" {
  description = "Principal ID of the virtual machine's system-assigned managed identity."
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "private_ip_address" {
  description = "Private IP address of the virtual machine's network interface."
  value       = azurerm_network_interface.vm.private_ip_address
}

output "network_interface_resource_id" {
  description = "Resource ID of the virtual machine's network interface."
  value       = azurerm_network_interface.vm.id
}

output "virtual_network_resource_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.demo.id
}

output "subnet_resource_id" {
  description = "Resource ID of the workload subnet."
  value       = azurerm_subnet.workload.id
}

output "network_security_group_resource_id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.workload.id
}

output "nat_gateway_resource_id" {
  description = "Resource ID of the NAT gateway."
  value       = azurerm_nat_gateway.workload.id
}

output "nat_gateway_public_ip_address" {
  description = "Public IP address used by the NAT gateway for outbound traffic."
  value       = azurerm_public_ip.nat.ip_address
}
