
output "vpc_name" {
  value = module.network.vpc_id
}

output "subnet_id" {
  value = module.network.subnet_id
}


output "gke_service_account" {
  value = module.iam.gke_sa_email
}

output "pipeline_service_account" {
  value = module.iam.devops_sa_email
}

output "artifact_repository" {
  value = module.registry.repo_id
}


output "gke_cluster_endpoint" {
  value = module.compute.cluster_endpoint
}