
resource "google_service_account" "gke_cluster_service" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
  project      = var.project_id
}


resource "google_service_account" "pipline_line_service" {
  account_id   = "cloud-build-deployer"
  display_name = "Cloud Build and Deploy CI-CD Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "cb_roles" {
  for_each = toset([
    "roles/artifactregistry.writer", 
    "roles/container.developer",    
    "roles/logging.logWriter",       
    "roles/clouddeploy.operator",    
    "roles/storage.admin",           
    "roles/cloudbuild.builds.builder" 
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.pipline_line_service.email}"
}


resource "google_service_account_iam_member" "cb_sa_user" {
  service_account_id = google_service_account.pipline_line_service.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.pipline_line_service.email}"
}


resource "google_project_iam_member" "gke_roles" {
  for_each = toset([
    "roles/artifactregistry.reader", 
    "roles/logging.logWriter",      
    "roles/monitoring.metricWriter", 
    "roles/stackdriver.resourceMetadata.writer" 
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_cluster_service.email}"
}