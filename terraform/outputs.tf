output "resource_group_rg_example" {
  value = azurerm_resource_group.rg.id
}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
output "ssh_private_key" {
  value = tls_private_key.roni_ssh.private_key_pem
  sensitive = true
}
output "ssh_public_key" {
  value = tls_private_key.roni_ssh.public_key_pem
  sensitive = true
}
output "public_ip" {
  value = azurerm_public_ip.publicip.ip_address
}
