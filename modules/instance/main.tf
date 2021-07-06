terraform {
  required_version = ">= 0.12"
}

output "host_ip" {
	value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
#######################################################
# Create custom GCP instance
#######################################################
resource "google_compute_instance" "vm" {
  name         = "${var.name}"
  machine_type = format("%s%s%s%d","e2-custom-",var.cpu,"-",var.ram * 1024)

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  # Write public key in to the metadata item GCP
  metadata = {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }
}