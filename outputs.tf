output "network_name" {
  value = google_compute_network.network.name
}

output "network_self_link" {
  value = google_compute_network.network.self_link
}

output "subnetwork_name" {
  value = google_compute_subnetwork.subnetwork.name
}

output "google_container_cluster" {
  value = google_container_cluster.primary.name
}

output "k8s_ingress_ip" {
  value = google_compute_address.k8s_ingress_ip.address
}

output "nat_address" {
  value = google_compute_address.nat_manual_ip.*.address
}
