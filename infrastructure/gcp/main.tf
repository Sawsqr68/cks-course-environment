terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Get the latest Ubuntu 24.04 LTS (Noble) image
data "google_compute_image" "ubuntu_2404" {
  family  = "ubuntu-2404-lts"
  project = "ubuntu-os-cloud"
}

# Create cks-master VM instance
resource "google_compute_instance" "cks_master" {
  name         = "cks-master"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["cks-master", "kubernetes"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_2404.self_link
      size  = 50
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    enable-oslogin = "true"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "VM created successfully - ready for cks-master setup"
  EOF
}
