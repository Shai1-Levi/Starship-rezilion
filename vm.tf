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

resource "google_compute_instance" "default" {
  # count        = "${var.node_count}"
  # name         = "vm-terraform-starship-${count.index}"
  name         = "vm-terraform-starship"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

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

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["http-server", "ssh-rule"]
}

resource "google_compute_firewall" "http-server" {
  # count        = "${var.node_count}"
  # name    = "default-allow-http-terraform-${count.index}"
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  // Allow traffic from my IP to instances with an http-server tag
  source_ranges = ["${var.my_ip}"]
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
  # target_tags = ["vm-terraform-starship-${count.index}"]
  target_tags = ["vm-terraform-starship"]
  source_ranges = ["${var.my_ip}"]
}

resource "google_compute_network" "vpc_network" {
  name = "vm-terraform-starship"
}

output "ip" {
  value = "${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}


resource "null_resource" "cluster" {
  depends_on  =   [google_compute_instance.default]
  
  connection {
    type = "ssh"
    user = "shai4458"
    host = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
    private_key = "${file("~/.ssh/google_compute_engine")}"
    # agent = "false"
    timeout = "5m"
  }  

  provisioner "file" {
    source = "docker-compose.yml"
    destination = "docker-compose.yml"  

  }
  provisioner "remote-exec" {
    inline = [
      # installing docker on vm 
      "sudo apt-get -y  update",
      # sudo apt install --yes apt-transport-https ca-certificates curl gnupg2 software-properties-common
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      # sudo apt update
      "sudo apt-get install --yes docker-ce",


      # installing docker-compose on vm 
      "mkdir -p ~/.docker/cli-plugins/",
      "curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose",
      "chmod +x ~/.docker/cli-plugins/docker-compose",


      # if ypu need a permision to use docker compose
      # sudo chmod +x /usr/local/bin/docker-compose

      # build docker
      # "sudo docker build -t mongoapp .",
      "sudo docker pull dockerid1011shai/website:v1",

      # run docker-compose
      "sudo docker compose up -d"
    ]
  }
}

# Start elastic container
# resource "docker_container" "elastic" {
#     image = "${var.docker-image}"
#     # name = "elastic"
#     # hostname = "elastic"
#     # env = ["SERVICE=elastic", "PROJECT=stage", "ENVIRONMENT=operations"]
#     # restart= "no"
#     must_run="true"
# }


# resource "google_compute_instance" "test-build" {
#   # project                   = "artifactory-staging"
#   # name                      = "file-transfer-test"
#   # machine_type              = "n1-standard-2"
#   # zone = "europe-west3-b"
#   allow_stopping_for_update = "true"

  
#   network_interface {
#     subnetwork         = "default"
#     subnetwork_project = "artifactory-staging"
#     access_config      = {}
#   }
#   metadata {
#     ssh-keys = "shai4458:${file("credentials.json")}"
#   }
# }

  # provisioner "local-exec" {
  #   command = "echo $FOO >> env_vars.txt"

  #   environment = {
  #     FOO = "tls_private_key.rsa-4096-example.private_key_pem >> google_compute_engine.pub"
  #   }
  # }