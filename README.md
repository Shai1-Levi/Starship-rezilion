
# Introduction

This is a Terraform configuration that sets up a Docker Container on an existing VPC with a configurable amount of VM instances. 



# Installation
 - How to install terraform you can find at this link - https://www.terraform.io/downloads

 - How to install google cloud sdk shell you can find at this link - https://cloud.google.com/sdk/docs/install-sdk



# Preparations



### GCP account

If you don't have account, you may get a free GCP account. In the setup will be used free f1.micro instances.

https://cloud.google.com/resource-manager/docs/creating-managing-projects


### GCP Credenciatials

Run the following command in gcloud cli -  

    export GOOGLE_APPLICATION_CREDENTIALS={{path}}

That give the ability to connect terraform to GCP.



# VM instance configuration

In the file variables.tf update to your VM instances information.
    project-id, region, instance-image, machine type

Note: the machine type has been choosen to the smallest machine.



# Upload the website using Terraform commands

This command sets up the environment.

    terraform init


After all the configuration files are ready, you can do check if there are no mistakes.

    terraform plan


This command will show either syntax errors or list of resources will be created. After you can run:

    terraform apply


This command will build and run all resources in the *.tf files. If you run this command many times, Terraform will destroy previous instances before creating new ones. That is it. Now you have fully functioned docker container in GCP.

If you want to terminate instances and destroy the configuration you may call:

    terraform destroy



# HTTP and SSH protocols of VM istances

HTTP can be access from any IP.

SSH can be access only from the developer IP.



# URL website

The URL website will print to the shell when the command terraform apply is finish.

In addition, it can the URL can be found also in GCP -> Compute Engine -> VM instance at the section of external IP.
