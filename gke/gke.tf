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
  GKE
 *****************************************/

resource "google_container_cluster" "test_cluster" {
  provider                  = google-beta
  project                   = var.project_id
  name                      = "test-gke-cluster"
  location                  = "us-central1"
  remove_default_node_pool  = true
  network                   = var.network_self_link
  subnetwork                = var.subnet_self_link
  initial_node_count        = 1

  private_cluster_config {
    enable_private_endpoint = false
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