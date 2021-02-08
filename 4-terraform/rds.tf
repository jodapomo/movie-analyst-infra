resource "aws_db_instance" "tf-moviedb-jp-ramp-up" {
  identifier           = "tf-moviedb-jp-ramp-up"
  engine               = "mysql"
  engine_version       = "5.7.26"
  parameter_group_name = "default.mysql5.7"
  instance_class       = "db.t2.micro"
  auto_minor_version_upgrade = false
  copy_tags_to_snapshot  = false
  skip_final_snapshot = true

  allocated_storage    = 20
  storage_type         = "gp2"

  username             = var.db_username
  password             = var.db_password
  name                 = var.db_name

  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.tf-moviedb-sng-jp-ramp-up.name
  vpc_security_group_ids  = [aws_security_group.tf-db-sg-jp-ramp-up.id]
  port                    = var.db_port

  tags = {
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_security_group" "tf-db-sg-jp-ramp-up" {
  name        = "tf-db-sg-jp-ramp-up"
  description = "RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "DB port"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    security_groups = [aws_security_group.tf-jp-ramp-up-api-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-db-sg-jp-ramp-up"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_db_subnet_group" "tf-moviedb-sng-jp-ramp-up" {
  name       = "tf-moviedb-sng-jp-ramp-up"
  subnet_ids = [var.subnet_id_private_0, var.subnet_id_private_1]

  tags = {
    Name = "tf-moviedb-sng-jp-ramp-up"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}
