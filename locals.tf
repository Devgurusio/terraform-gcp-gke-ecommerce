locals {
  // location
  location   = var.regional ? var.region : var.zones[0]
  region     = var.region == null ? join("-", slice(split("-", var.zones[0]), 0, 2)) : var.region
  zone_count = length(var.zones)

  // Kubernetes version
  master_version_regional = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.region.latest_master_version
  master_version_zonal    = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.zone.latest_master_version

  master_version = var.regional ? local.master_version_regional : local.master_version_zonal

  # This variable will be prepended to all related resources
  cluster_suffix = var.cluster_name_suffix != "" ? "-${var.cluster_name_suffix}" : ""
  cluster_name   = "${var.project_id}-cluster${local.cluster_suffix}"
}
