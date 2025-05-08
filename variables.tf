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

variable "s3_bucket_name" {
  description = "S3 bucket for music"
  type = string
  default = "ampache_bucket_956789"
}
