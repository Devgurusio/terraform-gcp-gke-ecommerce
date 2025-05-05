# This keepers list is based on the variables that will force a new node pool resource to be created
resource "random_id" "node_pool_name" {
  byte_length = 2
  # Node pool name must be less than 40 characters so we left 5 characters for the suffix
  prefix = format("%s-", substr("${var.gke_instance_type}-node-pool", 0, 35))
  keepers = {
    environment     = var.environment,
    project_id      = var.project_id,
    disk_size_gb    = var.node_pool_disk_size,
    disk_type       = var.node_pool_disk_type,
    machine_type    = var.gke_instance_type,
    preemptible     = var.gke_preemptible,
    service_account = google_service_account.sa.email,
    image_type      = "COS_CONTAINERD"
  }
}

# TODO: add support to deploy several node-pools
resource "google_container_node_pool" "primary_nodes" {
  provider = google

  # This random suffix allows us to re-create the node pool by creating the new one and once that's
  # up and running the old one will be decomisioned.
  name    = random_id.node_pool_name.hex
  cluster = google_container_cluster.primary.name

  project  = var.project_id
  location = local.location
  // if it is a regional cluster set all the zones, if it is zonal it will be null, no additional zones (multi-zonal)
  node_locations = local.node_locations

  node_config {
    preemptible  = var.gke_preemptible
    machine_type = var.gke_instance_type

    disk_size_gb = var.node_pool_disk_size
    disk_type    = var.node_pool_disk_type

    # The set of Google API scopes to be made available on all of the node VMs
    # under the "default" service account. These can be either FQDNs, or scope
    # aliases. The cloud-platform access scope authorizes access to all Cloud
    # Platform services, and then limit the access by granting IAM roles
    # https://cloud.google.com/compute/docs/access/service-accounts#service_account_permissions
    # If any microservice requires further permissions we should do it by creating a SA for that
    # service
    # https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    service_account = google_service_account.sa.email

    labels = {
      project     = var.project_id
      environment = var.environment
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }

    metadata = {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
      disable-legacy-endpoints = "true"
    }

    # For security we recommend encrypting the node root volume
    # https://cloud.google.com/compute/docs/disks/customer-managed-encryption#command-line
    boot_disk_kms_key = var.boot_disk_kms_key

    image_type = random_id.node_pool_name.keepers.image_type

    tags = [var.environment]

    dynamic "kubelet_config" {
      for_each = var.kubelet_config == null ? [] : [var.kubelet_config]
      content {
        cpu_manager_policy   = kubelet_config.value.cpu_manager_policy
        cpu_cfs_quota        = kubelet_config.value.cpu_cfs_quota
        cpu_cfs_quota_period = kubelet_config.value.cpu_cfs_quota_period
      }
    }

  }

  management {
    auto_repair  = var.node_auto_repair
    auto_upgrade = var.node_auto_upgrade
  }

  # Setting initial_node_count to 1 so at least default workloads can be deployed
  initial_node_count = var.gke_initial_node_count
  autoscaling {
    min_node_count = var.gke_auto_min_count
    max_node_count = var.gke_auto_max_count
  }

  upgrade_settings {
    # https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-upgrades#optimizing-surge
    # For nodes that use Spot VMs surge upgrade values are ignored because there is no availability guarantee
    # Max extra nodes that can be added to update
    max_surge = var.gke_max_surge
    # Max unavailable nodes during the upgrade (0 less disruptive)
    max_unavailable = var.gke_max_unavailable
    # Nodes upgraded simultaneously = max_surge + max_unavailable. Limited to 20
    # Balanced least disruptive:      max_surge=1 max_unavailable=0
    # Fast disruptive:                max_surge=0 max_unavailable=20
    # Fast expensive less disruptive: max_surge=20 max_unavailable=0
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_count,
      node_config.0.labels,
      node_config.0.metadata,
      node_config.0.metadata.disable-legacy-endpoints
    ]
    create_before_destroy = true
  }
}
