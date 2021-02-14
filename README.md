# Finpy IaC Project

This project is meant to be a training exercise in utilizing IaC concepts with Terraform (AWS Provider) and Ansible for a full deployment of an app.

Example app utilized: [Finpy](https://github.com/GabhenDM/finpy-ci)

## Infrastructure Setup

- &check; AWS VPC Separated into 2 private and public subnets (each on it's own AZ)
- &check; Application Load Balancer Forwarding traffic
- &check; 2 EC2 Instances running the Back-end of API
- &check; Security Group for everything
- &check; NAT Gateway for outbound internet traffic (with EIP)
- &check; Internet gateway for inbound traffic to public subnet
- &check; Bastion host for private subnet SSH access


## Todo:
- &cross; Output variables after terraform apply
- &cross; Terraform vars (ikr)
- &cross; S3 Bucket for ALB Access Logs
- &cross; Autoscaling group for EC2 instances
