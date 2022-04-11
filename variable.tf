variable "node_count" {
  type = number
  default = "2"
}

variable "gce_ssh_user" {
  default = "shai4458"
}
variable "gce_ssh_pub_key_file" {
  default = "google_compute_engine.pub"
}

variable "project_id" {
  type        = string
  description = "name of the project_id on gcp"
  default     = "elevated-valve-317623"
}

variable "network" {
  type        = string
  description = "name of your network"
  default     = "default"
}

variable "vm-instance-image" {
  type        = string
  description = "instance machine type"
  default     = "ubuntu-1804-bionic-v20220331a" 
}

variable "user_name" {
  type        = string
  description = "instance machine type"
  default     = "shai4458"
}

variable "ssh_fine_name" {
  type        = string
  description = "file name that will save localy on your computer"
  default     = ".ssh/google_compute_engine"
}


