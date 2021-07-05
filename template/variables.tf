variable "public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/gcloud_id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default     = "~/.ssh/gcloud_id_rsa"
}

variable "instance_name" {
  description = "Set name of instace"
}

variable "cpu" {
  description = "Set quntity of CPU"
}

variable "ram" {
  description = "Set RAM in Mb (1024, 2048, 3072, 4096 ...)"
}

variable "image" {
  description = "Set name of image"
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
 
}
