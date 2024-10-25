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
  cluster_name          = "sample-ecs-cluster"
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.load_balancer.alb_security_group_id
}

variable "apps" {
  description = "List of applications to deploy"
  type = list(object({
    name                     = string
    container_image          = string
    container_port           = number
    cpu                      = string
    memory                   = string
    desired_count            = number
    route_path               = string
    enable_autoscaling       = bool
    autoscaling_min_capacity = number
    autoscaling_max_capacity = number
    autoscaling_cpu_target   = number
    environment_variables    = map(string)
  }))
  default = [
    {
      name                     = "app1"
      container_image          = "dmenezesgabriel/fastapi-app1:v3"
      container_port           = 8000
      cpu                      = "256"
      memory                   = "512"
      desired_count            = 2
      route_path               = "/app1"
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP2_URL = "http://app2.sample-ecs-cluster.local:8000"
      }
    },
    {
      name                     = "app2"
      container_image          = "dmenezesgabriel/fastapi-app2:v3"
      container_port           = 8000
      cpu                      = "256"
      memory                   = "512"
      desired_count            = 2
      route_path               = "/app2"
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP1_URL = "http://app1.sample-ecs-cluster.local:8000"
      }
    },
    {
      name                     = "app3"
      container_image          = "dmenezesgabriel/nextjs-app3:v3"
      container_port           = 3000
      cpu                      = "256"
      memory                   = "512"
      desired_count            = 2
      route_path               = "/app3"
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP1_URL = "http://app1.sample-ecs-cluster.local:8000"
      }
    }
  ]
}

module "ecs_services" {
  source = "./ecs-service"
  count  = length(var.apps)

  cluster_id                     = module.ecs_cluster.cluster_id
  vpc_id                         = module.vpc.vpc_id
  app_name                       = var.apps[count.index].name
  container_image                = var.apps[count.index].container_image
  container_port                 = var.apps[count.index].container_port
  cpu                            = var.apps[count.index].cpu
  memory                         = var.apps[count.index].memory
  desired_count                  = var.apps[count.index].desired_count
  subnet_ids                     = module.vpc.public_subnet_ids
  task_execution_role_arn        = module.ecs_cluster.task_execution_role_arn
  ecs_tasks_security_group_id    = module.ecs_cluster.ecs_tasks_security_group_id
  alb_security_group_id          = module.load_balancer.alb_security_group_id
  lb_listener                    = module.load_balancer.lb_listener
  target_group_arn               = module.load_balancer.target_group_arns[count.index]
  environment_variables          = var.apps[count.index].environment_variables
  enable_service_discovery       = true
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  enable_autoscaling             = var.apps[count.index].enable_autoscaling
  autoscaling_min_capacity       = var.apps[count.index].autoscaling_min_capacity
  autoscaling_max_capacity       = var.apps[count.index].autoscaling_max_capacity
  autoscaling_cpu_target         = var.apps[count.index].autoscaling_cpu_target
}

resource "aws_security_group_rule" "allow_inter_service_communication" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = module.ecs_cluster.ecs_tasks_security_group_id
  security_group_id        = module.ecs_cluster.ecs_tasks_security_group_id
  description              = "Allow communication between ECS tasks"
}

# Policies for app1
resource "aws_iam_role_policy" "app1_dynamodb_policy" {
  name = "app1-dynamodb-policy"
  role = module.ecs_services[0].task_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/my-app1-table"
      }
    ]
  })
}

resource "aws_iam_role_policy" "app1_s3_policy" {
  name = "app1-s3-policy"
  role = module.ecs_services[0].task_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-app1-bucket",
          "arn:aws:s3:::my-app1-bucket/"
        ]
      }
    ]
  })
}

# Policies for app2
resource "aws_iam_role_policy" "app2_dynamodb_policy" {
  name = "app2-dynamodb-policy"
  role = module.ecs_services[1].task_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/my-app2-table"
      }
    ]
  })
}

resource "aws_iam_role_policy" "app2_s3_policy" {
  name = "app2-s3-policy"
  role = module.ecs_services[1].task_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::my-app2-bucket",
          "arn:aws:s3:::my-app2-bucket/"
        ]
      }
    ]
  })
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}
