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
 Easiest to update these in the variables.auto.tfvars file
 *****************************************/

variable "project_id" {}
variable "test_user_id" {}
variable "accesspolicy_number" {}
variable "accesslevel_id" {}

/******************************************
  Set IAM Policy
 *****************************************/

resource "google_project_iam_member" "test_iap_condition" {
  member  = "user:${var.test_user_id}"
  role    = "roles/iap.tunnelResourceAccessor"
  condition {
    expression  = "'accessPolicies/${var.accesspolicy_number}/accessLevels/${var.accesslevel_id}' in request.auth.access_levels"
    title       = "testingiapaccess"
  }
}