provider "google" {
  credentials = file("./terraform-app.json")
  project     = "${var.google_cloud_project}"
  region      = "${var.google_cloud_location}"
  alias       = "devops-app-sa"
}

#resource "google_project_service" "enabled_apis" {
#  for_each = toset(var.enabled_apis)
#  project = var.google_cloud_project
#  service = each.value
#}

resource "google_service_account" "test_service_account" {
  account_id = var.google_cloud_app_service_account
  display_name = var.google_cloud_app_service_account
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.test_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

#resource "google_project_iam_member" "project_iam_binding" {
#  provider = google.gcp-quickstart-service-account
#  project = var.google_cloud_project
#  role    = "roles/iam.serviceAccountUser"
#  member  ="serviceAccount:${var.google_cloud_app_service_account}@${var.google_cloud_project}.iam.gserviceaccount.com"
#}
#resource "google_project_iam_member" "project_iam_binding_cluster" {
#  provider = google.gcp-quickstart-service-account
#  project = var.google_cloud_project
#  role    = "roles/container.clusterViewer"
#  member  ="serviceAccount:${var.google_cloud_app_service_account}@${var.google_cloud_project}.iam.gserviceaccount.com"
#}
#variable "google_cloud_project" {
#  type        = string
#  description = "Google Cloud project ID"
#  default     = "devops-challenge-faceit"
#}


#resource "google_sql_user" "quickstart-service-account" {
#  name     = "quickstart-service-account@devops-challenge-faceit.iam.gserviceaccount.com"
#  instance = google_sql_database_instance.quickstart-instance.name
#  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
#}

resource "google_sql_database_instance" "quickstart-instance" {
  name            = "quickstart-instance"
  database_version = "POSTGRES_13"
  region          = var.google_cloud_location
  project         = "devops-challenge-faceit"
  deletion_protection = false

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

resource "null_resource" "create_sa_keys" {
  provisioner "local-exec" {
    command = <<-EOT
    gcloud iam service-accounts keys create ~/key.json
    --iam-account="${google_service_account.test_service_account.email}"
    EOT
  }
  depends_on = [google_service_account.test_service_account]
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
