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
module "srv_build" {
  source = "./modules/instance"
  public_key_path = "~/.ssh/gcloud_id_rsa.pub"
  private_key_path = "~/.ssh/gcloud_id_rsa"
  name = "builder"
  cpu = 2
  ram = 2
  image = "ubuntu-os-cloud/ubuntu-2004-lts"
}
resource "null_resource" "srv_build" {
     # Copies the Dockerfile as the root user using SSH
  provisioner "file" {
    source      = "./Dockerfile"
    destination = "/tmp/Dockerfile"

    connection {
      host        = module.srv_build.host_ip
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

#######################################################
# Create production instance
#######################################################
module "srv_prod" {
  # Set start order. After build
  depends_on = [module.srv_build]

  source = "./modules/instance"
  public_key_path = "~/.ssh/gcloud_id_rsa.pub"
  private_key_path = "~/.ssh/gcloud_id_rsa"
  name = "production"
  cpu = 2
  ram = 2
  image = "ubuntu-os-cloud/ubuntu-2004-lts"
}

resource "null_resource" "srv_prod" {
  # Copies the credentials to GCP as the root user using SSH
  provisioner "file" {
    source      = "/home/User/devops-school-317412-e388b05e76b4.json"
    destination = "/opt/cred.json"

    connection {
      host        = module.srv_prod.host_ip
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
      "sudo apt update",
      "sudo apt install docker.io -y",
      "sudo usermod -aG docker `echo $USER`",
      "sudo gcloud auth activate-service-account --key-file /opt/cred.json",
      "sudo gcloud auth configure-docker -q",
      "sudo docker login gcr.io/devops-school-317412",
      "sudo docker pull gcr.io/devops-school-317412/box_app:1.0",
      "sudo docker run -d -p 8090:8080 --name web_app gcr.io/devops-school-317412/box_app:1.0"
    ]
  }
}