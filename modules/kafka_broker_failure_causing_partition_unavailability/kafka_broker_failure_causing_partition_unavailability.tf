resource "shoreline_notebook" "kafka_broker_failure_causing_partition_unavailability" {
  name       = "kafka_broker_failure_causing_partition_unavailability"
  data       = file("${path.module}/data/kafka_broker_failure_causing_partition_unavailability.json")
  depends_on = [shoreline_action.invoke_check_kafka_metrics,shoreline_action.invoke_update_kafka_server_config]
}

resource "shoreline_file" "check_kafka_metrics" {
  name             = "check_kafka_metrics"
  input_file       = "${path.module}/data/check_kafka_metrics.sh"
  md5              = filemd5("${path.module}/data/check_kafka_metrics.sh")
  description      = "Resource exhaustion due to high traffic or large message sizes"
  destination_path = "/agent/scripts/check_kafka_metrics.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_kafka_server_config" {
  name             = "update_kafka_server_config"
  input_file       = "${path.module}/data/update_kafka_server_config.sh"
  md5              = filemd5("${path.module}/data/update_kafka_server_config.sh")
  description      = "Increase the number of Kafka brokers in the cluster to ensure that there are enough replicas and that the cluster can handle the required load."
  destination_path = "/agent/scripts/update_kafka_server_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_kafka_metrics" {
  name        = "invoke_check_kafka_metrics"
  description = "Resource exhaustion due to high traffic or large message sizes"
  command     = "`chmod +x /agent/scripts/check_kafka_metrics.sh && /agent/scripts/check_kafka_metrics.sh`"
  params      = ["PATH_TO_KAFKA_INSTALLATION","PATH_TO_BROKER_LOGS_DIRECTORY"]
  file_deps   = ["check_kafka_metrics"]
  enabled     = true
  depends_on  = [shoreline_file.check_kafka_metrics]
}

resource "shoreline_action" "invoke_update_kafka_server_config" {
  name        = "invoke_update_kafka_server_config"
  description = "Increase the number of Kafka brokers in the cluster to ensure that there are enough replicas and that the cluster can handle the required load."
  command     = "`chmod +x /agent/scripts/update_kafka_server_config.sh && /agent/scripts/update_kafka_server_config.sh`"
  params      = ["PATH_TO_KAFKA_INSTALLATION","NUMBER_OF_ADDITIONAL_BROKERS_TO_ADD"]
  file_deps   = ["update_kafka_server_config"]
  enabled     = true
  depends_on  = [shoreline_file.update_kafka_server_config]
}

