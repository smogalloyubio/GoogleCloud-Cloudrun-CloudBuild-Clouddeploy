resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  name     = "gke-deploy-pipeline"
  location = var.region
  
  serial_pipeline {
    stages {
      target_id = "prod-gke"
    }
  }
}

resource "google_clouddeploy_target" "gke_target" {
  name     = "prod-gke"
  location = var.region
  
  gke {
    cluster = var.cluster_id
  }
}

