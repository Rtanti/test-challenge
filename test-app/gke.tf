resource "google_project_service" "workload_identity_api" {
  project = var.google_cloud_project
  service = "iam.googleapis.com"
}

#resource "google_workload_identity_pool" "my_pool" {
#  #provider = google
#  location = var.google_cloud_location
#  display_name = "my-workload-identity-pool"
#}


#resource "google_iam_workload_identity_pool" "iam_identity_pool" {
#  provider = google-beta
#  project = var.google_cloud_project
#  display_name = "IAM Identity Pool"
#  description = "IAM IDentity pool"
#
#  disabled = true
#}


resource "google_container_cluster" "cluster" {
  name     = "test-app-beb-cluster"
  location = "${var.google_cloud_location}"

  initial_node_count = 1

  node_config {
    machine_type = "n1-standard-2"
    disk_size_gb = 10
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = true
    }
  }
}


#data "google_container_cluster" "cluster" {
#  name     = "test-app-beb-cluster"
#  location = "${var.google_cloud_location}"
#
#}

data "google_container_cluster" "cluster" {
  name     = google_container_cluster.cluster.name
  location = google_container_cluster.cluster.location
}


#resource "kubernetes_config_map" "cluster_credentials" {
#  metadata {
#    name = "cluster-credentials"
#  }
#
#  data = {
#    "kubeconfig" = data.google_container_cluster.cluster.master_
#  }
#}

resource "null_resource" "get_cluster_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${data.google_container_cluster.cluster.name} --region ${data.google_container_cluster.cluster.location}"
  }

  depends_on = [google_container_cluster.cluster]
}
