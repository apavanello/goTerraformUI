provider "aws" {
  region = "us-west-2"
}

module "database" {
  source  = "./modules/db"
  db_name = "myappdb"
}

module "app_server" {
  source      = "./modules/app"
  db_endpoint = module.database.endpoint
}

resource "aws_lb" "front_end" {
  name               = "front-end-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-123", "subnet-456"]
}

resource "aws_security_group" "lb_sg" {
  name = "lb-sg"
}

output "lb_dns" {
  value = aws_lb.front_end.dns_name
}
