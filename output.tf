# ===============================
# VM CREDENTIALS
# ===============================
output "vm_admin_username" {
  description = "Admin username for all Linux VMs"
  value       = var.admin_username
}

output "vm_admin_password" {
  description = "Random admin password used for all Linux VMs"
  value       = random_password.vm_admin.result
  sensitive   = true
}

# ===============================
# MYSQL CREDENTIALS
# ===============================
output "mysql_admin_username" {
  description = "MySQL admin username"
  value       = var.mysql_admin_username
}

output "mysql_admin_password" {
  description = "MySQL admin password"
  value       = var.mysql_admin_password
  sensitive   = true
}

# ===============================
# MYSQL ENDPOINTS
# ===============================
output "mysql_master_fqdn" {
  description = "MySQL master FQDN"
  value       = azurerm_mysql_flexible_server.master.fqdn
}

output "mysql_replica1_fqdn" {
  description = "MySQL replica 1 FQDN"
  value       = azurerm_mysql_flexible_server.replica1.fqdn
}

output "mysql_replica2_fqdn" {
  description = "MySQL replica 2 FQDN"
  value       = azurerm_mysql_flexible_server.replica2.fqdn
}
