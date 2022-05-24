variable "gcp_credentials" {
  type        = string
  description = "path to your credentials"  
}

variable "gcp_project_id" {
  type        = string
  description = "name of the project_id on gcp console"
}

variable "gcp_region" {
  type        = string
  description = "the ragion the project is loacted"
}

variable "gcp_zones" {
  type        = list(string)
  description = "list of zones to GKE cluster"
}

variable "gke_cluster_name" {
  type        = string
  description = "your gke cluster name"
}

variable "gke_vm-instance-image" {
  type        = string
  description = "instance machine type"
}

variable "gke_machine_type" {
  type        = string
  description = "The kind of the machine type to create"
}

variable "gke_network" {
  type        = string
  description = "name of the gke network"  
}
variable "gke_subnetwork" {
  type        = string
  description = "name of the gke sub network"  
}

variable "gke_service_account" {
    type        = string
    description = "GKE servive Account Name"  
}

