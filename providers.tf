provider "azurerm" {
  features {}

  #   skip_provider_registration = true
  use_cli = false

  environment   = "stack"
  metadata_host = "localhost:4577"

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}
