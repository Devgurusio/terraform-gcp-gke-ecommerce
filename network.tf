resource "google_compute_network" "network" {
  name                    = "${var.project_id}-network${var.cluster_name_suffix}"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "${var.project_id}-subnetwork${var.cluster_name_suffix}"
  project                  = var.project_id
  ip_cidr_range            = var.subnet_ip_cidr_range
  region                   = local.region
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true
}

resource "google_compute_address" "k8s_ingress_ip" {
  name         = "${var.project_id}-ingress-ip${var.cluster_name_suffix}"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "nat_manual_ip" {
  count  = var.nat_ip_count
  name   = "${var.project_id}-nat-manual-ip-${count.index}${var.cluster_name_suffix}"
  region = var.region
}

resource "google_compute_router" "router" {
  name    = "${var.project_id}-router${var.cluster_name_suffix}"
  project = var.project_id
  region  = local.region
  network = google_compute_network.network.self_link
}

resource "google_compute_router_nat" "advanced-nat" {
  name                               = "${var.project_id}-nat${var.cluster_name_suffix}"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region

  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_manual_ip.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm                   = var.min_ports_per_vm
  tcp_transitory_idle_timeout_sec    = var.tcp_transitory_idle_timeout_sec
  tcp_established_idle_timeout_sec   = var.tcp_established_idle_timeout_sec
  udp_idle_timeout_sec               = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec              = var.icmp_idle_timeout_sec

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# TODO: We need the connector if we want GCP Functions and GCP Cloud Run to go through the NAT
#
# resource "google_vpc_access_connector" "connector" {
#   name          = "vpc-connector-${var.project_name}"
#   region        = var.region
#   ip_cidr_range = var.connector_ip_cidr_range
#   network       = google_compute_network.network.name
# }

# TODO: We may need to add this istio workaround once we include istio in the k8s cluster
#
# # Workaround to fix to allow the autoinject error
# # Updated to istio 1.5 (15017)
# resource "google_compute_firewall" "istio_rule" {
#   name          = "istio-allow-firewall"
#   project       = var.project_id
#   network       = google_compute_network.network.self_link
#   priority      = 1000
#   direction     = "INGRESS"
#   source_ranges = [var.master_ip_cidr_block]
#   // As we don't know the network tag, we allow for all
#   //target_tags   = ["gke-gke-on-vpc-cluster-349a7ec2-node"]

#   allow {
#     protocol = "tcp"
#     ports    = ["9443", "15017"]
#   }

#   depends_on = [google_compute_network.network]
# }
