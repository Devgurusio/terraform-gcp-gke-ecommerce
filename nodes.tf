# TODO: add support to deploy several node-pools
resource "google_container_node_pool" "primary_nodes" {
  provider = google-beta

  # Node pool name must be less than 40 characters
  name    = substr("${var.gke_instance_type}-node-pool", 0, 40)
  cluster = google_container_cluster.primary.name

  project  = var.project_id
  location = local.location

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

    metadata = {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
      disable-legacy-endpoints = "true"
    }

    # For security we're encrypting the node root volume
    # https://cloud.google.com/compute/docs/disks/customer-managed-encryption#command-line
    boot_disk_kms_key = google_kms_crypto_key.node_encryption_key.self_link

    tags = [var.environment]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Setting initial_node_count to 1 so at least default workloads can be deployed
  initial_node_count = var.gke_initial_node_count
  autoscaling {
    min_node_count = var.gke_auto_min_count
    max_node_count = var.gke_auto_max_count
  }

  # In the future we should be able to optimize and parametrize this values
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
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

resource "google_kms_crypto_key" "node_encryption_key" {
  provider = google-beta

  name     = "${local.cluster_name}-node-encryption-key"
  key_ring = google_kms_key_ring.node_encryption_key_ring.self_link
  purpose  = "ENCRYPT_DECRYPT"

  # TODO: Should we add a rotation period?
}

resource "google_kms_key_ring" "node_encryption_key_ring" {
  provider = google-beta

  name     = "${local.cluster_name}-node-encryption-key-ring"
  location = local.location
  project  = var.project_id
}

# Allow GCE to use the KMS key to encrypt/decrypt
resource "google_kms_crypto_key_iam_member" "node_crypto_key" {
  crypto_key_id = google_kms_crypto_key.node_encryption_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@compute-system.iam.gserviceaccount.com"
}
