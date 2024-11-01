##############################################################################
# variables
##############################################################################
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets where the ALB will be deployed"
  type        = list(string)
}

variable "elb_name" {
  type = string
}
variable "load_balancer_type" {
  type = string
}

variable "internal" {
  type    = bool
  default = false
}

variable "security_groups" {
  type = list(string)
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}


##############################################################################
# resources
##############################################################################
resource "aws_lb" "main" {
  name                       = var.elb_name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_groups
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
}

##############################################################################
# outputs
##############################################################################
output "elb_arn" {
  value       = aws_lb.main.arn
  description = "The ARN of the load balancer"
}

output "elb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The DNS name of the load balancer"
}
