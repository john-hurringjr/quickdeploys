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
  Can enter variable for proejct
  id first or wait for prompt
 *****************************************/

variable "project_id" {}

/******************************************
  Optionally Change These Variables
 *****************************************/

variable "vpc_name" {
  default = "simple-vpc"
}
variable "region_1" {
  default = "us-east4"
}
variable "region_2" {
  default = "us-central1"
}

variable "sub_1_cidr" {
  default = "10.0.0.0/19"
}
variable "sub_2_cidr" {
  default = "10.128.0.0/19"
}

variable "vpc_flow_log_interval" {
  default = "INTERVAL_15_MIN"
}

variable "vpc_flow_log_sampling" {
  default = 0.5
}

variable "region_1_router_asn" {
  default = 4200000900
}

variable "region_2_router_asn" {
  default = 4200000901
}

/******************************************
  Network
 *****************************************/

resource "google_compute_network" "vpc" {
  project                         = var.project_id
  name                            = var.vpc_name
  routing_mode                    = "GLOBAL"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

module "on_prem_vpc_region_1_subnet" {
  source                = "github.com/john-hurringjr/test-modules/networking/subnet/generic"
  project_id            = var.project_id
  network_self_link     = google_compute_network.vpc.self_link
  network_name          = google_compute_network.vpc.name
  region                = var.region_1
  cidr                  = var.sub_1_cidr
  vpc_flow_log_interval = var.vpc_flow_log_interval
  vpc_flow_log_sampling = var.vpc_flow_log_sampling
  subnet_number         = "1"
  private_google_access = "false"
}

module "on_prem_vpc_region_2_subnet" {
  source                = "github.com/john-hurringjr/test-modules/networking/subnet/generic"
  project_id            = var.project_id
  network_self_link     = google_compute_network.vpc.self_link
  network_name          = google_compute_network.vpc.name
  region                = var.region_2
  cidr                  = var.sub_2_cidr
  vpc_flow_log_interval = var.vpc_flow_log_interval
  vpc_flow_log_sampling = var.vpc_flow_log_sampling
  subnet_number         = "1"
  private_google_access = "false"
}

module "on_prem_vpc_firewall_allow_iap_all" {
  source            = "github.com/john-hurringjr/test-modules/networking/firewall-rules/all/allow-ingress-iap"
  project_id        = var.project_id
  network_self_link = google_compute_network.vpc.self_link
  network_name      = google_compute_network.vpc.name
}

module "on_prem_vpc_firewall_allow_rfc1918_all" {
  source            = "github.com/john-hurringjr/test-modules/networking/firewall-rules/all/allow-ingress-rfc1918"
  project_id        = var.project_id
  network_self_link = google_compute_network.vpc.self_link
  network_name      = google_compute_network.vpc.name
}

/******************************************
  Set Up Cloud NAT
 *****************************************/
module "cloud_nat_region_1" {
  source                  = "github.com/john-hurringjr/test-modules/networking/nat/auto-ip-all-region-subnets"
  project_id              = var.project_id
  network_self_link       = google_compute_network.vpc.self_link
  network_name            = google_compute_network.vpc.name
  cloud_router_asn_number = var.region_1_router_asn
  nat_region              = var.region_1
}

module "cloud_nat_region_2" {
  source                  = "github.com/john-hurringjr/test-modules/networking/nat/auto-ip-all-region-subnets"
  project_id              = var.project_id
  network_self_link       = google_compute_network.vpc.self_link
  network_name            = google_compute_network.vpc.name
  cloud_router_asn_number = var.region_2_router_asn
  nat_region              = var.region_2
}