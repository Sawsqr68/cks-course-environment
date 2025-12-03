output "cks_master_name" {
  description = "The name of the cks-master VM"
  value       = google_compute_instance.cks_master.name
}

output "cks_master_internal_ip" {
  description = "The internal IP address of the cks-master VM"
  value       = google_compute_instance.cks_master.network_interface[0].network_ip
}

output "cks_master_external_ip" {
  description = "The external IP address of the cks-master VM"
  value       = google_compute_instance.cks_master.network_interface[0].access_config[0].nat_ip
}

output "cks_master_zone" {
  description = "The zone where the cks-master VM is located"
  value       = google_compute_instance.cks_master.zone
}
