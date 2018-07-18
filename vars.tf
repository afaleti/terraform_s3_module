# This seeds object names to ensure they are unique in AWS.
# This matters for features like S3 buckets where names are globally unique
variable "name_prefix" { default = "MyCompany" }

# S3 Settings
variable "s3_lifecycle_days" { default = 7 }
variable "s3_lifecycle_days_versions" { default = 1 }