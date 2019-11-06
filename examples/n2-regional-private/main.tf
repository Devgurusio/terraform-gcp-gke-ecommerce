module "gke" {
  source     = "../.."
  project_id = "project-gaia-101"
  region     = "us-central1"
  zones = ["us-central1-a","us-central1-c","us-central1-f"]

  gke_instance_type = "n2-standard-2"
  cluster_name_suffix = "-n2-regional"
}