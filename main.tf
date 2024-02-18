provider "azurerm" {
  features {}

  client_id       = "5142fe84-410f-4abc-ae7c-0122e0967edc"
  client_secret   = "5408Q~n2ovxKsacsQWsSAGRELT3TeBZtBUtUEa_c"
  tenant_id       = "e74a417b-ab67-48bd-921b-0fd6c5d2b1c2"
  subscription_id = "b98f53aa-1ec7-4951-b1fd-6ad6381b1ff0"
}

resource "azurerm_resource_group" "rg" {
  name     = var.azurerm_resource_group
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.address_prefixes1
  depends_on = [azurerm_virtual_network.vnet]

}

resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.address_prefixes2
  depends_on = [azurerm_virtual_network.vnet]

}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_virtual_network.vnet]

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pip" {
  
  name                    = "public-ip"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

resource "azurerm_network_interface" "nic" {
  name                = var.Dev-nic
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.Dev-vm
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"
  depends_on = [azurerm_network_interface.nic]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "gafar"
    admin_password = "Password123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

