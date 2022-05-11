
# Introduction

This is a Terraform configuration that sets up a Docker Container on a VM instaces, with a configurable amount of VM instances. 
Those VM's are running in existing VPC.



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

path - the path in your local computer to the google cloud SDK folder.

That give the ability to connect terraform to GCP.




# VM instance configuration

In the file variables.tf update to your VM instances information.
    project-id, region, instance-image, machine type.

Note: the machine type has been choosen to the smallest machine.




# Upload the website using Terraform commands

This command sets up the environment.

    terraform init


After all the configuration files are ready, you can do check if there are no mistakes.

    terraform plan


This command will show either syntax errors or list of resources will be created. After you can run:

    terraform apply

After terraform apply completes, the website URL will be printed to the shell.



This command will build and run all resources in the *.tf files.



 - If you run this command after you changed details in *.tf files, Terraform will update the previous instances or destroy previous instances before creating new ones.

That's it. Now you have fully functioned docker container in GCP.

If you want to terminate instances and destroy the configuration you may call:

    terraform destroy




# How to connect to the VM?

SSH can only be accessed from the developer IP address.

Run the command in shell to connect the VM instancs.

    ssh -i your_ssh_key your_gcp_username@external_IP

 * your_ssh_key can be found in GCP -> Compute Engine -> VM instance -> metadata
 * external_IP - the external_IP of the VM instace



# VM Firewall rules

The google_compute_firewall which is responsibole of the VM instace firewall is allow HTTP trafic from any IP address.


# Cotnainers in use

### webapp container
Container that sending api request to superget api and analyze the data


### nginx container
web container that recive http request and forwad them to webapp container

### vault container
Container that keep secrets as api key

### mongodb container
Container that stored Processed information from webapp

https://github.com/Shai1-Levi/Starship-rezilion/blob/update-readme-and-python-changes/architecture.jpg

# Website URL 

The URL website will print to the shell when the command terraform apply is finish.

In addition, the URL can be found also in GCP -> Compute Engine -> VM instance at the section of external IP.
