module "gke" {
  source     = "../.."
  project_id = var.project_id
  region     = var.region
  zones      = var.zones
}
