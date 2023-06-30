provider "kubectl" {
  config_context_cluster = "gke_devops-challenge-faceit_europe-west1_test-app-beb-cluster"
  config_path = "/home/rentan/devops-challenge/test-app/gke-kubeconfig.yaml"
}
output "cluster_config" {
  value = google_container_cluster.cluster.endpoint
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
      serviceAccountName:
      containers:
        - name: test-app-beb
          image: gcr.io/devops-challenge-faceit/test-app-beb:latest
          ports:
            - containerPort: 8080
          env:
          - name  : INSTANCE_CONNECTION_NAME
            value : "devops-challenge-faceit:europe-west1:quickstart-instance"
          - name  : POSTGRESQL_USER
            value : "postgres"
          - name  : POSTGRESQL_DBNAME
            value : "quickstart_db"
          - name  : POSTGRESQL_HOST
            value : "/cloudsql/devops-challenge-faceit:europe-west1:quickstart-instance"
          - name  : POSTGRESQL_PASS
            value : "mysecretpassword"
          resources:
            limits:
              cpu: "0.5"
              memory: "512Mi"
            requests:
              cpu: "0.2"
              memory: "256Mi"

        - name: cloud-sql-proxy
          # It is recommended to use the latest version of the Cloud SQL Auth Proxy
          # Make sure to update on a regular schedule!
          image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.0
          args:
            # If connecting from a VPC-native GKE cluster, you can use the
            # following flag to have the proxy connect over private IP
            # - "--private-ip"

            # Enable structured logging with LogEntry format:
            - "--structured-logs"

            # Replace DB_PORT with the port the proxy should listen on
            - "--port=5432"
            - "devops-challenge-faceit:europe-west1:quickstart-instance"

          securityContext:
            # The default Cloud SQL Auth Proxy image runs as the
            # "nonroot" user and group (uid: 65532) by default.
            runAsNonRoot: true
          # You should use resource requests/limits as a best practice to prevent
          # pods from consuming too many resources and affecting the execution of
          # other pods. You should adjust the following values based on what your
          # application needs. For details, see
          # https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
          resources:
            limits:
              cpu: "0.5"
              memory: "512Mi"
            requests:
              # The proxy's memory use scales linearly with the number of active
              # connections. Fewer open connections will use less memory. Adjust
              # this value based on your application's requirements.
              memory: "256Mi"
              # The proxy's CPU use scales linearly with the amount of IO between
              # the database and the application. Adjust this value based on your
              # application's requirements.
              cpu:    "0.25"

---

apiVersion: v1
kind: Service
metadata:
  name: cloud-run-service
spec:
  selector:
    app: test-app-beb
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: LoadBalancer
EOF
}
