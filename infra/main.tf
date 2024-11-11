provider "aws" {
  region = "us-east-1"
}

locals {
  ecs_cluster_name   = "sample-ecs-cluster"
  elb_name           = "ecs-alb"
  load_balancer_type = "application"
  apps = [
    {
      name            = "app1"
      container_image = "dmenezesgabriel/fastapi-app1:v3"
      container_port  = 8000
      cpu             = "256"
      memory          = "512"
      desired_count   = 2

      lb_target_group_config = {
        protocol    = "HTTP",
        target_type = "ip",
        health_check = {
          path                = "/app1/health",
          healthy_threshold   = 2,
          unhealthy_threshold = 10,
          timeout             = 60,
          interval            = 300,
          matcher             = "200"
        }
      }
      lb_listener_config = {
        listener_arn = aws_lb_listener.front_end.arn
        priority     = 100
        path_pattern = ["/app1*"]
      }
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP2_URL     = "http://app2.${local.ecs_cluster_name}.local:3000"
        ALB_DNS_NAME = module.load_balancer.elb_dns_name
      }
    },
    {
      name            = "app2"
      container_image = "dmenezesgabriel/fastify-app2:v2"
      container_port  = 3000
      cpu             = "256"
      memory          = "512"
      desired_count   = 2
      lb_target_group_config = {
        protocol    = "HTTP",
        target_type = "ip",
        health_check = {
          path                = "/app2/health",
          healthy_threshold   = 2,
          unhealthy_threshold = 10,
          timeout             = 60,
          interval            = 300,
          matcher             = "200"
        }
      }
      lb_listener_config = {
        listener_arn = aws_lb_listener.front_end.arn
        priority     = 200
        path_pattern = ["/app2*"]
      }
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP1_URL     = "http://app1.${local.ecs_cluster_name}.local:8000"
        ALB_DNS_NAME = module.load_balancer.elb_dns_name
      }
    },
    {
      name            = "app3"
      container_image = "dmenezesgabriel/nextjs-app3:v3"
      container_port  = 3000
      cpu             = "256"
      memory          = "512"
      desired_count   = 2
      lb_target_group_config = {
        protocol    = "HTTP",
        target_type = "ip",
        health_check = {
          path                = "/app3/health",
          healthy_threshold   = 2,
          unhealthy_threshold = 10,
          timeout             = 60,
          interval            = 300,
          matcher             = "200"
        }
      }
      lb_listener_config = {
        listener_arn = aws_lb_listener.front_end.arn
        priority     = 300
        path_pattern = ["/app3*"]
      }
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP1_URL     = "http://app1.${local.ecs_cluster_name}.local:8000"
        ALB_DNS_NAME = module.load_balancer.elb_dns_name
      }
    },
    {
      name            = "app4"
      container_image = "dmenezesgabriel/nextjs-app4:v3"
      container_port  = 80
      cpu             = "256"
      memory          = "512"
      desired_count   = 2
      lb_target_group_config = {
        protocol    = "HTTP",
        target_type = "ip",
        health_check = {
          path                = "/app4/health",
          healthy_threshold   = 2,
          unhealthy_threshold = 10,
          timeout             = 60,
          interval            = 300,
          matcher             = "200"
        }
      }
      lb_listener_config = {
        listener_arn = aws_lb_listener.front_end.arn
        priority     = 400
        path_pattern = ["/app4*"]
      }
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 5
      autoscaling_cpu_target   = 70
      environment_variables = {
        APP1_URL     = "http://app1.${local.ecs_cluster_name}.local:8000"
        ALB_DNS_NAME = module.load_balancer.elb_dns_name
      }
    },
  ]
}

# security groups
resource "aws_security_group" "alb" {
  name        = "ecs-alb-sg"
  description = "Allow inbound traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [
      {
        protocol    = "tcp",
        from_port   = 80,
        to_port     = 80,
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        protocol    = "tcp",
        from_port   = 443,
        to_port     = 443,
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [module.vpc]
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.ecs_cluster_name}-ecs-tasks-sg"
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = module.vpc.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [module.vpc]
}

resource "aws_security_group_rule" "allow_from_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_tasks.id
  description              = "Allow inbound traffic from ALB to ECS tasks"

  depends_on = [aws_security_group.alb, aws_security_group.ecs_tasks]
}

resource "aws_security_group_rule" "allow_inter_service_communication" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id        = aws_security_group.ecs_tasks.id
  description              = "Allow communication between ECS tasks"

  depends_on = [aws_security_group.ecs_tasks]
}

# Modules
module "vpc" {
  source                           = "./vpc"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
}

module "load_balancer" {
  source             = "./load-balancer"
  elb_name           = local.elb_name
  load_balancer_type = local.load_balancer_type
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  depends_on = [module.vpc, aws_security_group.alb]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = module.load_balancer.elb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, World!"
      status_code  = "200"
    }
  }

  depends_on = [module.load_balancer]
}

module "ecs_cluster" {
  source       = "./ecs-cluster"
  cluster_name = local.ecs_cluster_name
  vpc_id       = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "ecs_services" {
  source = "./ecs-service"
  count  = length(local.apps)

  cluster_id                     = module.ecs_cluster.cluster_id
  vpc_id                         = module.vpc.vpc_id
  app_name                       = local.apps[count.index].name
  container_image                = local.apps[count.index].container_image
  container_port                 = local.apps[count.index].container_port
  cpu                            = local.apps[count.index].cpu
  memory                         = local.apps[count.index].memory
  desired_count                  = local.apps[count.index].desired_count
  subnet_ids                     = module.vpc.public_subnet_ids
  security_groups                = [aws_security_group.ecs_tasks.id]
  alb_security_group_id          = aws_security_group.alb.id
  lb_target_group_config         = local.apps[count.index].lb_target_group_config
  lb_listener_config             = local.apps[count.index].lb_listener_config
  environment_variables          = local.apps[count.index].environment_variables
  enable_service_discovery       = true
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  enable_autoscaling             = local.apps[count.index].enable_autoscaling
  autoscaling_min_capacity       = local.apps[count.index].autoscaling_min_capacity
  autoscaling_max_capacity       = local.apps[count.index].autoscaling_max_capacity
  autoscaling_cpu_target         = local.apps[count.index].autoscaling_cpu_target
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
  value = module.load_balancer.elb_dns_name
}
