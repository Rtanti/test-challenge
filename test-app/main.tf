provider "google" {
  credentials = file("./terraform-app.json")
  project     = "devops-challenge-faceit"
  region      = "${var.google_cloud_location}"
}

#variable "google_cloud_project" {
#  type        = string
#  description = "Google Cloud project ID"
#  default     = "devops-challenge-faceit"
#}

#resource "google_service_account" "quickstart_service_account" {
#  account_id   = "quickstart-service-account"
#  display_name = "Quickstart Service Account"
#}

#resource "google_sql_user" "quickstart-service-account" {
#  name     = "quickstart-service-account@devops-challenge-faceit.iam.gserviceaccount.com"
#  instance = google_sql_database_instance.quickstart-instance.name
#  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
#}

resource "google_project_iam_binding" "cloudsql_client_binding" {
  project = "${var.google_cloud_project}"
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:quickstart-service-account@${var.google_cloud_project}.iam.gserviceaccount.com",
  ]
}
#
#resource "google_project_iam_binding" "cloudsql_instanceuser_binding" {
#  project = var.google_cloud_project
#  role    = "roles/cloudsql.instanceUser"
#
#  members = [
#    "serviceAccount:quickstart-service-account@${var.google_cloud_project}.iam.gserviceaccount.com",
#  ]
#}

#resource "google_project_iam_binding" "log_writer_binding" {
#  project = var.google_cloud_project
#  role    = "roles/logging.logWriter"
#
#  members = [
#    "serviceAccount:quickstart-service-account@${var.google_cloud_project}.iam.gserviceaccount.com",
#  ]
#}

resource "google_sql_database_instance" "quickstart-instance" {
  name            = "quickstart-instance"
  database_version = "POSTGRES_13"
  region          = var.google_cloud_location
  project         = "devops-challenge-faceit"

  settings {
    tier              = "db-f1-micro"
    disk_size         = 10
    disk_autoresize   = true
    backup_configuration {
      enabled = true
    }
    database_flags {
      name = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

resource "google_sql_database" "quickstart-db" {
  name     = "quickstart_db"
  instance = google_sql_database_instance.quickstart-instance.name
}

resource "google_sql_user" "postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.quickstart-instance.name
  password = "mysecretpassword"
}

#resource "google_project_service" "vpcaccess-api" {
#  project = "devops-challenge-faceit"
#  service = "vpcaccess.googleapis.com"
#}

#resource "google_cloud_run_service" "cloud_run_service" {
#  name     = "cloud_run_service"
#  location = "${var.google_cloud_location}"
#
#  template {
#    spec {
#      containers {
#        image = "test-app"
#      }
#    }
#  }
#}
