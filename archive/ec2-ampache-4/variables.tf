variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
  default     = "ampache"
}

variable "private_key_path" {
  description = "SSH key path"
  type        = string
  default     = "~/.ssh/ampache.pem"
}

