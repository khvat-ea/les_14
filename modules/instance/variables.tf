variable "public_key_path" {
  description = "Path to file containing public key"
  type = string
}

variable "private_key_path" {
  description = "Path to file containing private key"
  type = string
}

variable "name" {
  description = "Set name of instace"
  type = string
}

variable "cpu" {
  description = "Enter the number of CPUs in multiples of 2 (only digit)"
  type = number
}

variable "ram" {
  description = "Enter RAM in Gb (only digit)"
  type = number
}

variable "image" {
  description = "Enter the name of image"
  type = string
}