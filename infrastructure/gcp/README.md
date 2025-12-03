# GCP Infrastructure for CKS Course

This directory contains Terraform configuration to provision the cks-master VM on Google Cloud Platform.

## VM Specifications

- **Name**: cks-master
- **Machine Type**: e2-medium (2 vCPU, 4GB RAM)
- **Image**: Ubuntu 24.04 LTS (Noble)
- **Boot Disk**: 50GB

## Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
2. Install and configure [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. Authenticate with GCP:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

## Usage

### Initialize Terraform

```bash
cd infrastructure/gcp
terraform init
```

### Plan the Infrastructure

```bash
terraform plan -var="project_id=YOUR_PROJECT_ID"
```

### Create the VM

```bash
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

### Destroy the VM

```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

## Configuration

You can customize the deployment by setting variables:

- `project_id`: Your GCP project ID (required)
- `region`: GCP region (default: europe-west3)
- `zone`: GCP zone (default: europe-west3-c)

Example using a variables file:

```bash
# Create terraform.tfvars
cat > terraform.tfvars <<EOF
project_id = "your-project-id"
region     = "europe-west3"
zone       = "europe-west3-c"
EOF

# Apply with variables file
terraform apply
```

## Connect to the VM

After creation, connect to the VM using:

```bash
gcloud compute ssh cks-master --zone=europe-west3-c
```

## Configure Kubernetes

Once connected to the VM, run the master setup script:

```bash
sudo -i
bash <(curl -s https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_master.sh)
```
