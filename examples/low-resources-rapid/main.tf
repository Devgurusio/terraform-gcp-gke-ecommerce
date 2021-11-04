module "gke" {
  source = "../../"

  project_id          = var.project_id
  cluster_name_suffix = "low"
  regional            = false
  region              = var.region
  zones               = var.zones
  gke_instance_type   = "e2-standard-2"
  release_channel     = "RAPID"
  gke_preemptible     = true
}
