resource "google_cloudbuild_trigger" "git_trigger" {
  name            = "git-trigger"
  service_account = var.devops_sa_id

  github {
    owner = var.git_owner
    name  = var.git_repo
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}

