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
  PubSub Topic
 *****************************************/

# Creation
resource "google_pubsub_topic" "sink_topic" {
  project = var.project_id
  name    = var.sink_pubsub_topic_name
}
# IAM Policy Data
data "google_iam_policy" "sink_topic_iam_policy_data" {
  binding {
    members = [google_logging_organization_sink.org_log_sink.writer_identity]
    role = "roles/pubsub.publisher"
  }
}

# IAM Policy Applied
resource "google_pubsub_topic_iam_policy" "sink_topic_iam_poicy" {
  project     = var.project_id
  depends_on  = [google_logging_organization_sink.org_log_sink]
  policy_data = data.google_iam_policy.sink_topic_iam_policy_data.policy_data
  topic       = google_pubsub_topic.sink_topic.name
}

/******************************************
  Org Log Sink
 *****************************************/

resource "google_logging_organization_sink" "org_log_sink" {
  destination       = "pubsub.googleapis.com/${google_pubsub_topic.sink_topic.id}"
  name              = var.sink_name
  org_id            = var.organization_id
  include_children  = true
  filter            = "protoPayload.methodName:'SetIamPolicy'"
}

///******************************************
//  Function
// *****************************************/
//
//resource "google_cloudfunctions_function" "test_function" {
//  project = var.project_id
//  name    = "test-function"
//  runtime = ""
//}