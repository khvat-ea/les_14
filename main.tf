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
# Create instances
#######################################################
resource "google_compute_instance" "vm_builder" {
  name         = "builder"
  machine_type = "e2-custom-2-2048"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  # Write public key in to the metadata item GCP
  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`", 
      "sudo docker run -d -p 80:80 nginx"
    ]
  }
}