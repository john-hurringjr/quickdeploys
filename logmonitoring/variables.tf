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
  Varables
 *****************************************/

variable "project_id" {
  type        = string
  description = "Project ID which will host the pubsub topic/subscription for sink"
}

variable "sink_pubsub_topic_name" {
  type        = string
  description = "Name of PubSub topic for sink"
}

variable "sink_pubsub_subscription_name" {
  type        = string
  description = "Name of PubSub subscription to be subscribed to topic for sink"
}

variable "sink_name" {
  type        = string
  description = "Name of org sink"
}

variable "sink_subscription_service_account_name" {
  type        = string
  description = "Name of service account to be used to access sink subsription"
}

variable "sink_filter" {
  type        = string
  description = "Any filters desired for sink. Leave blank to recieve all logs"
}

variable "organization_id" {
  type        = string
  description = "Org ID for sink to collect logs from"
}