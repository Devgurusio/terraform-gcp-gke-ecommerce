resource "google_compute_network" "network" {
  name                    = "${var.project_id}-network"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "${var.project_id}-subnetwork"
  project                  = var.project_id
  ip_cidr_range            = var.subnet_ip_cidr_range
  region                   = var.region
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true
}

resource "google_compute_global_address" "k8singress" {
  name    = "${var.project_id}-ip"
  project = var.project_id
}

resource "google_compute_router" "router" {
  name    = "${var.project_id}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.network.self_link
}

resource "google_compute_router_nat" "advanced-nat" {
  name                               = "${var.project_id}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  min_ports_per_vm                   = "8192"
  tcp_transitory_idle_timeout_sec    = "30"
  tcp_established_idle_timeout_sec   = "1200"
  udp_idle_timeout_sec               = "30"
  icmp_idle_timeout_sec              = "30"
  subnetwork {
    name                    = "${google_compute_subnetwork.subnetwork.self_link}"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  depends_on = [google_compute_network.network, google_compute_subnetwork.subnetwork]
}