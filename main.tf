provider "google" {
 credentials = "${file("credentials.json")}"
 project = var.project_id
 region = "us-central-1"
}

provider "tls" {}