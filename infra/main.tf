provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./vpc"
}

module "load_balancer" {
  source     = "./load-balancer"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  apps       = var.apps
}

module "ecs_cluster" {
  source                = "./ecs-cluster"
  cluster_name          = "my-ecs-cluster"
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.load_balancer.alb_security_group_id
}

variable "apps" {
  description = "List of applications to deploy"
  type = list(object({
    name            = string
    container_image = string
    container_port  = number
    cpu             = string
    memory          = string
    desired_count   = number
    path_pattern    = string
  }))
  default = [
    {
      name            = "app1"
      container_image = "dmenezesgabriel/fastapi-app1:v1"
      container_port  = 8000
      cpu             = "256"
      memory          = "512"
      desired_count   = 2
      path_pattern    = "/app1*"
    },
    {
      name            = "app2"
      container_image = "dmenezesgabriel/fastapi-app2:v1"
      container_port  = 8000
      cpu             = "256"
      memory          = "512"
      desired_count   = 2
      path_pattern    = "/app2*"
    }
  ]
}

module "ecs_services" {
  source = "./ecs-service"
  count  = length(var.apps)

  cluster_id                  = module.ecs_cluster.cluster_id
  vpc_id                      = module.vpc.vpc_id
  app_name                    = var.apps[count.index].name
  container_image             = var.apps[count.index].container_image
  container_port              = var.apps[count.index].container_port
  cpu                         = var.apps[count.index].cpu
  memory                      = var.apps[count.index].memory
  desired_count               = var.apps[count.index].desired_count
  subnet_ids                  = module.vpc.public_subnet_ids
  task_execution_role_arn     = module.ecs_cluster.task_execution_role_arn
  ecs_tasks_security_group_id = module.ecs_cluster.ecs_tasks_security_group_id
  alb_security_group_id       = module.load_balancer.alb_security_group_id
  lb_listener                 = module.load_balancer.lb_listener
  target_group_arn            = module.load_balancer.target_group_arns[count.index]
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}
