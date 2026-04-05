module "network" {
  source      = "./modules/network"
  vpc_name    = "prod-vpc"
  project_id  = var.project_id
  subnet_name = "gke-subnet"
  region      = var.region
}

module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
}

module "registry" {
  source    = "./modules/artifact_registry"
  region    = var.region
  repo_name = "app-repo"
}

module "compute" {
  source       = "./modules/compute"
  cluster_name = "production-cluster"
  zone         = var.zone
  network_id   = module.network.vpc_id
  subnet_id    = module.network.subnet_id
  gke_sa_email = module.iam.gke_sa_email
}

module "deploy" {
  source     = "./modules/cloud_deploy"
  region     = var.region
  cluster_id = "projects/${var.project_id}/locations/${var.zone}/clusters/${module.compute.cluster_name}"
}