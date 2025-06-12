# 🚀 Flask App Deployment to GKE via GitHub Actions

This project showcases an end-to-end CI/CD pipeline that deploys a Flask application to a **Google Kubernetes Engine (GKE)** private cluster. It follows modern DevOps practices using:

- **Docker** for containerization  
- **GCR (Google Container Registry)** for storing container images  
- **Terraform** for GCP infrastructure provisioning  
- **GitHub Actions** for automation and continuous delivery  
- **Kubernetes** for orchestration and deployment  

---

## 🧱 What’s Inside

- **Terraform-based infrastructure setup** (`terraform/`)
- **Flask application source code** (`app/`)
- **Kubernetes manifests** for deployment and service
- **GitHub Actions pipeline** to automate Docker build, push, and deployment

---

## 📌 High-Level Architecture

1. **Infrastructure as Code (IaC)**:  
   A private GKE cluster is provisioned using Terraform. Networking, IAM, and other dependencies are handled programmatically.

2. **Application Containerization**:  
   The Flask application is packaged into a Docker image and stored in Google Container Registry (GCR).

3. **CI/CD Pipeline with GitHub Actions**:  
   The GitHub workflow automates:
   - Checking out code
   - Authenticating with GCP and GCR
   - Building and pushing the image
   - Deploying the app to GKE using Kubernetes manifests

---

## 🔒 Security and Secrets

GitHub Secrets are used to protect sensitive information:

- `GCP_SA_KEY`: A base64-encoded Google service account JSON key with sufficient IAM permissions (like GKE Admin, Storage Admin, etc.)

This key is used to authenticate the runner to both GCP and GCR securely.

---

## 🧑‍💻 Workflow Summary

### Trigger:
- Any commit pushed to the `master` branch triggers the deployment.

### Steps:
1. **Code Checkout**  
   The source code is cloned into the GitHub runner (self-hosted).

2. **GCP Authentication**  
   Using the service account key, the runner is authorized to interact with GCP services.

3. **Docker Image Build and Push**  
   The app is containerized and pushed to GCR.

4. **Kubernetes Deployment**  
   The image is pulled by GKE and deployed using the defined manifests.

---

## 🌐 GKE Cluster Setup

- The GKE cluster is private (nodes have no public IPs).
- Terraform configures:
  - VPC
  - Subnets
  - GKE cluster with regional multi-zonal nodes
  - Service Account bindings
  - Firewall rules for master-node communication

---

## 📂 Key Files

| Path | Description |
|------|-------------|
| `terraform/` | All infrastructure provisioning logic |
| `app/` | Flask application source and `Dockerfile` |
| `app/app.yml` | Kubernetes Deployment and Service manifests |
| `.github/workflows/deploy.yml` | GitHub Actions workflow file |

---

## ✅ Deployment Output

- On successful deployment, the app is available at the **external IP** exposed by the Kubernetes LoadBalancer service.
- Navigate to the IP to view the live Flask app.

---

## ⚠️ Common Pitfalls

- Make sure your `GCP_SA_KEY` secret is correctly formatted and valid.
- If image push fails, check GCR permissions or Docker authentication setup.
- Ensure the correct image path and tag is referenced inside the Kubernetes manifest.

---

## 👨‍🔧 Maintainer

**Sanjeev Ranjan**  
Cloud/DevOps Engineer | GCP | Kubernetes | Terraform  
📫 Connect on [LinkedIn](#)

---

## 📌 Future Enhancements

- Add health checks and resource limits in K8s deployment.
- Implement Helm charts for easier configuration management.
- Introduce monitoring (Stackdriver, Prometheus) and alerting.

---
