provider "aws" {
  alias  = "bucket-replica-region"
  region = "${var.replica_region}"
}

# Replica bucket is created if replication is enabled
resource "aws_s3_bucket" "replica" {
  # count = "${var.enable_replica}"
  provider = "aws.bucket-replica-region"

  bucket = "${var.bucket}-${var.replica_region}"
  acl = "${var.acl}"

  region = "${var.replica_region}"

  versioning { enabled = true }

  # Generic lifecycle will match the parent bucket
  lifecycle_rule {
    id = "${var.lifecycle_name}"
    prefix = "${var.lifecyle_days}"
    enabled = "${var.enable_lifecycle}"

    expiration {
      days = "${var.lifecyle_days}"
    }
  }

  # Replica bucket sends old data to cold storage to reduce costs
  lifecycle_rule {
    id = "Move to cold storage"
    prefix = ""
    enabled = "${var.replica_enable_cold_storage}"

    # Infrequent acess is cheaper than standard, but with fast turnaround for recovery
    transition {
      days = "${var.replica_ia_days}"
      storage_class = "STANDARD_IA"
    }

    # Glacier is cheaper than IA, but with slow turnaround for recovery
    transition {
      days = "${var.replica_glacier_days}"
      storage_class = "GLACIER"
    }
  }

  # Lifecycle rule to expire old objects permenently
  lifecycle_rule {
    id = "Expire old object versions"
    prefix = ""
    enabled = true

    noncurrent_version_expiration {
      days = "${var.replica_lifecyle_days_versions}"
    }
  }
}