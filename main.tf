/******************************************
  Get available zones in region
 *****************************************/
data "google_compute_zones" "available" {
  provider = google

  project = var.project_id
  region  = local.region
}

resource "random_shuffle" "available_zones" {
  input        = data.google_compute_zones.available.names
  result_count = 3
}

locals {
  // location
  location = var.regional ? var.region : var.zones[0]
  region   = var.region == null ? join("-", slice(split("-", var.zones[0]), 0, 2)) : var.region
  // for regional cluster - use var.zones if provided, use available otherwise, for zonal cluster use var.zones with first element extracted
  node_locations = var.regional ? coalescelist(compact(var.zones), sort(random_shuffle.available_zones.result)) : slice(var.zones, 1, length(var.zones))
  zone_count     = length(var.zones)
  // kuberentes version
  master_version_regional = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.region.latest_master_version
  master_version_zonal    = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.zone.latest_master_version
  node_version_regional   = var.node_version != "" && var.regional ? var.node_version : local.master_version_regional
  node_version_zonal      = var.node_version != "" && ! var.regional ? var.node_version : local.master_version_zonal
  master_version          = var.regional ? local.master_version_regional : local.master_version_zonal
  node_version            = var.regional ? local.node_version_regional : local.node_version_zonal
}

/******************************************
  Get available container engine versions
 *****************************************/
data "google_container_engine_versions" "region" {
  location = local.location
  project  = var.project_id
}

data "google_container_engine_versions" "zone" {
  // Work around to prevent a lack of zone declaration from causing regional cluster creation from erroring out due to error
  //
  //     data.google_container_engine_versions.zone: Cannot determine zone: set in this resource, or set provider-level zone.
  //
  location = local.zone_count == 0 ? data.google_compute_zones.available.names[0] : var.zones[0]
  project  = var.project_id
}
