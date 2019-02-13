# Use CloudInit to add our ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default"

  user_data = <<EOF
#cloud-config
growpart:
  mode: auto
  devices: ['/']
ssh_pwauth: True
ssh_authorized_keys:
  - "${file("~/.ssh/id_rsa.pub")}"
chpasswd:
  list: |
     root:linux
  expire: False
package_update: True
package_upgrade: True
EOF
}

resource "libvirt_volume" "disk_ubuntu_resized" {
  count          = "${var.vm_count}"
  name           = "ubuntu-k8s-${count.index}.qcow2"
  base_volume_id = "${data.terraform_remote_state.volumes.ubuntu_base_volume}"
  size           = 8361393152
}

resource "libvirt_volume" "disk_centos_resized" {
  count          = "${var.vm_count}"
  name           = "centos-k8s-${count.index}.qcow2"
  base_volume_id = "${data.terraform_remote_state.volumes.centos_base_volume}"
  size           = 10361393152
}

# Create the machine
resource "libvirt_domain" "node" {
  count  = "${var.vm_count}"
  name   = "terraform-k8s-${count.index}"
  memory = "4096"
  vcpu   = 4

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    network_name = "default"
    hostname     = "node-${count.index}"

    ## Let it be dynamic
    ## addresses = ["192.168.122.10${count.index}"]
    mac = "AA:BB:CC:11:22:0${count.index}"

    wait_for_lease = true
  }

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = "${element(libvirt_volume.disk_centos_resized.*.id, count.index)}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }
}

# Print the Boxes IP
# Note: you can use `virsh domifaddr <vm_name> <interface>` to get the ip later
output "ips" {
  value = "${libvirt_domain.node.*.network_interface.0.addresses.0}"
}
