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

output "k8singress_ip" {
  value = google_compute_global_address.k8singress.address
}
