output "ping_results" {
  description = "Aggregated ping results"
  value       = join("\n", [for i in range(var.instance_count) : element(null_resource.ping_test[*].triggers.result, i)])
}
