module "gke" {
  source = "../../"

  project_id = var.project_id
  regional   = true
  region     = var.region

  database_encryption = {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.master_encryption_key.self_link
  }

  cluster_name_suffix = "db"
}

### Master encryption key
resource "google_kms_crypto_key" "master_encryption_key" {
  provider = google

  name     = "${var.project_id}-cluster-master-encryption-key"
  key_ring = google_kms_key_ring.master_encryption_key_ring.self_link
  purpose  = "ENCRYPT_DECRYPT"

}

resource "google_kms_key_ring" "master_encryption_key_ring" {
  provider = google

  name     = "${var.project_id}-cluster-master-encryption-key-ring"
  location = var.region
  project  = var.project_id
}

# Allow GKE to use the KMS key to encrypt/decrypt
resource "google_kms_crypto_key_iam_member" "master_crypto_key" {
  crypto_key_id = google_kms_crypto_key.master_encryption_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
}

data "google_project" "current" {
  project_id = var.project_id
}
