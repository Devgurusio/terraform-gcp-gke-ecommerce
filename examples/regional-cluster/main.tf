module "gke" {
  source = "../../"

  project_id = "devops-common"
  regional   = true
  region     = "us-central1"
}
