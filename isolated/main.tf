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
  Can enter variables first or wait for prompt
 *****************************************/

variable "project_id" {}

variable "source_image_self_link" {}

/******************************************
  Optionally Change These Variables
 *****************************************/

variable "vpc_name" {
  default = "isolated-temp-vpc"
}
variable "region" {
  default = "us-central1"
}

variable "gce_vm_zone" {
  default = "us-central1-a"
}

variable "sub_cidr" {
  default = "10.0.0.0/28"
}

variable "vpc_flow_log_interval" {
  default = "INTERVAL_5_MIN"
}

variable "vpc_flow_log_sampling" {
  default = 1
}

variable "region_router_asn" {
  default = 4200000900
}

/******************************************
  Network
 *****************************************/

resource "google_compute_network" "vpc" {
  project                         = var.project_id
  name                            = var.vpc_name
  routing_mode                    = "GLOBAL"
  auto_create_subnetworks         = false
}

resource "google_compute_subnetwork" "subnet" {
  provider      = google-beta
  project       = var.project_id
  ip_cidr_range = var.sub_cidr
  name          = "${google_compute_network.vpc.name}-${var.region}"
  network       = google_compute_network.vpc.self_link
  region        = var.region

  private_ip_google_access = true

  log_config {
    aggregation_interval  = var.vpc_flow_log_interval
    flow_sampling         = var.vpc_flow_log_sampling
    metadata              = "INCLUDE_ALL_METADATA"
  }

}

resource "google_compute_firewall" "firewall_rule_iap" {
  provider        = google-beta
  project         = var.project_id
  name            = "${google_compute_network.vpc.name}-allow-iap-ingress"
  network         = google_compute_network.vpc.self_link
  direction       = "INGRESS"
  priority        = 1000
  source_ranges   = ["35.235.240.0/20"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["22",]
  }

}

/******************************************
  Cloud Router
 *****************************************/

resource "google_compute_router" "cloud_nat_router" {
  name    = "${google_compute_network.vpc.name}-${var.region}-nat-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.self_link
  bgp {
    asn = var.region_router_asn
  }
}

/******************************************
  Cloud NAT
 *****************************************/

resource "google_compute_router_nat" "cloud_nat" {
  name                               = "${google_compute_network.vpc.name}${var.region}-nat"
  project                            = var.project_id
  router                             = google_compute_router.cloud_nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}

/******************************************
  Temp VM Service Account
 *****************************************/

resource "google_service_account" "temp_vm_service_account" {
  project     = var.project_id
  account_id  = "temp-vm-sa"
}

/******************************************
  GCE VM
 *****************************************/

resource "google_compute_instance" "temp_instance" {
  depends_on = [google_compute_network.vpc, google_compute_subnetwork.subnet, google_service_account.temp_vm_service_account]
  project         = var.project_id
  zone            = var.gce_vm_zone
  machine_type    = "e2-standard-4"
  name            = "temp-vm"

  service_account {
    email = google_service_account.temp_vm_service_account.email
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = var.source_image_self_link
      type  = "pd-ssd"
      size  = 25
    }
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

}