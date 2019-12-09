module "gke" {
  source       = "../.."
  project_id   = "project-gaia-101"
  regional     = false
  zones        = ["us-central1-a"]
  gke_instance_type   = "n1-standard-1"
  cluster_name_suffix = "-n1-istio"
  istio_config = true
}