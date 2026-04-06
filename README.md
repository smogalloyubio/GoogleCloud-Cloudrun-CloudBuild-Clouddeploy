# Terraform GCP CI/CD Pipeline for GKE

**Automated Infrastructure-as-Code (IaC) setup for a complete CI/CD pipeline on Google Cloud Platform**

---

## Introduction

This project provides a fully automated, production-ready CI/CD pipeline on Google Cloud Platform (GCP) using Terraform. It provisions all the necessary infrastructure from networking and security to GKE cluster, Cloud Build triggers, Artifact Registry, and Cloud Deploy so that every time you push code to your Git repository, a Docker image is automatically built, pushed to **both** Google Artifact Registry **and** Docker Hub, and deployed to a Kubernetes cluster.

The entire setup is modular, secure (least-privilege IAM, Secret Manager for credentials), and follows GCP best practices. No manual steps are required after the initial `terraform apply`.

---

## Architecture Diagram
![Architectural diagram]()

---
## Problem Statement

Modern applications require fast, reliable, and repeatable deployments. However, setting up a complete CI/CD pipeline on GCP involves many complex components:

- Creating a secure VPC network and firewall rules for GKE  
- Provisioning a GKE cluster  
- Setting up Cloud Build triggers connected to a Git repository  
- Managing Docker image repositories (Artifact Registry + Docker Hub)  
- Handling secure credential storage for external registries  
- Configuring Cloud Deploy pipelines for zero-downtime deployments  

Doing all of this manually is time-consuming, error-prone, and difficult to reproduce across environments or teams. Without proper IaC, infrastructure drifts, security gaps appear, and deployments become inconsistent.

---

## Solution

This Terraform project solves the problem by **declaring the entire infrastructure as code**.  

One `terraform apply` creates:
- A dedicated VPC, subnets, and firewall rules  
- A fully functional GKE cluster  
- Artifact Registry repository  
- Cloud Build triggers linked to your Git repo  
- IAM service accounts with minimal permissions  
- Secret Manager secrets for Docker Hub credentials  
- Cloud Deploy pipeline that automatically deploys new images to GKE  

---
![terraform  modules](https://github.com/smogalloyubio/GoogleCloud-Cloudrun-CloudBuild-Clouddeploy/blob/main/picture/Screenshot%202026-04-05%20at%2013.14.32.png)
---
## Tools & Technologies Used

| Tool / Service              | Purpose |
|-----------------------------|-------|
| **Terraform**               | Infrastructure as Code (IaC) – provisions everything |
| **Google Cloud Platform**   | Cloud provider |
| **GKE (Google Kubernetes Engine)** | Container orchestration |
| **Cloud Build**             | CI pipeline – builds Docker images on every push |
| **Artifact Registry**       | Private Docker image storage (GCP native) |
| **Docker Hub**              | Public/private image registry (external) |
| **Cloud Deploy**            | Continuous deployment to GKE |
| **Secret Manager**          | Securely stores Docker Hub credentials |
| **IAM**                     | Least-privilege service accounts |
| **VPC + Firewall**          | Secure networking for GKE |

All modules are in the `modules/` folder and are called from the root `main.tf`.
## Step 1 Terraform Execution Environment (Custom Docker Image)
created a custom Docker image (based on a Debian base image) that includes Terraform CLI  and Google Cloud SDK (gcloud CLI) in a Docker file called  Dockerfile.Install  this pull the  Debian image. It installs all required dependencies
Copies the entire Terraform workspace  into the container using the COPY or ADD instruction
Sets up the working directory so the container is ready to run terraform init, terraform plan, and terraform apply immediately. This image is then built and pushed to Docker Hub (and also to Artifact Registry) as part of the pipeline.
### Why I Chose This Approach
- Consistency across machines — Anyone (or any CI runner) can pull the exact same image and run Terraform without installing Terraform, gcloud, or any dependencies locally.
- Reproducibility — The exact versions of Terraform and gcloud are locked inside the image. This prevents version conflicts when working on similar projects in the future.
- Portability & Zero Local Setup — You don't need to install anything on your laptop, Mac, or new developer machines. Just run
```

FROM debian:bookworm-slim

ENV TERRAFORM_VERSION=1.7.0


RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    software-properties-common \
    unzip \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip


RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y && apt-get install google-cloud-cli -y


WORKDIR /infrastructure

COPY . .

CMD ["/bin/bash", "-c", "terraform --version && gcloud --version && exec /bin/bash"]

docker run --rm -v $(pwd):/workspace -w /workspace image-name

terraform init

terraform validate

terraform apply -auto-approve

```
---
![terraform apply command ](https://github.com/smogalloyubio/GoogleCloud-Cloudrun-CloudBuild-Clouddeploy/blob/main/picture/Screenshot%202026-04-05%20at%2016.11.56.png)

---



##  Step 3 GCP Authentication for Terraform

To allow Terraform to provision resources in Google Cloud, the `gcloud` CLI must be authenticated inside the Docker container (or on the host).

### Steps Performed:
I used two essential commands:

1. **`gcloud auth login`**  
   - Authenticates the `gcloud` CLI with your personal Google account (interactive browser login).

2. **`gcloud auth application-default login`**  
   - Configures **Application Default Credentials (ADC)** that Terraform uses to authenticate with GCP APIs.

### Why Both Commands Are Needed
- `gcloud auth login` → Used by the `gcloud` CLI itself.
- `gcloud auth application-default login` → Provides credentials specifically for Terraform and other client libraries.

After running these commands once inside the Docker container, Terraform can successfully connect to your GCP project and provision the 
infrastructure (GKE, Cloud Build, Artifact Registry, etc.).

**Note:** These credentials are stored inside the container or your local credential store and are not committed to Git.

![terraform authentication](https://github.com/smogalloyubio/GoogleCloud-Cloudrun-CloudBuild-Clouddeploy/blob/main/picture/Screenshot%202026-04-05%20at%2012.55.59.png)


##  Step 4 Cloud Build Trigger Configuration
Cloud Build is the core CI service in this project. It automatically triggers a build whenever code is pushed to the Git repository. Terraform provisions the Cloud Build trigger so the entire pipeline (build → push to registries → deploy) runs automatically.

### How It Was Done
Terraform (in the `modules/cloud-build/` module) creates:
- A dedicated Cloud Build service account with the necessary permissions
- A Cloud Build trigger that is connected to your Git repository

After running `terraform apply`, the trigger is pre-configured in GCP. You only need to complete the repository connection in the Google Cloud Console (one-time manual step).

### Connection Steps (Summary)
1. Run `terraform apply` – Terraform creates the trigger resource.
2. Go to **Google Cloud Console → Cloud Build → Triggers**.
3. Click on the trigger created by Terraform.
4. Connect your Git repository (GitHub) using the GCP connector.
5. Select the branch (usually `main` or `master`) and the path to your `cloudbuild.yaml` file.

Once connected, every `git push` to the selected branch automatically starts the Cloud Build pipeline.
---
![cloud build](https://github.com/smogalloyubio/GoogleCloud-Cloudrun-CloudBuild-Clouddeploy/blob/main/picture/Screenshot%202026-04-05%20at%2018.00.53.png)

### Detailed Flow

- You push code to your Git repo → Cloud Build trigger fires
- Cloud Build uses the custom Docker image (or default steps) to:
  - Build the application Docker image
  - Push it to Google Artifact Registry
  - Retrieve Docker Hub credentials from Secret Manager
  - Push the same image to Docker Hub
- On successful build, Cloud Deploy automatically rolls out the new image to the GKE cluster

### Key Benefits
- Fully automated CI pipeline
- Trigger is managed as code via Terraform (reproducible and version-controlled)
- Secure permissions using dedicated service account
- No manual build steps required after initial setup

![cloudbuild trigger](https://github.com/smogalloyubio/GoogleCloud-Cloudrun-CloudBuild-Clouddeploy/blob/main/picture/Screenshot%202026-04-05%20at%2017.21.47.png)

##  Step 5 Cloud Deploy Configuration
Cloud Deploy is used for continuous deployment of the Docker image to the GKE cluster. It provides safe, automated, and repeatable deployments with built-in rollout strategies and rollback capabilities.
Terraform (in the `modules/cloud-deploy/` module) provisions the Cloud Deploy pipeline and target.

### How the Deployment Works (Simple Summary)

1. **Managed Configuration in Git Repository**  
   The Kubernetes manifests (deployment, service, etc.) are stored in the Git repository under a dedicated directory
   
   ```
   k8s/
    ├── deployment.yaml
    ├── service.yaml

2. **Cloud Build Knows the Location**  
In your `cloudbuild.yaml` file (located in the root of the repository), we specify the path to the Kubernetes folder so Cloud Build can find and pass the manifests to Cloud Deploy.

3. **Deployment Flow**
- After successfully building and pushing the Docker image to **Artifact Registry**, Cloud Build triggers Cloud Deploy.
- Cloud Deploy pulls the latest image from Artifact Registry.
- It applies the Kubernetes manifests from the `k8s/` directory (managed via `skaffold.yaml`).
- The image is deployed to the GKE cluster with zero-downtime rollout.

### Key Files
- **`skaffold.yaml`** – Defines how to render and deploy the Kubernetes manifests.
- **`deployment.yaml`** – Contains the Kubernetes Deployment that references the image from Artifact Registry.
- **`service.yaml`** (optional) – Exposes the application.

### Why This Approach
- All deployment configuration lives **as code** in Git (version-controlled and auditable).
- Cloud Deploy handles progressive delivery, approvals, and rollbacks automatically.
- The image is always pulled from the secure private Artifact Registry created by Terraform.

**Result**: Every `git push` automatically builds the image and deploys it safely to GKE using Cloud Deploy.
   

##  Step 5 GKE Cluster & Final Deployment

### Overview
The last phase of the project is the deployment of the application to the **Google Kubernetes Engine (GKE)** cluster. Terraform fully provisions the GKE cluster along with all supporting resources (VPC, subnets, and firewall rules).

### What Was Provisioned by Terraform
- A secure VPC network and subnets
- Firewall rules to allow necessary traffic (including port 80 and 443 for the application)
- The GKE cluster itself (standard or Autopilot mode)

### How Deployment Happens to the Cluster
1. Cloud Deploy receives the successful build from Cloud Build.
2. It pulls the Docker image from **Artifact Registry**.
3. Using the Kubernetes manifests (`deployment.yaml` and `skaffold.yaml`) stored in the Git repository, Cloud Deploy applies the configuration to the GKE cluster.
4. The application pod starts running in the cluster.
5. The Service resource (defined in the manifests) exposes the application on **port 80** (HTTP) or **443** (HTTPS) as configured.
6. You can access the application using the external IP or Load Balancer provided by GKE.

This completes the end-to-end pipeline:  
**git push → Build → Push to registries → Deploy to GKE**

### Final Result
Every code change is automatically built, tested, and deployed to a live GKE cluster with minimal manual intervention.

---
![Google Gke cloud]()
