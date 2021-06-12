# ec2-terraform

DevOps Pipeline to deploy docker services on AWS EC2 instances using Terraform and Ansible.

## Requirements
- Ansible
- Terraform
- AWS account with permissions to create EC2 resources
- RSA key pair for the EC2 instances


## Considerations

1. The Terraform configuration is defined in a single file to keep simplicity. It could be split in different files.
2. For each deployment, a security group and a key pair is created. That makes sense if each instance has his own key pair and security group configuration, which is not the case on this example. Maybe there would be interesting to create a single shared resource but this would increase the complexity of this deployment and we've decided to keep it simple.