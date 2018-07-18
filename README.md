# terraform_s3_module
Example s3 module that supports simple lifecycles to keep unexpected s3 costs down

Default lifecycles:
  * Lifecycle rule to expire versioned objects, enabled when versioning or replication is enabled
  * Lifecycle rule to expire object delete markers, enabled when versioning or replication is enabled
  * Lifecycle rule to clean up expired multipart uploads