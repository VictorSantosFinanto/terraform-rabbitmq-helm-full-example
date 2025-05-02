variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default = "fnt-master"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "credentials_file" {
    description = "GCP Credential File"
    default = "../auth.json"
}
