variable "google_cloud_project" {
  type        = string
  description = "Google Cloud project ID"
  default     = "devops-challenge-faceit"
}

variable "google_cloud_location" {
  type        = string
  description = "Google Cloud location"
  default     = "europe-west1"
}

variable "google_cloud_app_name" {
  type        = string
  description = "Google Cloud application name"
  default     = "test-app-beb"
}
