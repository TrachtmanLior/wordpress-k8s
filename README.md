# WordPress Deployment with K3s, Terraform, ArgoCD & GitHub Actions

This project demonstrates a complete DevOps pipeline for deploying WordPress on an EC2 instance running K3s Kubernetes, connected to an RDS MySQL database. It includes infrastructure provisioning using Terraform, Helm-based deployment, GitOps with ArgoCD, and CI automation via GitHub Actions.

---

## 📚 Table of Contents

- [Project Structure](#-project-structure)
- [Technologies Used](#️-technologies-used)
- [Infrastructure Setup](#️-infrastructure-setup)
- [K3s Setup](#-k3s-setup)
- [Deploy ArgoCD](#-deploy-argocd)
- [Deploy WordPress via ArgoCD](#-deploy-wordpress-via-argocd)
- [GitHub Actions Automation](#-github-actions-automation)
- [Final Validation](#-final-validation)
- [Testing](#-test)
- [Credits](#-credits)

---

## 📁 Project Structure

- `main.tf` – Terraform configuration for EC2, RDS, and Security Groups
- `outputs.tf` – Outputs the public IP of the EC2 instance
- `install_k3s.sh` – Bash script to install K3s on the EC2 instance
- `wordpress-values.yaml` – Custom Helm values file connecting WordPress to the external RDS
- `wordpress-argocd.yaml` – ArgoCD Application manifest for WordPress
- `.github/workflows/deploy.yaml` – GitHub Actions workflow to auto-sync ArgoCD on changes
- `wordpress-helm/Chart.yaml` – Helm chart metadata for the WordPress deployment




---

## ⚙️ Technologies Used

- **Terraform** – Infrastructure provisioning (EC2, RDS, Security Groups)
- **K3s** – Lightweight Kubernetes distribution
- **Helm** – Application deployment via Bitnami WordPress chart
- **ArgoCD** – GitOps deployment management
- **GitHub Actions** – CI automation for triggering ArgoCD sync

---

## 🛠️ Infrastructure Setup

1. Initialize and apply the Terraform scripts:

```bash
terraform init
terraform apply
```
Output: Public IP of EC2 and RDS endpoint

## ☸️ K3s Setup

### Step 1: SSH into the EC2 Instance

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<EC2_PUBLIC_IP>
```

Deploy WordPress via ArgoCD

Apply the ArgoCD application manifest:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/<your-username>/wordpress-k8s/main/wordpress-argocd.yaml
```

### Step 2: Install K3s
This will install WordPress using the Bitnami chart and configure it using wordpress-values.yaml with an external RDS database.

```bash
curl -sfL https://get.k3s.io | sh -
```

### Step 3: Configure kubectl Access

```bash
sudo chmod +r /etc/rancher/k3s/k3s.yaml
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

### Step 4: Verify K3s Cluster

```bash
kubectl get nodes
```

## Deploy ArgoCD

### Step 1: Install ArgoCD in Kubernetes
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Step 2: Expose ArgoCD Server via NodePort

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

### Step 3: Retrieve Access Details

```bash
# Get exposed ArgoCD service port
kubectl get svc -n argocd

# Get ArgoCD admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## GitHub Actions Automation

Located in .github/workflows/deploy.yaml, this workflow automatically syncs ArgoCD when changes are pushed to key deployment files:


## Final Validation

Make sure the following components are working:

- EC2 instance with K3s is running
- RDS MySQL database is reachable
- ArgoCD is accessible and monitoring the app
- WordPress is deployed and accessible in a browser
- GitHub Actions triggers ArgoCD sync on changes

  
---

## Testing

To test the full GitOps pipeline:

1. Edit the `image.tag` field in `wordpress-values.yaml`
2. Commit and push the change to GitHub
3. Confirm:
   - GitHub Actions runs successfully
   - ArgoCD auto-syncs the deployment
   - A new WordPress pod is deployed with the updated tag
