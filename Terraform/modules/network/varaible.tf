variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "vpc_name" {
  type    = string
  
}

variable "subnet_name" {
  type    = string
  default = "subnet"
}

variable "region" {
  type    = string
}