terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "jenkins_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = filebase64("${path.module}/userdata.sh")

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "Jenkins-Server"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "JENKINS_IP=${self.public_ip}" > ${path.module}/../../.env
    EOT
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, Jenkins, and Docker"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375 # Docker API
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_server.public_ip}:8080"
}