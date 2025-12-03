#!/bin/bash

# GCP Firewall Setup Script for CKS Course Environment
# This script creates the necessary firewall rules for Kubernetes NodePorts
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Active GCP project configured
#
# Usage:
#   ./setup_gcp_firewall.sh

set -e

echo "=================================="
echo "GCP Firewall Setup for CKS Course"
echo "=================================="
echo

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed"
    echo "Please install gcloud from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if [ -z "$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)" ]; then
    echo "Error: No active gcloud authentication found"
    echo "Please run: gcloud auth login"
    exit 1
fi

# Get current project
PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT" ]; then
    echo "Error: No GCP project is set"
    echo "Please run: gcloud config set project YOUR_PROJECT"
    exit 1
fi

echo "Current GCP Project: $PROJECT"
echo

# Check if firewall rule already exists
if gcloud compute firewall-rules describe nodeports &> /dev/null; then
    echo "Firewall rule 'nodeports' already exists"
    echo "Current configuration:"
    gcloud compute firewall-rules describe nodeports --format="table(allowed[].IPProtocol:label=PROTOCOL,allowed[].ports:label=PORTS)"
    echo
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing firewall rule..."
        gcloud compute firewall-rules delete nodeports --quiet
    else
        echo "Keeping existing firewall rule. Exiting."
        exit 0
    fi
fi

# Create firewall rule for NodePorts
echo "Creating firewall rule for NodePorts (TCP 30000-40000)..."
gcloud compute firewall-rules create nodeports --allow tcp:30000-40000

echo
echo "✓ Firewall rule 'nodeports' created successfully!"
echo
echo "You can now access Kubernetes services using NodePorts in the range 30000-40000"
echo "Example: http://<node-external-ip>:30080"
