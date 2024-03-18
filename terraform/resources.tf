#Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

resource "azurerm_storage_account" "ronist" {
    name = "ronist"
    resource_group_name = var.resource_group_name
    location            = var.location_name
    account_tier	= "Standard"
    account_replication_type = "LRS"
    public_network_access_enabled = true

    tags = {
    	environment = var.environment
    }
    depends_on = [
    	azurerm_resource_group.rg
    ]
}

#ACR
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location_name
  sku                 = "Basic"
  admin_enabled       = true
  depends_on = [
    azurerm_resource_group.rg
  ]
}

#VM
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location_name
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = var.location_name
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id	  = azurerm_public_ip.publicip.id
  }
}

resource "tls_private_key" "roni_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = var.location_name
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size               	= var.vm_size
  admin_username	= "roni"
  disable_password_authentication = true
  computer_name  = "Whymca-Roni-MACHINE-name"

  admin_ssh_key {
    username = "roni"
    public_key = tls_private_key.roni_ssh.public_key_openssh
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }
  os_disk {
    caching           		= "ReadWrite"
    storage_account_type	= "Standard_LRS"
  }

  boot_diagnostics {
  	storage_account_uri = azurerm_storage_account.ronist.primary_blob_endpoint
  }
  
  tags = {
    environment = var.environment
  }
}

#Public IP
resource "azurerm_public_ip" "publicip" {
  name                = "RoniPublicIp"
  resource_group_name = var.resource_group_name
  location            = var.location_name
  allocation_method   = "Static"

  tags = {
    environment = var.environment
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

#Security Group for a SSH connection inbound rule
resource "azurerm_network_security_group" "securitygroup" {
  name                = "RoniSecurityGroup"
  location            = var.location_name
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

#AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location_name
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "kubernetes_persistent_volume" "example" {
  metadata {
    name = "terraform-example"
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/mnt/tmp"
      }
    }
  }
}

#resource "azurerm_role_assignment" "acr_public_access" {
#  scope                = azurerm_container_registry.acr.id
#  role_definition_name = "AcrPull"
#  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
#}

