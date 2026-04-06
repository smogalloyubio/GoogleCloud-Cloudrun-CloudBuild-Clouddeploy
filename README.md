# Terraform GCP CI/CD Pipeline for GKE

**Automated Infrastructure-as-Code (IaC) setup for a complete CI/CD pipeline on Google Cloud Platform**

---

## Introduction

This project provides a fully automated, production-ready CI/CD pipeline on Google Cloud Platform (GCP) using Terraform. It provisions all the necessary infrastructure — from networking and security to GKE cluster, Cloud Build triggers, Artifact Registry, and Cloud Deploy — so that every time you push code to your Git repository, a Docker image is automatically built, pushed to **both** Google Artifact Registry **and** Docker Hub, and deployed to a Kubernetes cluster.

The entire setup is modular, secure (least-privilege IAM, Secret Manager for credentials), and follows GCP best practices. No manual steps are required after the initial `terraform apply`.

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

Every `git push` now triggers a complete build → test → push (to two registries) → deploy workflow with zero manual intervention.

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

---

## Architecture Diagram
![Architectural diagram]()

