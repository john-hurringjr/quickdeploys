/**
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
  GKE - Cluster
 *****************************************/

resource "google_container_cluster" "test_cluster" {
  provider                  = google-beta
  project                   = var.project_id
  name                      = "test-gke-cluster"
  location                  = var.location
  remove_default_node_pool  = true
  network                   = var.network_self_link
  subnetwork                = var.subnet_self_link
  initial_node_count        = 1
  networking_mode           = "VPC_NATIVE"

  default_snat_status {
    disabled = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.master_authorized_cidrs
    }
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_cidr
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  master_auth {
    username = var.username
    password = var.password
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    istio_config {
      disabled = false
    }
  }

}

/******************************************
  GKE - Node Pool - 1 - Service Account
 *****************************************/

resource "google_service_account" "gke_node_pool_1_service_account" {
  project     = var.project_id
  account_id  = "gke-node-pool-1"
}

/******************************************
  GKE - Node Pool - 1
 *****************************************/

resource "google_container_node_pool" "test_node_pool_1" {
  project = var.project_id
  location = var.location
  cluster = google_container_cluster.test_cluster.name
  node_count = 2

  autoscaling {
    max_node_count = 6
    min_node_count = 1
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 2
  }

  management {
    auto_repair   = true
    auto_upgrade  = true
  }

  node_config {
    disk_size_gb  = 25
    disk_type     = "pd-ssd"
    machine_type  = "n1-standard-2"
    labels = {
      node-pool = "test-node-pool-1"
    }
    service_account = google_service_account.gke_node_pool_1_service_account.email

  }

}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.test_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.test_cluster.)
  }
}

resource "helm_release" "example" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"

  values = [
    file("values.yaml")
  ]

  set {
    name  = "runnerRegistrationToken"
    value = var.gitlab_reg_token
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${google_container_cluster.test_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.test_cluster.master_auth.0.cluster_ca_certificate)
}