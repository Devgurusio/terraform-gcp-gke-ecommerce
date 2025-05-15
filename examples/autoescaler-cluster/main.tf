module "gke" {
  source = "../.."

  project_id                = var.project_id
  enable_cluster_autoscaler = true
  enable_vpa                = true
  cluster_name_suffix       = "autoescaler"
}
