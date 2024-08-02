# Update Alternate Contacts
data "aws_region" "aft_management_region" {}

data "aws_caller_identity" "aft_management_id" {}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_ssm_parameter" "aft_request_metadata_table_name" {
  name = "/aft/resources/ddb/aft-request-metadata-table-name"
}

data "aws_dynamodb_table" "aft_request_metadata_table" {
  name = data.aws_ssm_parameter.aft_request_metadata_table_name.value
}

data "aws_ssm_parameter" "aft_customizations_max_concurrent" {
  name = "/aft/config/customizations/maximum_concurrent_customizations"
}

data "archive_file" "aft_alternate_contacts_extract" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/aft_alternate_contacts_extract"
  output_path = "${path.module}/lambda/aft_alternate_contacts_extract.zip"
}

data "archive_file" "aft_alternate_contacts_add" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/aft_alternate_contacts_add"
  output_path = "${path.module}/lambda/aft_alternate_contacts_add.zip"
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install jsonschema -t ${path.module}/lambda/aft_alternate_contacts_validate/"
  }

  # This will cause the null_resource to run every time
  # You might want to add some logic to prevent unnecessary runs
  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "aft_alternate_contacts_validate" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/aft_alternate_contacts_validate"
  output_path = "${path.module}/lambda/aft_alternate_contacts_validate.zip"

  depends_on = [null_resource.install_dependencies_validate]
}