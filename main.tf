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
    "source" = "terraform"
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
  tag_creator = "Freddie Mercury"
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

# Example Standard bucket with versioning disabled
module "no_versioning_bucket" {
  source = "modules/bucket/"

  bucket = "${var.name_prefix}-no-versioning-bucket-${terraform.workspace}"
  logging_bucket = "${aws_s3_bucket.logging_bucket.id}"

  enable_versioning = false

  tag_env = "${terraform.workspace}"
  tag_creator = "Chase Graves"
}

# Example Standard bucket with a lifecycle
module "no_versioning_bucket" {
  source = "modules/bucket/"

  bucket = "${var.name_prefix}-no-versioning-bucket-${terraform.workspace}"
  logging_bucket = "${aws_s3_bucket.logging_bucket.id}"

  enable_lifecycle = true
  lifecyle_days = 10
  lifecyle_days_versions = 3 # we ship a new version every day, only keep the last 3
  lifecyle_prefix = "temp-" # our app uses the temp prefix for temporary files


  tag_env = "${terraform.workspace}"
  tag_creator = "Chase Graves"
}

# Example Standard bucket with replication
module "replicated_bucket" {
  source = "modules/bucket-with-replica/"

  bucket = "${var.name_prefix}-replicated-bucket-${terraform.workspace}"
  logging_bucket = "${aws_s3_bucket.logging_bucket.id}"

  enable_replica = true
  replica_enable_cold_storage = true # We keep this data for compliance, move it to cold storage
  replica_ia_days = "30" # We need to recover 30 days to rebuild the app for disaster recovery, move older data to IA
  replica_glacier_days = "90" # We only need to recover 90 days for standard requests. Older data should move to glacier

  tag_env = "${terraform.workspace}"
  tag_creator = "John Doe"
}
