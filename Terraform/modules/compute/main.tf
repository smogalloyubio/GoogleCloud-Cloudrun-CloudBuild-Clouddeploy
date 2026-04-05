resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = var.network_id
  subnetwork               = var.subnet_id
}

resource "google_container_node_pool" "nodes" {
  name       = "main-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    service_account = var.gke_sa_email
    machine_type    = "e2-medium"
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}



