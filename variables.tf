variable "account_no" {
  type        = string
  description = "AWS Account Number"
  default     = "1234567890"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources"
  default = {
    Environment     = "production"
    Owner-Email     = "infradev-segun@steghub.com"
    Managed-By      = "Terraform"
    Billing-Account = "1234567890"
  }
}
variable "name" {
  type        = string
  description = "Name prefix for resources"
  default     = "ACS"
}

variable "ami" {
  type        = string
  description = "AMI ID for EC2 instances"
  default     = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI for your region if needed
}

variable "keypair" {
  type        = string
  description = "Key pair name for EC2 instances"
  default     = "my-key-name"
}

variable "master-username" {
  type        = string
  description = "RDS master username"
     } 

variable "master-password" {
  type        = string
  description = "RDS master password"
  sensitive   = true

}
variable "enable_pro_services" {
  type        = bool
  description = "Toggle resources requiring LocalStack Pro / licensed AWS features"
  default     = true
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}