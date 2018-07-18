# Create the logging bucket manually to ensure we don't make it log to itself. This prevents expontential bucket growth.
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.name_prefix}-logging-${terraform.workspace}"
  acl = "log-delivery-write"

  # Keep activity logs for a year for PCI/SOX compliance
  lifecycle_rule {
    id = "logs"
    prefix = "*"
    enabled = true

    expiration {
      days = 365
    }
  }

  tags {
    "Name" = "bucket-logging-${terraform.workspace}"
  }
}

# Example Standard bucket with nothing flashy
module "normal_bucket" {
  source = "modules/bucket/"

  bucket = "${var.name_prefix}-normal-bucket-${terraform.workspace}"
  logging_bucket = "${aws_s3_bucket.logging_bucket.id}"
  tag_env = "${terraform.workspace}"
  tag_creator = "John Doe"
}

# Example bucket with policy
module "policy_bucket" {
  source = "modules/bucket"
  policy = "${data.aws_iam_policy_document.policy_bucket.json}"

  bucket = "${var.name_prefix}-policy-bucket-${terraform.workspace}"
  logging_bucket = "${aws_s3_bucket.logging_bucket.id}"
  tag_env = "${terraform.workspace}"
  tag_creator = "John Doe"
}

data "aws_iam_policy_document" "policy_bucket" {
  "statement" {
    actions = [
      "s3:source",
    ]

    resources = [
      "test",
    ]
  }
}
