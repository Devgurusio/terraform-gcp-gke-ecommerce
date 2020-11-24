resource "google_compute_network" "network" {
  name                    = "${local.cluster_name}-network"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "${local.cluster_name}-subnetwork"
  project                  = var.project_id
  ip_cidr_range            = var.subnet_ip_cidr_range
  region                   = local.region
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true
}

resource "google_compute_address" "k8s_ingress_ip" {
  name         = "${local.cluster_name}-ingress-ip"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "nat_manual_ip" {
  count  = var.nat_ip_count
  name   = "${local.cluster_name}-nat-manual-ip-${count.index}"
  region = var.region
}

resource "google_compute_router" "router" {
  name    = "${local.cluster_name}-router"
  project = var.project_id
  region  = local.region
  network = google_compute_network.network.self_link
}

resource "google_compute_router_nat" "advanced-nat" {
  name    = "${local.cluster_name}-nat"
  project = var.project_id
  router  = google_compute_router.router.name
  region  = var.region

  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_manual_ip.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm                 = var.min_ports_per_vm
  tcp_transitory_idle_timeout_sec  = var.tcp_transitory_idle_timeout_sec
  tcp_established_idle_timeout_sec = var.tcp_established_idle_timeout_sec
  udp_idle_timeout_sec             = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec            = var.icmp_idle_timeout_sec

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Istio rule only for private GKE clusters: Need to open 15017 needed by the Pilot discovery validation webhook
resource "google_compute_firewall" "istio_discovery_rule" {
  count         = var.regional ? 1 : 0
  name          = "istio-discovery-allow-firewall"
  project       = var.project_id
  network       = google_compute_network.network.self_link
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = [var.master_ipv4_cidr_block]
  // As we don't know the network tag, we allow for all
  //target_tags   = ["gke-${var.project-id}-cluster-node-gke-28f667bc-node"]

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "15017"]
  }

  depends_on = [google_compute_network.network]
}
