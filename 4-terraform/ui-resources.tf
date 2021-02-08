resource "aws_launch_template" "tf-lt-jp-ramp-up-ui" {
  name                   = "tf-lt-jp-ramp-up-ui"
  image_id               = var.amis[var.region]
  instance_type          = var.ui_instance_type
  key_name               = var.key_name
  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "tf-lt-jp-ramp-up-ui"
      project     = var.project_tag
      responsible = var.responsible_tag
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      project     = var.project_tag
      responsible = var.responsible_tag
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.tf-jp-ramp-up-ui-sg.id]
    delete_on_termination       = true
  }

  user_data = base64encode(data.template_file.userdata-ui.rendered)

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_autoscaling_group" "tf-asg-jp-ramp-up-ui" {
  name = "tf-asg-jp-ramp-up-ui"

  launch_template {
    id      = aws_launch_template.tf-lt-jp-ramp-up-ui.id
    version = "$Latest"
  }

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [var.subnet_id_private_0, var.subnet_id_private_1]
  target_group_arns   = [aws_lb_target_group.tf-ui-tg-jp-ramp-up.arn]

  tag {
    key                 = "project"
    value               = var.project_tag
    propagate_at_launch = false
  }
  tag {
    key                 = "responsible"
    value               = var.responsible_tag
    propagate_at_launch = false
  }
}

resource "aws_security_group" "tf-jp-ramp-up-ui-sg" {
  name        = "tf-jp-ramp-up-ui-sg"
  description = "UI launch template instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "UI port"
    from_port   = var.ui_port
    to_port     = var.ui_port
    protocol    = "tcp"
    security_groups = [aws_security_group.tf-alb-external-sg-jp-ramp-up.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-jp-ramp-up-ui-sg"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

data "template_file" "userdata-ui" {
  template = file("scripts/userdata/ui-userdata.sh")

  vars = {
    repository_url = "https://github.com/jodapomo/movie-analyst-ui"
    repo_name      = "movie-analyst-ui"
    app_port       = var.ui_port
    api_url        = "http://${aws_lb.tf-alb-internal-jp-ramp-up.dns_name}:${var.api_port}"
    user           = "ubuntu"
  }
}
