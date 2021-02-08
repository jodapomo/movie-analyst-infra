resource "aws_lb" "tf-alb-internal-jp-ramp-up" {
  name               = "tf-alb-internal-jp-ramp-up"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf-alb-internal-sg-jp-ramp-up.id]
  subnets            = [var.subnet_id_private_0, var.subnet_id_private_1]

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_security_group" "tf-alb-internal-sg-jp-ramp-up" {
  name        = "tf-alb-internal-sg-jp-ramp-up"
  description = "Internal load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "API port"
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "tcp"
    security_groups = [aws_security_group.tf-jp-ramp-up-ui-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-alb-internal-sg-jp-ramp-up"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_lb_listener" "api-listener" {
  load_balancer_arn = aws_lb.tf-alb-internal-jp-ramp-up.arn
  port              = var.api_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-api-tg-jp-ramp-up.arn
  }
}

resource "aws_lb_target_group" "tf-api-tg-jp-ramp-up" {
  name     = "tf-api-tg-jp-ramp-up"
  port     = var.api_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}
