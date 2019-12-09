module "gke" {
  //source  = "DevgurusSupport/gke-ecommerce/gcp"
  //version = "0.0.1"
  source = "../.."
  project_id   = var.project_id
  regional     = false
  zones        = ["us-central1-a"]
  gke_instance_type   = "n1-standard-2"
  cluster_name_suffix = "-n1-x4"
  gke_auto_min_count = 4
  gke_auto_max_count = 6
}