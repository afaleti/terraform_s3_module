# Take in a list of bucket names to create
variable "bucket" { }

# config
variable "logging_bucket"    { }
variable "acl"               { default = "private" }
variable "policy"            { default = "" }
variable "bucket_region"     { default = "auto" type = "string"}

# versioning config
variable "enable_versioning"         { default = true }
variable "versioning_expire_deletes" { default = true }

# lifecyle config
variable "enable_lifecycle"             { default = false }
variable "lifecyle_days"                { default = 150 }
variable "enable_version_lifecycle"     { default = true }
variable "lifecyle_days_versions"       { default = 30 } # Days to keep old object versions
variable "lifecyle_days_delete_markers" { default = 10 } # Days to keep delete markers
variable "lifecycle_prefix"             { default = ""} # Blank = "Whole Bucket"
variable "lifecycle_name"               { default = "all"}

# multipart lifecycle config
variable "enable_multipart_cleanup" { default = true }
variable "multipart_expire_days"    { default = 7 }
variable "multipart_prefix"         { default = ""} # Blank = "Whole Bucket"

# tags
variable "tag_creator" { }
variable "tag_env"     { }
