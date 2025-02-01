
variable "name_prefix" {
  type = string
}

variable "gcloud_project" {
  type = string
}

variable "gcloud_region" {
  type = string
}

variable "kubernetes_endpoint" {
  type = string
}

variable "kubernetes_token" {
  type = string
  sensitive = true
}