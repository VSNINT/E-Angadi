# -----------------------------
# GLOBAL
# -----------------------------
variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "tags" {
  type = map(string)
}

# -----------------------------
# VM
# -----------------------------
variable "vm_names" {
  type = list(string)
}

variable "vm_size" {
  type    = string
  default = "Standard_D8als_v6"
}

variable "admin_username" {
  type = string
}

# -----------------------------
# MYSQL
# -----------------------------
variable "mysql_master_name" {
  type = string
}

variable "mysql_admin_username" {
  type = string
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_version" {
  type    = string
  default = "8.0.21"
}

variable "mysql_storage_gb" {
  type    = number
  default = 200
}

variable "master_sku" {
  type    = string
  default = "GP_Standard_D4ds_v4"
}

variable "replica_sku" {
  type    = string
  default = "GP_Standard_D2ds_v4"
}
