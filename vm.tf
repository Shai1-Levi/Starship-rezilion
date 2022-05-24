locals {
  project_id          = "elevated-valve-317623"
  network          =  "default"
  image            =  var.vm-instance-image 
  user_ssh         =   "${split("@", data.google_client_openid_userinfo.me.email)[0]}"
  web_servers = {
    vm-terraform-starship--000-staging = {
      machine_type = var.machine_type
      zone         = "us-central1-a"
    }
    # To add more servers just copy the above and change the details
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = ".ssh/google_compute_engine"
  file_permission = "0400"
}

data "http" "devip" {
  url = "http://ipv4.icanhazip.com"
}

data "google_client_openid_userinfo" "me" {}

resource "google_compute_firewall" "http-server" {
  project = local.project_id
  name    = "default-allow-http-terraform"
  network = local.network

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  priority = 1000

  // Allow traffic from all IP to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] 
}

resource "google_compute_firewall" "nginx-rule" {
  project = local.project_id
  name    = "default-allow-vault-terraform"
  network = local.network

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  priority = 1000

  // Allow traffic from all IP to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nginx-rule"] 
}

resource "google_compute_firewall" "ssh-rule" {
  project = local.project_id
  name = "vm-terraform-starship"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  // Allow traffic from my IP to instances with an http-server tag
  target_tags = ["vm-terraform-starship"]
  source_ranges = ["${chomp(data.http.devip.body)}/32"]
}

resource "google_compute_network" "vpc_network" {
  name = "vm-terraform-starship"
}

resource "google_compute_instance" "default" {
  for_each              = local.web_servers
  name                  = each.key
  machine_type          = each.value.machine_type
  zone                  = each.value.zone 
  project               = local.project_id
  tags = ["http-server", "ssh-rule", "nginx-rule"] // Apply the firewall rule to allow external IPs to access this instance

  boot_disk {
    initialize_params {
      image = local.image
    }
  }

  network_interface {
    network = local.network

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${local.user_ssh}:${tls_private_key.ssh_key.public_key_openssh}"
  }

  connection {
    type        = "ssh"
    user        = local.user_ssh
    host        = self.network_interface.0.access_config.0.nat_ip
    private_key = "${file("~/.ssh/google_compute_engine")}"
    timeout     = "5m"
  }  

  provisioner "file"{
    source      = "docker-compose.yml"
    destination = "docker-compose.yml"  
  }

  provisioner "file"{
    source      = "default.conf"
    destination = "default.conf"  
  }

  provisioner "file"{
    source      = "index.html"
    destination = "index.html"  
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y  update",

      # installing docker-compose on vm 
      "mkdir -p ~/.docker/cli-plugins/",
      "curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose",
      "chmod +x ~/.docker/cli-plugins/docker-compose",

       # installing docker on vm 
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",

      # sudo apt update
      "sudo apt-get install --yes docker-ce",

      # create bridge between to containers
      "sudo docker network create web-bridge",

      # pull vault container from docker hub
      "sudo docker pull vault",
      "sudo docker run -p 8200:8200 --cap-add=IPC_LOCK -d --name vault --net web-bridge -e 'VAULT_DEV_ROOT_TOKEN_ID=superget-api-key' vault",

     

      # run docker-compose
      "sudo docker compose up -d",
      # "sudo docker rename shai4458-web-1 webapp",
      "sudo docker network connect web-bridge webapp",
      "sudo docker network connect shai4458_default webapp",

      #install trivy
      # "sudo apt-get install wget apt-transport-https gnupg lsb-release",
      # "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -",
      # "echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list",
      # "sudo apt-get update",
      # "sudo apt-get install trivy",
      # "trivy -d image -f json -o trivyoutput.json nginx"
    ]
  }
}
