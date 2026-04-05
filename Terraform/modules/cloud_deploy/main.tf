resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  name     = "gke-deploy-pipeline"
  location = var.region
  
 strategy {
  canary {
    runtime_config {
      kubernetes {
        service_networking {
          service    = "my-app-service" 
          deployment = "my-app"         
        }
      }
    }
    canary_deployment {
      percentages = [10, 50, 100]
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

