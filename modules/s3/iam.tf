# Policy for allowing replication from generic bucket to replica
data "aws_iam_policy_document" "replica_policy" {
  statement {
    actions   = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = ["${aws_s3_bucket.generic.arn}"]
  }

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl"
    ]
    resources = ["${aws_s3_bucket.generic.arn}/*"]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = ["${aws_s3_bucket.replica.arn}/*"]
  }
}

# IAM role to allow S3 to perform replication
data "aws_iam_policy_document" "replication_role" {
  statement {
    actions   = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = ["s3.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_policy" "replication" {
  name = "iam-role-policy-replication-${var.bucket}"
  path = "/"
  policy = "${data.aws_iam_policy_document.replica_policy.json}"
}

resource "aws_iam_role" "replication" {
  name = "iam-role-replication-${var.bucket}"
  assume_role_policy = "${data.aws_iam_policy_document.replication_role.json}"
}

resource "aws_iam_policy_attachment" "replication" {
  name = "iam-role-attachment-replication-${var.bucket}"
  roles = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}
