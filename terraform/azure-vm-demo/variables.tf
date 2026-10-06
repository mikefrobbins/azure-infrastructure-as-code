variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "terraform-demo"
}

variable "location" {
  description = "Azure region where the resources are deployed."
  type        = string
  default     = "eastus"
}

variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
  default     = "vm-demo"

  validation {
    condition     = length(var.vm_name) >= 1 && length(var.vm_name) <= 59
    error_message = "The vm_name value must be between 1 and 59 characters."
  }
}

variable "admin_username" {
  description = "Administrator username for the virtual machine."
  type        = string

  validation {
    condition     = length(var.admin_username) >= 1
    error_message = "The admin_username value must not be empty."
  }
}

variable "ssh_public_key" {
  description = "SSH public key used to authenticate to the virtual machine."
  type        = string

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa) ", var.ssh_public_key))
    error_message = "The ssh_public_key value must be an Ed25519 or RSA public key in OpenSSH format."
  }
}

variable "vm_size" {
  description = "Virtual machine size."
  type        = string
  default     = "Standard_B2s_v2"
}

variable "vnet_address_prefix" {
  description = "Virtual network address space."
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Workload subnet address space."
  type        = string
  default     = "10.10.1.0/24"
}

variable "tags" {
  description = "Resource tags applied to supported resources."
  type        = map(string)
  default = {
    environment = "demo"
    workload    = "azure-vm-demo"
    managedBy   = "Terraform"
  }
}
