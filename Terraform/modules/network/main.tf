
resource "google_compute_network" "google_cloud_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false # Disabling auto-subnets is best practice for production control
  project                 = var.project_id
}


resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.google_cloud_vpc.id
  project       = var.project_id
}