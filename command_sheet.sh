terraform init
#This command sets up the environment.

terraform plan
#This command reports which configuration will be applied.

terraform apply -auto-approve
#This command approves the changes automatically and applies the configuration defined on Terraform files.


# installing docker on vm 
sudo apt-get -y  update
# sudo apt install --yes apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# sudo apt update
sudo apt-get install --yes docker-ce


# installing docker-compose on vm 
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# if ypu need a permision to use docker compose
# sudo chmod +x /usr/local/bin/docker-compose

# build docker
sudo docker build -t mongoapp .

# run docker-compose
sudo docker compose up -d

terraform destroy -auto-approve
#Counteracting the command above, this removes everything created.