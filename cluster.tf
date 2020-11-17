## Private & Regional Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-cluster${var.cluster_name_suffix}"
  location = local.location
  provider = google-beta

  # We can't create a cluster with no node pool defined, but we want to only use separately managed node pools.
  # So we create the smallest possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = local.master_version

  # Point to stackdriver api
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  logging_service    = "logging.googleapis.com/kubernetes"
  network            = google_compute_network.network.self_link
  subnetwork         = google_compute_subnetwork.subnetwork.self_link

  release_channel {
    channel = var.release_channel
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # TODO: Shouldn't we set this property?
  # https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/container_cluster#networking_mode
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  resource_labels = {
    project     = var.project_id
    environment = var.environment
  }

  # We should encrypt etcd cluster for security
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.encryption_key.self_link
  }

  master_authorized_networks_config {
    # Let the master open to the world could be risky
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  lifecycle {
    # prevent_destroy = true
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
    # This is the default value but we want to be sure it will be always enabled
    # This property will automatically create node pools based on resources consumption
    horizontal_pod_autoscaling {
      disabled = false
    }

    # Removed the to configure it as currently we don't want to deploy istio addon
    istio_config {
      disabled = true
    }

    # CSI is a storage specification that allows cloud providers to provide vendor-specific support
    # for storage features outside the k8s binary
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

  }

  depends_on = [google_compute_router_nat.advanced-nat, google_compute_router.router]
}

resource "google_kms_crypto_key" "encryption_key" {
  provider = google-beta

  name     = "${var.project_id}-cluster${var.cluster_name_suffix}-encryption-key"
  key_ring = google_kms_key_ring.encryption_key_ring.self_link
  purpose  = "ENCRYPT_DECRYPT"

  # TODO: Should we add a rotation period?
}

resource "google_kms_key_ring" "encryption_key_ring" {
  provider = google-beta

  name     = "${var.project_id}-cluster${var.cluster_name_suffix}-encryption-key-ring"
  location = local.location
  project  = var.project_id
}

# Allow GKE to use the KMS key to encrypt/decrypt
resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.encryption_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
}
