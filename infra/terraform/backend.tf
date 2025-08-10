terraform {
  backend "s3" {
    bucket         = "tech-nova-tfstate"  # Pre-created bucket
    key            = "prod/jenkins.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"  # For state locking
  }
}