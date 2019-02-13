# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu-bionic-cloudimg.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "centos" {
  name   = "centos-7.6-cloudimg.qcow2"
  pool   = "default"
  source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1503.qcow2"
  format = "qcow2"
}
