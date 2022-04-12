# Starship-rezilion

This repository is a small website that use the superget API.

To use this repository follow the actions:

Create a User in DockerHub - 

https://hub.docker.com

Download Terraform -

Choose your os before downloading the Terraform

link: https://www.terraform.io/downloads

Change the variables in variable.tf to your details: project-id, region, instance-image, machine type

Note: the machine type has been choosen to the smallest machine.


This command sets up the environment.
terraform init

This command reports which configuration will be applied.
terraform plan

This command approves the changes automatically and applies the configuration defined on Terraform files.
terraform apply 

This command destroy the environment
terraform destroy

# This repository has an access via HTTP and SSH protocols.
HTTP can be access from any IP.
SSH can be access only from the developer IP.