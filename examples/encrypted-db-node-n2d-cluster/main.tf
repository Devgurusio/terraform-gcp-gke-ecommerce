module "gke" {
  source = "../../"

  project_id          = var.project_id
  cluster_name_suffix = "node"
  regional            = true
  region              = var.region
  zones               = var.zones
  gke_instance_type   = "n2d-standard-2"

  database_encryption = {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.master_encryption_key.self_link
  }
  boot_disk_kms_key = google_kms_crypto_key.node_encryption_key.self_link
}

### Encryption keys
resource "google_kms_key_ring" "cluster_encryption_key_ring" {
  provider = google
  name     = "${var.project_id}-cluster-node-encryption-key-ring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "master_encryption_key" {
  provider = google
  name     = "${var.project_id}-cluster-master-encryption-key"
  key_ring = google_kms_key_ring.cluster_encryption_key_ring.self_link
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_kms_crypto_key" "node_encryption_key" {
  provider = google
  name     = "${var.project_id}-cluster-node-encryption-key"
  key_ring = google_kms_key_ring.cluster_encryption_key_ring.self_link
  purpose  = "ENCRYPT_DECRYPT"
}


# If key already exists, use inversion dependency pattern
//data "google_kms_key_ring" "cluster_encryption_key_ring" {
//  provider = google
//  name     = "${var.project_id}-cluster-node-encryption-key-ring"
//  location = var.region
//  project  = var.project_id
//}
//
//data "google_kms_crypto_key" "master_encryption_key" {
//  provider = google
//  name     = "${var.project_id}-cluster-master-encryption-key"
//  key_ring = data.google_kms_key_ring.cluster_encryption_key_ring.self_link
//}
//
//data "google_kms_crypto_key" "node_encryption_key" {
//  provider = google
//  name     = "${var.project_id}-cluster-node-encryption-key"
//  key_ring = data.google_kms_key_ring.cluster_encryption_key_ring.self_link
//}

# Allow GCE to use the KMS key to encrypt/decrypt
resource "google_kms_crypto_key_iam_member" "master_crypto_key" {
  crypto_key_id = google_kms_crypto_key.master_encryption_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "node_crypto_key" {
  crypto_key_id = google_kms_crypto_key.node_encryption_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@compute-system.iam.gserviceaccount.com"
}

data "google_project" "current" {
  project_id = var.project_id
}
