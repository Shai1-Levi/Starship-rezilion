locals {
  project_id       =  var.project_id 
  network          =  var.network 
  image            =  var.vm-instance-image 
  user_ssh         =  var.user_name 
  web_servers = {
    vm-terraform-starship--000-staging = {
      machine_type = "f1-micro"
      zone         = "us-central1-a"
    }
    # vm-terraform-starship--001-staging = {
    #   machine_type = "f1-micro"
    #   zone         = "us-central1-a"
    # }
  }
}

provider "tls" {
  // no config needed
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = var.ssh_fine_name
  file_permission = "0400"
}

data "http" "devip" {
  url = "http://ipv4.icanhazip.com"
}

resource "google_compute_firewall" "http-server" {
  # count        = "${var.node_count}"
  # name    = "default-allow-http-terraform-${count.index}"
  name    = "default-allow-http-terraform"
  network = local.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  priority = 1000

  // Allow traffic from my IP to instances with an http-server tag
  source_ranges = ["${chomp(data.http.devip.body)}/32"]
  target_tags   = ["http-server"] 
}

resource "google_compute_firewall" "ssh-rule" {
  # count        = "${var.node_count}"
  # name = "vm-terraform-starship-${count.index}"
  name = "vm-terraform-starship"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["vm-terraform-starship"]
  source_ranges = ["${chomp(data.http.devip.body)}/32"]
}

resource "google_compute_network" "vpc_network" {
  name = "vm-terraform-starship"
}

resource "google_compute_instance" "default" {
  # count        = "${var.node_count}"
  # name         = "vm-terraform-starship-${count.index}"
  for_each              = local.web_servers
  name                  = each.key
  machine_type          = each.value.machine_type
  zone                  = each.value.zone 
  tags = ["http-server", "ssh-rule"] // Apply the firewall rule to allow external IPs to access this instance

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
    ssh-keys = "${var.gce_ssh_user}:${tls_private_key.ssh.public_key_openssh}"
  }

  connection {
    type = "ssh"
    user = local.user_ssh
    host = self.network_interface.0.access_config.0.nat_ip
    private_key = "${file("~/.ssh/google_compute_engine")}"
    timeout = "5m"
  }  

  provisioner "file"{
    source = "getPrice.py"
    destination = "getPrice.py"  
  }

  provisioner "file"{
    source = "docker-compose.yml"
    destination = "docker-compose.yml"  
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

      # build docker
      "sudo docker pull dockerid1011shai/website:v1",

      # run docker-compose
      "sudo docker compose up -d"
    ]
  }
}