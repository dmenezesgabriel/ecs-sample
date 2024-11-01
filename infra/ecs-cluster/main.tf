##############################################################################
# variables
##############################################################################
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

##############################################################################
# resources
##############################################################################
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "ecs_cluster_logs" {
  name              = "/ecs/cluster/${var.cluster_name}"
  retention_in_days = 30
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.cluster_name}.local"
  description = "Service Discovery Namespace for ${var.cluster_name}"
  vpc         = var.vpc_id
}

##############################################################################
# outputs
##############################################################################
output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.this.id
}

output "service_discovery_namespace_name" {
  value = aws_service_discovery_private_dns_namespace.this.name
}

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}
