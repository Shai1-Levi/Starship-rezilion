provider "google" {
 credentials = "${file("credentials.json")}"
 project = "elevated-valve-317623"
 region = "us-central-1"
}

provider "tls" {}