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
variable "google_cloud_app_service_account" {
  type        = string
  description = "Google Cloud App Service Account to be used"
  default     = "quickstart-service-account"
}

variable "project_iam_policies" {
  type    = list(string)
  default = [
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
    "roles/logging.logWriter",
    "roles/container.clusterViewer"
  ]
}

#variable "enabled_apis" {
#  type    = list(string)
#  default = [
#    "compute.googleapis.com",
#    "storage.googleapis.com",
#    "pubsub.googleapis.com",
#    "logging.googleapis.com",
#    "cloudfunctions.googleapis.com"
#]
#}
