locals {
  vnet_name          = "vnet-${var.vm_name}"
  subnet_name        = "snet-workload"
  nsg_name           = "nsg-${var.vm_name}"
  nic_name           = "nic-${var.vm_name}"
  nat_gateway_name   = "nat-${var.vm_name}"
  nat_public_ip_name = "pip-${var.vm_name}-nat"
}

resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_security_group" "workload" {
  name                = local.nsg_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  tags                = var.tags
}

resource "azurerm_public_ip" "nat" {
  name                = local.nat_public_ip_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  # tflint-ignore: azurerm_public_ip_invalid_sku
  sku               = "StandardV2"
  allocation_method = "Static"
  tags              = var.tags
}

resource "azurerm_nat_gateway" "workload" {
  name                    = local.nat_gateway_name
  location                = azurerm_resource_group.demo.location
  resource_group_name     = azurerm_resource_group.demo.name
  sku_name                = "StandardV2"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "workload" {
  nat_gateway_id       = azurerm_nat_gateway.workload.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_virtual_network" "demo" {
  name                = local.vnet_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  address_space       = [var.vnet_address_prefix]
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  name                            = local.subnet_name
  resource_group_name             = azurerm_resource_group.demo.name
  virtual_network_name            = azurerm_virtual_network.demo.name
  address_prefixes                = [var.subnet_address_prefix]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

resource "azurerm_subnet_nat_gateway_association" "workload" {
  subnet_id      = azurerm_subnet.workload.id
  nat_gateway_id = azurerm_nat_gateway.workload.id
}

resource "azurerm_network_interface" "vm" {
  name                = local.nic_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.workload,
    azurerm_subnet_nat_gateway_association.workload,
    azurerm_nat_gateway_public_ip_association.workload,
  ]
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  size                = var.vm_size
  computer_name       = var.vm_name
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  disable_password_authentication = true
  provision_vm_agent              = true
  patch_assessment_mode           = "AutomaticByPlatform"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  boot_diagnostics {}
}

resource "azurerm_virtual_machine_extension" "guest_attestation" {
  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Security.LinuxAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags

  settings = jsonencode({
    AttestationConfig = {
      MaaSettings = {
        maaEndpoint   = ""
        maaTenantName = "GuestAttestation"
      }
    }
  })
}
