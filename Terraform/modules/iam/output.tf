
output "gke_sa_email" {
  value = google_service_account.gke_cluster_service.email
}

output "devops_sa_email" {
  value = google_service_account.pipline_line_service.email
}