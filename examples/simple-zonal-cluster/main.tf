module "gke" {
  source = "../.."

  project_id = var.project_id
  regional   = false
  zones      = [var.zone]

  cluster_name_suffix = "zonal"
}
