resource "google_container_node_pool" "primary_nodes" {
  provider = google-beta

  name    = "${var.project_id}-node-pool${var.cluster_name_suffix}-${var.gke_instance_type}"
  cluster = google_container_cluster.primary.name

  project  = var.project_id
  location = local.location

  node_config {
    oauth_scopes = var.oauth_scopes
    disk_size_gb = var.node_pool_disk_size
    preemptible  = var.gke_preemptible
    machine_type = var.gke_instance_type
    labels = {
      project     = var.project_id
      environment = var.environment
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

  node_count = var.gke_auto_min_count
  autoscaling {
    min_node_count = var.gke_auto_min_count
    max_node_count = var.gke_auto_max_count
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
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
