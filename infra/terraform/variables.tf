variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "github_access_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "gmail_user" {
  description = "Gmail address for notifications"
  type        = string
  sensitive   = true
}

variable "gmail_app_password" {
  description = "Gmail app password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1" # Updated to Mumbai region
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "AMI ID for Jenkins server"
  type        = string
  default     = "ami-0014e7a3845e031b2" # Updated AMI for ap-south-1 (Ubuntu 22.04 LTS)
}