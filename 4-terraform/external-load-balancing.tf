resource "aws_lb" "tf-alb-external-jp-ramp-up" {
  name               = "tf-alb-external-jp-ramp-up"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf-alb-external-sg-jp-ramp-up.id]
  subnets            = [var.subnet_id_public_0, var.subnet_id_public_1]

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_security_group" "tf-alb-external-sg-jp-ramp-up" {
  name        = "tf-alb-external-sg-jp-ramp-up"
  description = "External load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP port"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-alb-external-sg-jp-ramp-up"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_lb_listener" "ui-listener" {
  load_balancer_arn = aws_lb.tf-alb-external-jp-ramp-up.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-ui-tg-jp-ramp-up.arn
  }
}

resource "aws_lb_target_group" "tf-ui-tg-jp-ramp-up" {
  name     = "tf-ui-tg-jp-ramp-up"
  port     = var.ui_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}
