terraform {
  required_version = "1.5.7"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.74"
    }
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random Block
resource "random_string" "myrandom" {
  length = 16
  special = false
  upper = false
}
# RESOURCE GROUP    
resource "azurerm_resource_group" "myrg" {
  name = "kiranterraform-rg-${random_string.myrandom.id}"
  location = "eastus"
}

#VNET-1
resource "azurerm_virtual_network" "myvnet" {
  name = "Vnet123"
  resource_group_name = azurerm_resource_group.myrg.name
  location = azurerm_resource_group.myrg.location
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sn1" {
  name = "work-sn"
  resource_group_name = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}

# VNET-2
resource "azurerm_virtual_network" "myvnet1" {
  name = "Vnet12345"
  resource_group_name = azurerm_resource_group.myrg.name
  location = azurerm_resource_group.myrg.location
  address_space = ["10.0.0.0/16"]
  subnet {
    name = "work-sn"
    address_prefix = "10.0.2.0/24"
              }
      }

# VNET-3
resource "azurerm_virtual_network" "Vnet23" {
  name = "vnet3232"
  resource_group_name = azurerm_resource_group.myrg.name
  location = azurerm_resource_group.myrg.location
  address_space = [ "10.0.0.0/8" ]
  subnet {
    name = "sn-3"
    address_prefix = "10.0.3.0/24"
    }
}

# NSG
resource "azurerm_network_security_group" "mynsg" {
  name = "nsg1"
  location = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Subnet & NSG Association
resource "azurerm_subnet_network_security_group_association" "nsg1-work" {
  network_security_group_id = azurerm_network_security_group.mynsg.id
  subnet_id = azurerm_subnet.sn1.id
}
