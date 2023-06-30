provider "google" {
  credentials = file("./web-app.json")
  project     = "devops-challenge-faceit"
  region      = "${var.google_cloud_location}"
  alias       = "gcp-quickstart-service-account"
}

resource "time_sleep" "delay" {
  depends_on = [ google_sql_user.postgres ]

  create_duration = "30s"  # Adjust the duration as needed
}

resource "google_cloud_run_service" "test_app_beb" {
  name     = "test-app-beb"
  location = "${var.google_cloud_location}"
  depends_on = [ time_sleep.delay ]

  template {
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = "devops-challenge-faceit:${var.google_cloud_location}:quickstart-instance"
      }
    }
    spec {
      containers {
        image = "gcr.io/devops-challenge-faceit/test-app-beb"
          # You can set individual environment variables
        env {
          name  = "INSTANCE_CONNECTION_NAME"
          value = "devops-challenge-faceit:${var.google_cloud_location}:quickstart-instance"
        }

        env {
          name  = "POSTGRESQL_USER"
          value = "postgres"
        }

        env {
          name  = "POSTGRESQL_DBNAME"
          value = "quickstart_db"
        }

        env {
          name  = "POSTGRESQL_HOST"
          value = "/cloudsql/devops-challenge-faceit:${var.google_cloud_location}:quickstart-instance"
        }

        env {
          name  = "POSTGRESQL_PASS"
          value = "mysecretpassword"
        }


      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true

}

data "google_iam_policy" "noauth" {
  provider = google.gcp-quickstart-service-account
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  provider    = google.gcp-quickstart-service-account
  location    = google_cloud_run_service.test_app_beb.location
  project     = google_cloud_run_service.test_app_beb.project
  service     = google_cloud_run_service.test_app_beb.name
  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on = [ google_cloud_run_service.test_app_beb ]
}

resource "google_project_service" "enable_gke_api" {
  project = google_cloud_run_service.test_app_beb.project
  service = "container.googleapis.com"
  depends_on = [ google_cloud_run_service.test_app_beb ]
}

#resource "google_cloud_run_service_iam_policy" "test_app_beb_iam_policy" {
#  service = google_cloud_run_service.test_app_beb.name
#
#  policy_data = jsonencode({
#    bindings = [
#      {
#        role    = "roles/run.invoker"
#        members = ["allUsers"]
#      }
#    ]
#  })
#}

#resource "google_cloud_run_service_iam_member" "run_all_users" {
#  service  = google_cloud_run_service.test_app_beb.name
#  location = google_cloud_run_service.test_app_beb.location
#  role     = "roles/run.invoker"
#  member   = "allUsers"
#}

# Return service URL
output "url" {
  value = "${google_cloud_run_service.test_app_beb.status[0].url}"
}
