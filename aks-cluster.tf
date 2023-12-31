resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "West US 2"

  tags = {
    environment = "Eazytraining"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "eaytrainingacrlab"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "Premium"
  admin_enabled       = false
  georeplications = [
    {
      location                = "East US"
      zone_redundancy_enabled = true
      tags                    = {}
    },
    {
      location                = "westeurope"
      zone_redundancy_enabled = true
      tags                    = {}
  }]
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Eazytraining"
  }
}
