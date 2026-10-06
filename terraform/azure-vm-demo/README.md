# Azure VM with Terraform

This configuration deploys an Azure virtual machine (VM) using Terraform and Azure CLI. For a
complete walkthrough, including validation, deployment, verification, and clean up, see the
accompanying article:

**[Deploy an Azure VM with Terraform and Azure CLI][01]**

## Files

- `terraform.tf`: Terraform and provider version requirements
- `variables.tf`: Input variable declarations
- `azure-vm-demo.tf`: Resource definitions
- `outputs.tf`: Output values
- `azure-vm-demo.auto.tfvars`: Values for this deployment
- `.terraform.lock.hcl`: Dependency lock file that records the selected provider version
- `.tflint.hcl`: TFLint configuration with the Azure ruleset
- `.gitignore`: Excludes local state, plan files, and the provider cache

## What it deploys

- A resource group
- A virtual network with a private workload subnet
- A network security group
- A NAT gateway and its static public IP address for outbound connectivity
- A network interface
- A Linux VM with Trusted Launch, SSH public-key authentication, and no public IP address
- A system-assigned managed identity
- The Guest Attestation extension

> **Important:** The VM, its OS disk, the NAT gateway, and the NAT gateway's public IP address incur
> charges while they exist. Delete the resources when you're finished to avoid ongoing charges. For
> instructions, see the [article][01].

[01]: https://mikefrobbins.com/2026/10/06/deploy-an-azure-vm-with-terraform-and-azure-cli/
