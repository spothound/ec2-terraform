terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "random_uuid" "id" {}

provider "aws" {
  profile    = "default"
  region     = "eu-west-3"
  shared_credentials_file = "../.aws/credentials"
}

resource "aws_key_pair" "ansible" {
  key_name   = "key_${random_uuid.id.result}"
  public_key = file("ansible.pub")
}

resource "aws_security_group" "web_server" {
  name        = "sec_group_${random_uuid.id.result}"
  description = "Allow HTTP, HTTPS and SSH traffic"

  # It would be more secure to allow SSH traffic only from private networks but
  # in the interest of simplicity we will keep this unsecure for this exercise

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "terraform"
  }
}

variable "service_name" {
  description = "This is the name of the service that will be deployed on the EC2 instance. For example MQ or simple_web."
}

resource "aws_instance" "app_server" {
  ami           = "ami-00c08ad1a6ca8ca7c"
  instance_type = "t2.micro"
  key_name      = "key_${random_uuid.id.result}"
  tags = {
    Name = "[${var.service_name}] ${random_uuid.id.result}"
  }
  vpc_security_group_ids = [
    "sec_group_${random_uuid.id.result}"
  ]
}

output "address" {
  value = aws_instance.app_server.*.public_dns
}