data "google_client_config" "provider" {}

data "google_container_cluster" "primary" {
  name     = "gke-quickstart"
  location = "europe-west4"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}
provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "helm_release" "otomi" {
  name = "quickstart-otomi"

  repository = "https://otomi.io/otomi-core"
  chart      = "otomi"

  values = [
    file("${path.module}/otomi-values-gke.yaml")
  ]
}
