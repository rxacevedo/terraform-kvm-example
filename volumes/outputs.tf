output "ubuntu_base_volume" {
  value = "${libvirt_volume.ubuntu.id}"
}

output "centos_base_volume" {
  value = "${libvirt_volume.centos.id}"
}
