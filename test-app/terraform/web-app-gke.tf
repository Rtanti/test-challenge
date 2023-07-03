provider "kubectl" {
  config_context_cluster = "gke_devops-challenge-faceit_europe-west1_test-app-beb-cluster"
#  config_path = "/home/rentan/devops-challenge/test-app/gke-kubeconfig.yaml"
  config_path = "/home/rentan/devops-challenge/test-app/terraform/new-quickstart-gke.yaml"

}

provider "kubernetes" {
  #config_path = "/home/rentan/devops-challenge/test-app/gke-kubeconfig.yaml"
  config_path = "/home/rentan/devops-challenge/test-app/terraform/new-quickstart-gke.yaml"
  config_context = "gke_devops-challenge-faceit_europe-west1_test-app-beb-cluster"
}
output "cluster_config" {
  value = google_container_cluster.cluster.endpoint
}

resource "kubernetes_service_account" "gke_ksa_service_account" {
  provider = kubernetes
  metadata {
    name        = "gke-ksa"
    namespace   = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = "${var.google_cloud_app_service_account}@${var.google_cloud_project}.iam.gserviceaccount.com"
    }
  }
}

#resource "google_project_iam_member" "qs_ksa_sa_user_policy" {
#  project = var.google_cloud_project
#  role    = "roles/iam.serviceAccountUser"
#  member  =  "serviceAccount:${var.google_cloud_app_service_account}@devops-challenge-faceit.iam.gserviceaccount.com"
#}
#resource "google_project_iam_member" "gke_ksa_sa_policy" {
#  project = var.google_cloud_project
#  role    = "roles/iam.workloadIdentityUser"
#  member  = "serviceAccount:devops-challenge-faceit.svc.id.goog[default/gke-ksa].quickstart-service-account@devops-challenge-faceit.iam.gserviceaccount.com"
#}

resource "kubernetes_secret" "db_creds" {
  metadata {
    name = "db-creds"
  }

  data = {
    "username"  = "postgres"
    "password"  = "mysecretpassword"
    "database"  = "quickstart_db"
  }
}

#resource "google_service_account_key" "key" {
#  service_account_id = "${var.google_cloud_app_service_account}@${var.google_cloud_project}.iam.gserviceaccount.com"
#}
#
#resource "local_file" "key_file" {
#  filename = "~/key.json"
#  content  = google_service_account_key.key.private_key
#}
#
#output "keyfile" {
#  value  = google_service_account_key.key.private_key
#  sensitive = true
#}
resource "kubernetes_secret" "sa_secret" {
  metadata {
    name = "quickstart-sa-secret"
  }

  data = {
    "web-app.json" = file("/home/rentan/key.json")
  }
}


resource "kubectl_manifest" "web_app" {
  provider  = kubectl
  yaml_body = <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app-beb
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app-beb
  template:
    metadata:
      labels:
        app: test-app-beb
    spec:
      serviceAccountName: gke-ksa
      containers:
        - name: test-app-container
          image: gcr.io/devops-challenge-faceit/test-app-beb:latest
          ports:
            - containerPort: 8080
          env:
            - name: POSTGRESQL_HOST
              value: 127.0.0.1
            - name: POSTGRESQL_USER
              valueFrom:
                secretKeyRef:
                  name: db-creds
                  key: username
            - name: POSTGRESQL_PASS
              valueFrom:
                secretKeyRef:
                  name: db-creds
                  key: password
            - name: POSTGRESQL_DBNAME
              valueFrom:
                secretKeyRef:
                  name: db-creds
                  key: database
              resources:
                limits:
                  cpu: "0.5"
                  memory: "512Mi"
                requests:
                  cpu: "0.2"
                  memory: "256Mi"

        - name: cloud-sql-proxy
          image: gcr.io/cloudsql-docker/gce-proxy:1.28.0 # make sure the use the latest version
          command:
            - "/cloud_sql_proxy"
            - "-ip_address_types=PRIMARY"
            # Replace DB_PORT with the port the proxy should listen on
            # Defaults: MySQL: 3306, Postgres: 5432, SQLServer: 1433
            - "-instances=devops-challenge-faceit:europe-west1:quickstart-instance=tcp:5432"
            - "-credential_file=/secrets/web-app.json"
          securityContext:
            runAsNonRoot: true
          volumeMounts:
          - name: quickstart-sa-volume
            mountPath: /secrets/
            readOnly: true
          resources:
            requests:
              memory: "256Mi"
              cpu:    "1"
      readinessProbe:
        httpGet:
          path: /
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
      livenessProbe:
        httpGet:
          path: /health
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 10
      volumes:
      - name: quickstart-sa-volume
        secret:
          secretName: quickstart-sa-secret
EOF
}

resource "kubectl_manifest" "web_app_ingress" {
  provider  = kubectl
  yaml_body = <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: test-app-ingress
spec:
  selector:
    app: test-app-beb
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF
}


#data "google_container_cluster" "my_cluster" {
#  name     = "test-app-beb-cluster"
#  location = "europe-west1"
#}
#
#output "load_balancer_ip" {
#  value = google_container_cluster.cluster.endpoint
#}
#
