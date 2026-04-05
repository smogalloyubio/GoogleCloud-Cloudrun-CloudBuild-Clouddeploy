variable "project_id" {
  type        = string
  description = "The Google Cloud Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The GCP region for resources"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "The GCP zone for the GKE cluster"
}

variable "env_name" {
  type    = string
  default = "dev"
}