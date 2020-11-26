module "gke" {
  source = "../../"

  project_id = var.project_id
  regional   = true
  region     = var.region

  node_auto_upgrade = false
  node_auto_repair  = false

  cluster_name_suffix = "regional"
}
