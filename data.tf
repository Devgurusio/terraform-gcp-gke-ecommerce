locals {
  // location
  location   = var.regional ? var.region : var.zones[0]
  region     = var.region == null ? join("-", slice(split("-", var.zones[0]), 0, 2)) : var.region
  zone_count = length(var.zones)

  // for regional cluster - use var.zones if provided, use available otherwise, for zonal cluster use var.zones with first element extracted
  node_locations = var.regional ? coalescelist(compact(var.zones), sort(random_shuffle.available_zones.result)) : slice(var.zones, 1, length(var.zones))

  // Kubernetes version
  master_version_regional = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.region.latest_master_version
  master_version_zonal    = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.zone.latest_master_version

  master_version = var.regional ? local.master_version_regional : local.master_version_zonal

  # This variable will be prepended to all related resources
  cluster_suffix = var.cluster_name_suffix != "" ? "-${var.cluster_name_suffix}" : ""
  # Allow to override project prefix or truncate to prevent resource names longer than 40 characters
  project_prefix = var.project_name_override == "" ? substr(var.project_id, 0, 28) : var.project_name_override
  cluster_name   = "${local.project_prefix}-cluster${local.cluster_suffix}"
}

resource "random_shuffle" "available_zones" {
  input        = data.google_compute_zones.available.names
  result_count = 3
}

/******************************************
  Get available zones in region
 *****************************************/
data "google_compute_zones" "available" {
  provider = google

  project = var.project_id
  region  = local.region
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
