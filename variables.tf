variable "public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/gcloud_id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default     = "~/.ssh/gcloud_id_rsa"
}

variable "service_account_key" {
  description = "Path to file containing service account GCP key"
  default     = "/home/User/devops-school-317412-e388b05e76b4.json"
}