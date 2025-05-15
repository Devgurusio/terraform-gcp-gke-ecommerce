locals {
  account_id = var.service_account_id != null ? var.service_account_id : "sa-${trim(substr(local.cluster_name, 0, min(27, length(local.cluster_name))), "-")}"
}


resource "google_service_account" "sa" {
  provider = google

  # GCP SA account id must match the following regex: ^[a-z](?:[-a-z0-9]{4,28}[a-z0-9])$
  account_id   = local.account_id
  display_name = "Minimal service account for GKE cluster ${local.cluster_name}"
  project      = var.project_id
}

# Here we're just adding the minimum required permissions for the GKE node to work.
# Any addition permission that any pod may require should be added to the pod's SA
# Further info: https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#gcloud
resource "google_project_iam_member" "logging-log-writer" {
  provider = google

  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project_id
}

resource "google_project_iam_member" "monitoring-metric-writer" {
  provider = google

  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project_id
}

resource "google_project_iam_member" "monitoring-viewer" {
  provider = google

  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project_id
}

resource "google_project_iam_member" "resourceMetadata-writer" {
  provider = google

  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

# We're assuming we'll store images in GCR
resource "google_project_iam_member" "gcr-access" {
  provider = google

  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.sa.email}"
}
