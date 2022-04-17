variable "project_id" {
  type        = string
  description = "name of the project_id on gcp console"
  default     = "elevated-valve-317623"
}
variable "region" {
  type        = string
  description = "the ragion the project is loacted"
  default     = "us-central-1"
}

variable "vm-instance-image" {
  type        = string
  description = "instance machine type"
  default     = "ubuntu-1804-bionic-v20220331a" 
}

variable "machine_type" {
  type        = string
  description = "The kind of the machine type to create"
  default     = "f1-micro"
}




