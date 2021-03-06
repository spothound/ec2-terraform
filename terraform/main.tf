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
  shared_credentials_file = ".aws/credentials"
}

resource "aws_key_pair" "ansible" {
  key_name   = "key_${random_uuid.id.result}"
  public_key = file("ec2_key.pub")
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
    description = "HTTP"
    from_port   = var.port
    to_port     = var.port
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

variable "deploy_id" {
  description = "This is the human-readable id for this deployment. It may content the Jenkins build number if was launched from Jenkins."
}

variable "port" {
  description = "This is the port that will be open in the network so others could communicate."
}

resource "aws_instance" "app_server" {
  ami           = "ami-00c08ad1a6ca8ca7c"
  instance_type = "t2.micro"
  key_name      = "key_${random_uuid.id.result}"
  tags = {
    Name = "[${var.service_name}][${var.deploy_id}] ${random_uuid.id.result}"
  }
  vpc_security_group_ids = [
    "sec_group_${random_uuid.id.result}"
  ]
}

output "address" {
  value = aws_instance.app_server.*.public_dns
}