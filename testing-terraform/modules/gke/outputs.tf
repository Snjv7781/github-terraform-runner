output "cluster_name" {
  value = google_container_cluster.private_cluster.name
}

output "endpoint" {
  value = google_container_cluster.private_cluster.endpoint
}
