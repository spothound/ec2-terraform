# ec2-terraform

DevOps Pipeline to deploy docker services on AWS EC2 instances using Terraform and Ansible.

## Requirements
- Ansible
- Terraform
- AWS account with permissions to create EC2 resources
- RSA key pair for the EC2 instances

## Considerations

This pipeline is executed through an ansible playbook which will use Terraform to deploy EC2 instances (as well as other resources such as custom security groups and key pairs) in AWS, provision them and launch dockerized services on them.