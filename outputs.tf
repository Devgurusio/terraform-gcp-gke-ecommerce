output "network_name" {
  value       = google_compute_network.network.name
  description = "Network name"
}

output "network_self_link" {
  value       = google_compute_network.network.self_link
  description = "Network selflink"
}

output "subnetwork_name" {
  value       = google_compute_subnetwork.subnetwork.name
  description = "Subnetwork name"
}

output "google_container_cluster" {
  value       = google_container_cluster.primary.name
  description = "GKE cluster name"
}

output "k8s_ingress_ip" {
  value       = google_compute_address.k8s_ingress_ip.address
  description = "API server public IP address"
}

output "nat_address" {
  value       = google_compute_address.nat_manual_ip.*.address
  description = "List of NAT addresses"
}
