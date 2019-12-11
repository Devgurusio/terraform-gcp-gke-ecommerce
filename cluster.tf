## Private & Regional Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-cluster${var.cluster_name_suffix}"
  location = local.location
  provider = google-beta
  # So we create the smallest possible default node pool and immediately delete it. Using node pools
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = var.kubernetes_version
  node_version             = var.kubernetes_version
  # Point to stackdriver api
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  logging_service    = "logging.googleapis.com/kubernetes"
  network            = google_compute_network.network.self_link
  subnetwork         = google_compute_subnetwork.subnetwork.self_link

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  resource_labels = {
    project     = var.project_id
    environment = var.environment
    tenant      = "global"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      node_version,
      resource_labels,
    ]
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.daily_maintenance_window_start
    }
  }

  addons_config {
    istio_config {
      disabled = ! var.istio_config
    }
  }

  depends_on = [google_compute_router_nat.advanced-nat, google_compute_router.router]
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_id}-node-pool${var.cluster_name_suffix}"
  project    = var.project_id
  location   = local.location
  provider   = google-beta
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_auto_min_count

  node_config {
    oauth_scopes = var.oauth_scopes
    disk_size_gb = var.node_pool_disk_size
    preemptible  = var.gke_preemptible
    machine_type = var.gke_instance_type
    labels = {
      project     = var.project_id
      environment = var.environment
      tenant      = "global"
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = [var.environment]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.gke_auto_min_count
    max_node_count = var.gke_auto_max_count
  }

  lifecycle {
    ignore_changes = [
      node_count,
      node_config.0.labels,
      node_config.0.metadata,
      node_config.0.metadata.disable-legacy-endpoints
    ]
    create_before_destroy = true
  }
}

