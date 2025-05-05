## Private & Regional Cluster
resource "google_container_cluster" "primary" {

  name                = "${local.cluster_name}-gke"
  location            = local.location
  node_locations      = local.node_locations
  min_master_version  = local.min_master_version
  deletion_protection = var.deletion_protection

  # We can't create a cluster with no node pool defined, but we want to only use separately managed
  # node pools. So we create the smallest possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # The monitoring service that the cluster should write metrics to. Using the
  # 'monitoring.googleapis.com/kubernetes' option makes use of new Stackdriver
  # Kubernetes integration.
  monitoring_service = var.monitoring_service
  # The loggingservice that the cluster should write logs to. Using the
  # 'logging.googleapis.com/kubernetes' option makes use of new Stackdriver
  # Kubernetes integration.
  logging_service = var.logging_service

  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  release_channel {
    channel = var.release_channel
  }

  enable_shielded_nodes = true
  workload_identity_config {
    # Currently, the only supported identity namespace is the project of the cluster.
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  resource_labels = {
    project     = var.project_id
    environment = var.environment
  }

  database_encryption {
    key_name = var.database_encryption.key_name
    state    = var.database_encryption.state
  }

  # We're setting these configs following GKE best practices
  # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  master_authorized_networks_config {
    # Let the master open to the world could be risky
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.daily_maintenance_window_start
    }
  }

  addons_config {
    # This is the default value but we want to be sure it will be always enabled
    # This property will automatically create node pools based on resources consumption
    horizontal_pod_autoscaling {
      disabled = !var.enable_hpa
    }

    # CSI is a storage specification that allows cloud providers to provide vendor-specific support
    # for storage features outside the k8s binary
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    network_policy_config {
      disabled = !var.enable_netpol
    }

  }

  network_policy {
    enabled  = var.enable_netpol
    provider = var.enable_netpol ? upper(var.netpol_provider) : null
  }

  dynamic "cluster_autoscaling" {
    for_each = var.enable_cluster_autoscaler ? [1] : []
    content {
      enabled             = true
      autoscaling_profile = var.autoscaling_profile
      resource_limits {
        resource_type = "cpu"
        minimum       = var.cluster_autoscaler_cpu_min
        maximum       = var.cluster_autoscaler_cpu_max
      }
      resource_limits {
        resource_type = "memory"
        minimum       = var.cluster_autoscaler_memory_min_gb
        maximum       = var.cluster_autoscaler_memory_max_gb
      }
    }
  }

  dynamic "vertical_pod_autoscaling" {
    for_each = var.enable_vpa ? [1] : []
    content {
      enabled = true
    }
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      node_version,
      resource_labels,
    ]
  }
  depends_on = [google_compute_router_nat.advanced-nat, google_compute_router.router]
}
