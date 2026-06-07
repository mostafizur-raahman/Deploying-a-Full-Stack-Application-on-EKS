# Full-Stack Application Deployment on Amazon EKS

This repository contains the configuration files and step-by-step instructions for deploying a production-ready, full-stack application (React Frontend, Node.js Backend, and PostgreSQL Database) on Amazon Elastic Kubernetes Service (EKS).

## 🏗️ Architecture Overview

- **Frontend**: React application served via Nginx.
- **Backend**: Node.js REST API.
- **Database**: PostgreSQL (deployed via Helm for development; Amazon RDS recommended for production).
- **Infrastructure**: Amazon EKS (Managed Kubernetes), Amazon ECR (Container Registry), and AWS Application Load Balancer (ALB) for ingress routing.

---

## 📋 Prerequisites

Ensure the following tools are installed and configured on your local machine:

1. **AWS CLI**: Configured with `aws configure` (requires permissions for EKS, EC2, ECR, IAM, and VPC).
2. **eksctl**: The official CLI for creating and managing EKS clusters.
3. **kubectl**: The Kubernetes command-line tool.
4. **Docker**: To build and test container images locally.
5. **Helm**: The package manager for Kubernetes (v3.x).

---

## 📁 Project Structure

```text
.
├── backend/
│   ├── Dockerfile          # Node.js backend container definition
│   ├── server.js           # Example backend entry point
│   └── package.json
├── frontend/
│   ├── Dockerfile          # React + Nginx multi-stage build
│   ├── nginx.conf          # Nginx configuration for routing
│   └── src/                # React application source code
├── k8s/
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   └── ingress.yaml
├── cluster.yaml            # eksctl cluster configuration
└── README.md               # This file
```
