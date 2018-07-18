provider "aws" {
  alias  = "bucket-primary-region"
  region = "${var.bucket_region == "auto" ? format("%s", data.aws_region.region.name) : var.bucket_region}"
}

data "aws_region" "region" {}

resource "aws_s3_bucket" "generic" {
  provider = "aws.bucket-primary-region"

  bucket = "${var.bucket}" # ex: "foo-staging"
  acl = "${var.acl}"

  # Use our current region from runtime unless sepcified
  region = "${var.bucket_region == "auto" ? format("%s", data.aws_region.region.name) : var.bucket_region}"

  # Versioning must be enabled in buckets with replication enabled
  versioning {
    enabled = "${var.enable_versioning}"
  }

  policy = "${var.policy}"

  # Enable this generic lifecycle to either filter all objects with the default or specific objects with a prefix
  lifecycle_rule {
    id = "${var.lifecycle_name}"
    prefix = "${var.lifecycle_prefix}"
    enabled = "${var.enable_lifecycle}"

    expiration {
      days = "${var.lifecyle_days}"
    }
  }

  # Lifecycle rule to expire versioned objects, enabled when versioning or replication is enabled
  lifecycle_rule {
    id = "Expire old object versions"
    prefix = ""
    enabled = "${(var.enable_versioning) && var.enable_lifecycle}"

    noncurrent_version_expiration {
      days = "${var.lifecyle_days_versions}"
    }
  }

  # Lifecycle rule to expire object delete markers, enabled when versioning or replication is enabled
  lifecycle_rule {
    id = "Expire object delete markers"
    prefix = ""
    enabled = "${(var.enable_versioning) && var.versioning_expire_deletes}"

    expiration {
      days = "${var.lifecyle_days_delete_markers}"
      expired_object_delete_marker = true
    }
  }

  # Lifecycle rule to clean up expired multipart uploads
  lifecycle_rule {
    id = "Delete Incomplete Multipart Uploads"
    prefix = "${var.multipart_prefix}"
    enabled = "${var.enable_multipart_cleanup}"
    abort_incomplete_multipart_upload_days = "${var.multipart_expire_days}"
  }

  logging {
    target_bucket = "${var.logging_bucket}"
    target_prefix = "${var.bucket}/"
  }

  tags {
    "Name" = "${var.bucket}"
    "creator" = "${var.tag_creator}"
    "env" = "${var.tag_env}"
    "source" = "terraform"
  }
}