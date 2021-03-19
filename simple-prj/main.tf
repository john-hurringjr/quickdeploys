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
  Project
 *****************************************/

resource "google_project" "project" {
  name            = "Simple Project"
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
}

/******************************************
  APIs to Enable
 *****************************************/

resource "google_project_service" "enable_compute_api" {
  depends_on          = [google_project.project]
  project             = google_project.project.project_id
  service             = "compute.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "enable_gke_api" {
  depends_on          = [google_project.project, google_project_service.enable_compute_api]
  project             = google_project.project.project_id
  service             = "container.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "enable_container_registry_api" {
  depends_on          = [google_project.project, google_project_service.enable_compute_api]
  project             = google_project.project.project_id
  service             = "containerregistry.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "enable_artifact_registry_api" {
  depends_on          = [google_project.project, google_project_service.enable_compute_api]
  project             = google_project.project.project_id
  service             = "artifactregistry.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "enable_secret_manager_api" {
  depends_on          = [google_project.project, google_project_service.enable_compute_api]
  project             = google_project.project.project_id
  service             = "secretmanager.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "enable_cloudfunctions_api" {
  depends_on          = [google_project.project]
  project             = google_project.project.project_id
  service             = "cloudfunctions.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "enable_cloudbuild_api" {
  depends_on          = [google_project.project]
  project             = google_project.project.project_id
  service             = "cloudbuild.googleapis.com"
  disable_on_destroy  = false
}

/******************************************
  Input Variables
 *****************************************/

variable "project_id" {
  description = "Project ID for your project, globally unique"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "The folder ID of where the project will reside."
  type        = string
  default     = ""
}

variable "billing_account_id" {
  description = "Billing Account ID where costs of the project will be charged."
  type        = string
  default     = ""
}