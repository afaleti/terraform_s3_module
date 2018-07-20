# terraform_s3_module
Example s3 module that supports simple lifecycles to keep unexpected s3 costs down

### Default lifecycles:
#### enable_multipart_cleanup
By default S3 leaves partial uploads in the bucket and happily charges you to store these hidden objects.  This rule will purge them after an appropriate waiting period.  This feature is enabled by default.

#### enable_version_lifecycle
A common forgotten issue with object versioning is paying to store old versions of objects indefinitely. This lifecycle rule cleans up old object versions based on a time setting. This feature is enabled by default when versioning is enabled.

#### versioning_expire_deletes
Buckets with versioning enabled will keep delete markers for objects lying around. The costs for this come from increased execution time and bandwidth used when running certain api calls that list versioned objects. This feature is enabled by default when versioning is enabled.
  
### Replication lifecycles
The `bucket-with-replica` module provides an example of similar lifecycle policies that can be applied to a disaster recovery bucket.  This module automatically creates a replica bucket in another region.

#### replica_enable_cold_storage
Replica buckets automatically tier objects to Infrequent Access and Glacier as they age.  This can be used to keep disaster recovery bucket costs low.  To enable this feature, set this value to `true` when creating the bucket

### Custom Lifecycle
#### enable_lifecycle
For buckets containing data that slowly becomes irrelevant (logs), this is a generic lifecycle that can be applied to either the whole bucket or to any object with the given prefix using `lifecycle_prefix`.  Disabled by default.

### Future Improvements:
I fully expect that following the release of Terraform 0.12, that I will be able to merge the two modules into one using the new `if` block feature.  In addition to that improvement, I will probably also be able to use the `for` feature to generate any number of generic lifecycles from a list of prefixes.