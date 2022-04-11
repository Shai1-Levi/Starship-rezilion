# variable "node_count" {
#   type = number
#   default = "2"
# }

variable "docker-image" {
  type        = string
  description = "name of the docker image to deploy"
  default     = "dockerid1011shai/website:v1"
}

variable "my_ip" {
  type        = string
  description = "developer ip"
  default     = "82.114.45.72/32" #"84.110.38.122"
}

variable "gce_ssh_user" {
  default = "shai4458"
}
variable "gce_ssh_pub_key_file" {
  default = "google_compute_engine.pub"
}

