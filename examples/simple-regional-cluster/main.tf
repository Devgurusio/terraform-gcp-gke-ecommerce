module "gke" {
  source = "../../"

  project_id = var.project_id
  regional   = true
  region     = var.region

  cluster_name_suffix = "regional"
}
