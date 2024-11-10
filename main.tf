# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "a41d88b0-7dfa-4ecf-8a4d-633a2fdc2562"

  tenant_id       = "5d0aa6ea-6620-4863-9e21-9ecb140222bc"
}
 # terraform force-unlock 4ee86a92-b18c-c092-ee4f-0a59781b2a2a
# terraform force-unlock <LOCK_ID>
#rm -f .terraform/terraform.tfstate.lock.info
# Define Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}

# Define Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Define Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define Public IP
resource "azurerm_public_ip" "my_public_ip_172_166_197_132" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
}
# terraform apply -lock=false     
# Define Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myIPConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_public_ip_172_166_197_132.id
  }
}

# Define Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "NetworkWatcherRG"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"

  admin_username = "azureuser"
  admin_password = "YourPassword1234!"  # Use SSH key instead in production
     admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key
  }
  
   disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "public_ip_address" {
  value = azurerm_public_ip.my_public_ip_172_166_197_132.ip_address
}