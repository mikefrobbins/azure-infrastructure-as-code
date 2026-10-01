# Azure VM with Bicep

This configuration deploys an Azure virtual machine (VM) using Bicep and Azure PowerShell. For a
complete walkthrough, including validation, deployment, verification, and clean up, see the
accompanying article:

**[Deploy an Azure VM with Bicep and Azure PowerShell][01]**

## Files

- `azure-vm-demo.bicep`: The Bicep template
- `azure-vm-demo.bicepparam`: The Bicep parameter file

## What it deploys

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

[01]: https://mikefrobbins.com/2026/10/01/deploy-an-azure-vm-with-bicep-and-azure-powershell/
