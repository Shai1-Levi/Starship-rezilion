# Starship-rezilion

This repository is a small website that use the superget API.

To use this repository follow the actions:

Create a project in Google Cloud Platform - 

https://cloud.google.com/resource-manager/docs/creating-managing-projects

Download Terraform -

Choose your os before downloading the Terraform

link: https://www.terraform.io/downloads

Change the variables in variable.tf to your details: project-id, region, instance-image, machine type

Note: the machine type has been choosen to the smallest machine.


This command sets up the environment.
 - terraform init

This command reports which configuration will be applied.
 - terraform plan

This command approves the changes automatically and applies the configuration defined on Terraform files.
 - terraform apply -auto-approve

This command destroy the environment
 - terraform destroy

# This repository has an access via HTTP and SSH protocols.
HTTP can be access from any IP.
SSH can be access only from the developer IP.

# URL website
The URL website will print to the shell when the command terraform apply is finish.
In addition, it can the URL can be found also in GCP -> Compute Engine -> VM instance at the section of external IP.
