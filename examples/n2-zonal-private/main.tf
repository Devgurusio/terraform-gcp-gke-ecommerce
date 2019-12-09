module "gke" {
  source              = "../.."
  project_id          = "project-gaia-101"
  regional            = false
  zones               = ["us-central1-a"]
  gke_instance_type   = "n2-standard-2"
  cluster_name_suffix = "-n2-x3"
  gke_auto_min_count  = 3
  gke_auto_max_count  = 3
}