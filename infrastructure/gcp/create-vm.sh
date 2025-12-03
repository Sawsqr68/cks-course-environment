#!/bin/bash

# Script to create the cks-master VM on Google Cloud Platform
# 
# VM Specifications:
# - Name: cks-master
# - Machine Type: e2-medium (2 vCPU, 4GB RAM)
# - Image: Ubuntu 24.04 LTS (Noble)
# - Boot Disk: 50GB

set -e

# Configuration
VM_NAME="cks-master"
MACHINE_TYPE="e2-medium"
ZONE="${ZONE:-europe-west3-c}"
BOOT_DISK_SIZE="50GB"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first:"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    print_error "Not authenticated with gcloud. Please run:"
    echo "  gcloud auth login"
    exit 1
fi

# Get the project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    print_error "No GCP project configured. Please run:"
    echo "  gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

print_info "Using project: $PROJECT_ID"
print_info "Using zone: $ZONE"

# Get the latest Ubuntu 24.04 image
print_info "Fetching latest Ubuntu 24.04 LTS image..."
UBUNTU_IMAGE=$(gcloud compute images list \
    --project=ubuntu-os-cloud \
    --no-standard-images \
    --filter="family:ubuntu-2404-lts AND status:READY" \
    --format="value(name)" \
    --limit=1)

if [ -z "$UBUNTU_IMAGE" ]; then
    print_error "Could not find Ubuntu 24.04 LTS image"
    exit 1
fi

print_info "Using image: $UBUNTU_IMAGE"

# Check if VM already exists
if gcloud compute instances describe "$VM_NAME" --zone="$ZONE" &>/dev/null; then
    print_warning "VM '$VM_NAME' already exists in zone $ZONE"
    read -p "Do you want to delete it and recreate? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Deleting existing VM..."
        gcloud compute instances delete "$VM_NAME" --zone="$ZONE" --quiet
    else
        print_info "Keeping existing VM. Exiting."
        exit 0
    fi
fi

# Create the VM
print_info "Creating VM '$VM_NAME'..."
gcloud compute instances create "$VM_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image="$UBUNTU_IMAGE" \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size="$BOOT_DISK_SIZE" \
    --boot-disk-type=pd-standard \
    --tags=cks-master,kubernetes \
    --metadata=enable-oslogin=true

if [ $? -eq 0 ]; then
    print_info "VM '$VM_NAME' created successfully!"
    echo ""
    print_info "To connect to the VM, run:"
    echo "  gcloud compute ssh $VM_NAME --zone=$ZONE"
    echo ""
    print_info "To configure Kubernetes on the VM, run:"
    echo "  sudo -i"
    echo "  bash <(curl -s https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_master.sh)"
else
    print_error "Failed to create VM"
    exit 1
fi
