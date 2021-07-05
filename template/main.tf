terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.74.0"
    }
  }
}

provider "google" {
  project = "devops-school-317412"
  region  = "us-central1"
  zone    = "us-central1-c"
}


#######################################################
# Create builder instance
#######################################################
resource "google_compute_instance" "template_VM" {
  name         = "${var.instance_name}"
  machine_type = format("%s%s%s%s","e2-custom-",var.cpu,"-",var.ram)

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
