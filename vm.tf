provider "tls" {
  // no config needed
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = ".ssh/google_compute_engine"
  file_permission = "0400"
}

resource "google_compute_firewall" "http-server" {
  # count        = "${var.node_count}"
  # name    = "default-allow-http-terraform-${count.index}"
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  priority = 1000

  // Allow traffic from my IP to instances with an http-server tag
  source_ranges = ["${var.my_ip}"]
  target_tags   = ["http-server"] #"web"'
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
  # target_tags = ["vm-terraform-starship-${count.index}"]
  target_tags = ["vm-terraform-starship"]
  source_ranges = ["${var.my_ip}"]
}

resource "google_compute_network" "vpc_network" {
  name = "vm-terraform-starship"
}


resource "google_compute_instance" "default" {
  # count        = "${var.node_count}"
  # name         = "vm-terraform-starship-${count.index}"
  name         = "vm-terraform-starship"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags = ["http-server", "ssh-rule"] // Apply the firewall rule to allow external IPs to access this instance

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20220331a"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${tls_private_key.ssh.public_key_openssh}"
  }
}

resource "null_resource" "cluster" {
  depends_on  =   [google_compute_instance.default]
  
  connection {
    type = "ssh"
    user = "shai4458"
    host = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
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