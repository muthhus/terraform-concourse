variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
}

variable "aws_profile" {
  description = "This is the AWS profile name as set in the shared credentials file. Used to upload the Concourse keys to S3. Omit this if you're using environment variables."
  default     = ""
}

variable "concourse_keys_version" {
  description = "Change this if you want to re-generate Concourse keys"
  default     = "1"
}
