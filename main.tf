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
  metadata = {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  # Copies the Dockerfile as the root user using SSH
  provisioner "file" {
    source      = "./Dockerfile"
    destination = "/tmp/Dockerfile"

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }

  # Copies the credentials to GCP as the root user using SSH
  provisioner "file" {
    source      = "/home/User/devops-school-317412-e388b05e76b4.json"
    destination = "/opt/cred.json"

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`",
      "sudo gcloud auth activate-service-account --key-file /opt/cred.json",
      "sudo gcloud auth configure-docker -q",
      "sudo docker login gcr.io/devops-school-317412",
      "cd /tmp",
      "sudo docker build -t box_app:1.0 .",
      "sudo docker tag box_app:1.0 gcr.io/devops-school-317412/box_app:1.0",
      "sudo docker push gcr.io/devops-school-317412/box_app:1.0"
    ]
  }
}