# =====================================================
# RANDOM PASSWORD (ONE FOR ALL VMS)
# =====================================================
resource "random_password" "vm_admin" {
  length           = 12
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!@#$%&*()-_=+"
}

# =====================================================
# RESOURCE GROUP
# =====================================================
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      tags,
    ]
  }
}


# =====================================================
# NETWORK (EXISTING)
# =====================================================
resource "azurerm_virtual_network" "vnet" {
  name                = "prod-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/28"]

  lifecycle {
    prevent_destroy = true
  }
}

# =====================================================
# NETWORK INTERFACES (PRIVATE IP ONLY)
# =====================================================
resource "azurerm_network_interface" "nic" {
  count               = length(var.vm_names)
  name                = "${var.vm_names[count.index]}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# =====================================================
# LINUX VMS (UBUNTU 24.04 LTS)
# =====================================================
resource "azurerm_linux_virtual_machine" "vm" {
  count               = length(var.vm_names)
  name                = var.vm_names[count.index]
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size

  admin_username = var.admin_username
  admin_password = random_password.vm_admin.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(
    var.tags,
    {
      role = var.vm_names[count.index]
    }
  )
}

# =====================================================
# MYSQL MASTER (4 CORE)
# =====================================================
resource "azurerm_mysql_flexible_server" "master" {
  name                = var.mysql_master_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password

  sku_name = var.master_sku
  version  = var.mysql_version
  zone     = "2"

  storage {
    size_gb           = var.mysql_storage_gb
    auto_grow_enabled = true
  }

  tags = merge(var.tags, { role = "mysql-master" })
}

# =====================================================
# MYSQL SLAVE 1 (2 CORE)
# =====================================================
resource "azurerm_mysql_flexible_server" "replica1" {
  name                = "mysql-replica-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  create_mode      = "Replica"
  source_server_id = azurerm_mysql_flexible_server.master.id

  sku_name = var.replica_sku
  version  = var.mysql_version
  zone     = "2"

  storage {
    size_gb           = var.mysql_storage_gb
    auto_grow_enabled = true
  }

  tags = merge(var.tags, { role = "mysql-replica" })
}

# =====================================================
# MYSQL SLAVE 2 (2 CORE)
# =====================================================
resource "azurerm_mysql_flexible_server" "replica2" {
  name                = "mysql-replica-2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  create_mode      = "Replica"
  source_server_id = azurerm_mysql_flexible_server.master.id

  sku_name = var.replica_sku
  version  = var.mysql_version
  zone     = "3"

  storage {
    size_gb           = var.mysql_storage_gb
    auto_grow_enabled = true
  }

  tags = merge(var.tags, { role = "mysql-replica" })
}
