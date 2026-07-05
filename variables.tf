variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = "fastapi-rg"
}

variable "vm_name" {
  type    = string
  default = "fastapi-vm"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "github_username" {
  type = string
}

variable "github_pat" {
  type      = string
  sensitive = true
}

variable "docker_image" {
  type = string
}

variable "app_env" {
  description = "Contents of the application's .env file"
  type        = string
  sensitive   = true
}
