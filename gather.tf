data "openstack_blockstorage_volume_v3" "application" {
  name = "application"
}

data "openstack_blockstorage_volume_v3" "db-backup" {
  name = "db-backup"
}