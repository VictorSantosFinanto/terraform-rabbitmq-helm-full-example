output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "network" {
  value = google_compute_network.vpc_network.name
}
