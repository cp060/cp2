#Resource
variable "resource_group_name" {
  default = "Roni-rg"
}
variable "location_name" {
  #default = "West Europe"
  default = "UK South"
}
#ACR, variable name please due to problem with docker url dont capitalize
variable "acr_name" {
  default = "roniacr"
}
#VM
variable "prefix" {
  default = "Roni"
}
variable "vm_size" {
  default = "Standard_B2s"
}
#ip configuration name
variable "ip_name" {
  default = "Roni-conf"
}
#AKS
variable "aks_name" {
  default = "Roni-aks"
}
variable "dns_prefix" {
  default = "Roniaks"
}
#Environment
variable "environment" {
  default = "staging"
}
#SSH key name
variable "key_name" {
  default = "roni-key"
}
