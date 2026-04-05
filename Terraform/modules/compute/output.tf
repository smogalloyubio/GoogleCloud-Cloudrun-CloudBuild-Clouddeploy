output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster"
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "The IP address of the GKE cluster master"
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  description = "The public certificate of the GKE cluster"
}