variable "node_count" {
  type = number
  default = "2"
}

variable "gce_ssh_pub_key_file" {
  default = "google_compute_engine.pub"
}

variable "project_id" {
  type        = string
  description = "name of the project_id on gcp"
  default     = "elevated-valve-317623"
}

variable "vm-instance-image" {
  type        = string
  description = "instance machine type"
  default     = "ubuntu-1804-bionic-v20220331a" 
}

variable "machine_type" {
  type = string
  description = "The kind of the machine type to create"
  default = "f1-micro"
  
}


