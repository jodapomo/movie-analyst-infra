resource "aws_instance" "tf-jp-ramp-up-jenkins" {
  ami                         = var.amis[var.region]
  instance_type               = var.jenkins_instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id_public_0
  vpc_security_group_ids      = [aws_security_group.tf-jp-ramp-up-jenkins-sg.id]

  user_data = base64encode(data.template_file.userdata-jenkins.rendered)

  tags = {
    Name        = "tf-jp-ramp-up-jenkins"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

resource "aws_security_group" "tf-jp-ramp-up-jenkins-sg" {
  name        = "tf-jp-ramp-up-jenkins-sg"
  description = "Jenkins launch template instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins port"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH port"
    from_port   = 22
    to_port     = 22
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
    Name        = "tf-jp-ramp-up-jenkins-sg"
    project     = var.project_tag
    responsible = var.responsible_tag
  }
}

data "template_file" "userdata-jenkins" {
  template = file("scripts/userdata.sh")

  vars = {
    jenkins_port = var.jenkins_port
    user         = "ubuntu"
  }
}
