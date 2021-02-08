resource "aws_launch_template" "tf-lt-jp-ramp-up-api" {
  name                   = "tf-lt-jp-ramp-up-api"
  image_id               = var.amis[var.region]
  instance_type          = var.api_instance_type
  key_name               = var.key_name
  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "tf-lt-jp-ramp-up-api"
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
    security_groups             = [aws_security_group.tf-jp-ramp-up-api-sg.id]
    delete_on_termination       = true
  }

  user_data = base64encode(data.template_file.userdata-api.rendered)

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_autoscaling_group" "tf-asg-jp-ramp-up-api" {
  name = "tf-asg-jp-ramp-up-api"

  launch_template {
    id      = aws_launch_template.tf-lt-jp-ramp-up-api.id
    version = "$Latest"
  }

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [var.subnet_id_private_0, var.subnet_id_private_1]
  target_group_arns   = [aws_lb_target_group.tf-api-tg-jp-ramp-up.arn]

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

resource "aws_security_group" "tf-jp-ramp-up-api-sg" {
  name        = "tf-jp-ramp-up-api-sg"
  description = "API launch template instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "API port"
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "tcp"
    security_groups = [aws_security_group.tf-alb-internal-sg-jp-ramp-up.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-jp-ramp-up-api-sg"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

data "template_file" "userdata-api" {
  template = file("scripts/userdata/api-userdata.sh")

  vars = {
    repository_url = "https://github.com/jodapomo/movie-analyst-api"
    repo_name      = "movie-analyst-api"
    api_port       = var.api_port
    mysql_host     = aws_db_instance.tf-moviedb-jp-ramp-up.address 
    mysql_port     = var.db_port
    mysql_user     = var.db_username
    mysql_password = var.db_password
    mysql_db_name  = var.db_name
    user           = "ubuntu"
  }
}
