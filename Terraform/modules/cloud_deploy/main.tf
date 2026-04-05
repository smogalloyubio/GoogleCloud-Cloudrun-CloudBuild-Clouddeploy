resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  name     = "gke-deploy-pipeline"
  location = var.region

  serial_pipeline {
    stages {
      target_id = "prod-gke"

      # The strategy MUST live inside the stage
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
            percentages = [10, 50] 
          }
        }
      }
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